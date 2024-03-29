import java.io.*;
import java.net.*;



class ServerThread extends Thread{


    public static final int PACKET_AT_A_TIME = 100;

    private String fileName;
    private int packetSize, headerLength, dataLength;
    private Socket socket;
    private OutputStream out;
    private InputStream fileIn;
    private boolean sendSingleFile;

    public ServerThread(Socket s, String fileName, int packetSize, int headerLength, int fieldCount, boolean sendSingleFile) throws IOException{
        this.fileName = fileName;
        this.packetSize = packetSize;
        this.headerLength = headerLength;
        this.dataLength = fieldCount * 4;
        this.sendSingleFile = sendSingleFile;
        System.out.println("Packet size is: " + packetSize);
        System.out.println("MSS at receiving side is supposed to be set to " + packetSize);
        socket = s;
        out = new DataOutputStream(socket.getOutputStream());
       //out = new BufferedOutputStream(socket.getOutputStream());
        System.out.println("Connection from " +
            socket.getInetAddress().toString() + ":" + socket.getPort());
        /* calls Thread.run() */
        start();
    }

    class EOReadingFileException extends Exception{
        public EOReadingFileException(){
            super();
        }
    }

    private static byte[] short2byte(short s){
		byte[] res = new byte[2];
		res[1] = (byte)((s & 0xFF));
		res[0] = (byte)(((s >> 8) & 0xFF));
		return res;
    }
    private static byte[] intToByteArray(int a) {
        return new byte[] {
            (byte) ((a >> 24) & 0xFF),
            (byte) ((a >> 16) & 0xFF),
            (byte) ((a >> 8) & 0xFF),
            (byte) (a & 0xFF)
        };
    }

    @Override
    public void run() {
        try{
            /* get file inputstream */
            fileIn = new FileInputStream(fileName);

            if(sendSingleFile){
                int bufferSize = PACKET_AT_A_TIME * packetSize;
                byte[] buffer = new byte[bufferSize];
                int packetCount = 0;
                int packetAtATime = PACKET_AT_A_TIME;

                while(true){
                    /* prepare data */
/*
                    for(int i = 0;i < packetAtATime;i++){
                        if(fileIn.read(buffer, i * packetSize + headerLength, dataLength) == -1){
                            if(sendSingleFile){
                                if(i == 0)
                                    throw new EOReadingFileException();
                                else{
                                    packetAtATime = i;
                                    break;
                                }
                            }else{
                                fileIn.close();
                                fileIn = new FileInputStream(fileName);
                                continue;
                            }
                        }
                    }
*/
                    /* prepare header */
                    for(int i = 0;i < packetAtATime;i++){
                        byte[] type = short2byte((short)(0));
                        byte[] index = intToByteArray((packetCount + i) % 65535);
                        /* arraycopy(src, srcPos, dest, destPos, length) */
                        System.arraycopy(type, 0, buffer,  packetSize * i, 2);
                        System.arraycopy(index, 0, buffer, packetSize * i + 2, 4);
                    }
                    /* send to outputstream */
                    out.write(buffer);
                    // out.flush();
                    /* packet counting */
                    packetCount += packetAtATime;
                    /* assign new memory for buffer */
                    buffer = new byte[bufferSize];
                }
            }else{
                // send continuously
                int fileSize = 80454;
                int pos = 0;
                byte[] fileBuffer = new byte[fileSize];
                fileIn.read(fileBuffer, 0, fileSize);
                int packetCount = 0;
                int bufferSize = PACKET_AT_A_TIME * packetSize;
                byte[] buffer = new byte[bufferSize];
                int packetAtATime = PACKET_AT_A_TIME;

                while(true){
                    /* prepare data & header */
                    for(int i = 0;i < packetAtATime;i++){
                        byte[] type = short2byte((short)(0));
                        byte[] index = intToByteArray((packetCount + i) % 65535);
                        /* arraycopy(src, srcPos, dest, destPos, length) */
                        System.arraycopy(type, 0, buffer,  packetSize * i, 2);
                        System.arraycopy(index, 0, buffer, packetSize * i + 2, 4);
                        System.arraycopy(fileBuffer, pos, buffer, packetSize * i + headerLength, dataLength);
                        pos = (pos + dataLength) % (fileSize - dataLength);
                    }
                    /* send to outputstream */
                    out.write(buffer);
                    /* packet counting */
                    packetCount += packetAtATime;
                }
            }
/*
        } catch (EOReadingFileException e){
            System.out.println("All data sent!");
            try{
                fileIn.close();
            }catch(Exception e2){
                e2.printStackTrace();
            }
*/
        } catch (Exception e1){
            e1.printStackTrace();
            try{
                fileIn.close();
            }catch(Exception e2){
                e2.printStackTrace();
            }
        }finally{
            System.out.println("Server socket closing...");
            try{
                socket.close();
            }catch(Exception e2){
                e2.printStackTrace();
            }
        }
    }
}



public class BMPTransferServer{

    private int serverPort;
    private String fileName;

    public BMPTransferServer(int serverPort){
        this.serverPort = serverPort;
    }

    public void startServer(String fileName, int packetSize, int headerLength, int fieldCount, boolean sendSingleFile) throws IOException{
        ServerSocket serverSocket = new ServerSocket(serverPort);
        System.out.println("Server started at port " + serverPort);
        try{
            while(true){
                /* wait for connection */
                Socket socket = serverSocket.accept();
		
		//socket.setTcpNoDelay(true);
		System.out.println(socket.getSendBufferSize());
		//socket.setSendBufferSize(52200);
                try{
                    new ServerThread(socket, fileName, packetSize, headerLength, fieldCount, sendSingleFile);
                }catch(IOException e){
                    System.out.println("Failed on creating ServerThread");
                    socket.close();
                }
            }
        }finally{
            serverSocket.close();
        }
    }

    public static final int SERVER_PORT = 20001;
    public static final String INPUT_FILE_NAME = "/home/guest/netec-java/blue.bmp";
    // public static final String INPUT_FILE_NAME = "/home/kongxiao0532/thu/projects/netec-pdp/code/RS/blue.bmp";
    public static final int PACKET_SIZE = 128;
    public static final int HEADER_LENGTH = 6;
    public static final int FIELD_COUNT = 8;

    public static void main(String[] args) throws IOException, InterruptedException {
        BMPTransferServer server = new BMPTransferServer(SERVER_PORT);
        try{
            server.startServer(INPUT_FILE_NAME, PACKET_SIZE, HEADER_LENGTH, FIELD_COUNT, false/* send continuously */);
        } catch(Exception e){
            e.printStackTrace();
        }
    }
}

