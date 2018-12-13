import java.io.*;
import java.net.*;
import java.util.Timer;
import java.util.TimerTask;

public class BMPTransferClient{

    /* packet para */
    static final int PACKET_SIZE = BMPTransferServer.PACKET_SIZE;
    static final int HEADER_LENGTH = BMPTransferServer.HEADER_LENGTH;
    static final int DATA_SIZE = BMPTransferServer.FIELD_COUNT * 2;
    static final int PKT_PER_RECV_BUFFER = 1000;

    class DataReadCompleteException extends Exception{
        public DataReadCompleteException(){
            super();
        }
    }

    private String serverAddrStr;
    private int serverPort;

    public BMPTransferClient(String serverAddrStr, int serverPort){
        this.serverAddrStr = serverAddrStr;
        this.serverPort = serverPort;
    }

    private class NetSpeedTimerTask extends TimerTask{
        public long readinSize = 0, lastReadinSize = 0;
        @Override
        public void run() {
            /* every 1 sec */
            long speed = readinSize - lastReadinSize;
            System.out.print("Current receiving speed is " + speed / 1024 / 1024 * 8 + "Mbps\n");
            lastReadinSize = readinSize;
        }
    }

    public void getInfiniteData() throws IOException{
        InetAddress serverAddr = InetAddress.getByName(serverAddrStr);
        System.out.println("Target server: " + serverAddr + ":" + serverPort);
        /* open socket to server */
        Socket socket = new Socket(serverAddr, serverPort);;
        System.out.println("Receiving side started!");
        System.out.println("Client Socket: " + socket);

        /* get in stream */
        DataInputStream in = new DataInputStream(socket.getInputStream());

        int packetSize = PACKET_SIZE;
        int dataLength = DATA_SIZE;
        int packetPerBuffer = PKT_PER_RECV_BUFFER;
        int bufferSize = packetPerBuffer * packetSize;

        Timer speedoTimer = new Timer(true);
        NetSpeedTimerTask speedoTask = new NetSpeedTimerTask();

        try{
            speedoTimer.schedule(speedoTask, 0, 1000);
            while(true){
                byte[] byteBuffer = new byte[bufferSize];
                /* read from inputstream */
                speedoTask.readinSize += in.read(byteBuffer) / packetSize * dataLength;
            }
        }catch(Exception e){
            e.printStackTrace();
            System.err.println("IO Exception...Shutting down...");
        } finally{
            /* close the socket */
            try{
                socket.close();
            }catch(IOException e){
                System.err.println("Error on closing socket...");
            }
        }
    }

    public void getFile(int fileSize, String fileName) throws IOException{
        InetAddress serverAddr = InetAddress.getByName(serverAddrStr);
        System.out.println("Target server: " + serverAddr + ":" + serverPort);
        /* open socket to server */
        Socket socket = new Socket(serverAddr, serverPort);;
        System.out.println("Receiving side started!");
        System.out.println("Client Socket: " + socket);

        /* get in stream */
        DataInputStream in = new DataInputStream(socket.getInputStream());

        /* receive data */
        byte[] image = new byte[fileSize];
        int pos = 0;
        int packetSize = PACKET_SIZE;
        int dataLength = DATA_SIZE;
        int packetPerBuffer = PKT_PER_RECV_BUFFER;
        int bufferSize = packetPerBuffer * packetSize;

        try{
            while(true){
                byte[] byteBuffer = new byte[bufferSize];
                int readLength = 0;
                /* read from inputstream */
                readLength = in.read(byteBuffer);
                System.out.println(readLength + " bytes read!");
                // if(readLength == -1)
                //     break;
                for(int i = 0;i < readLength / packetSize;i++){
                    if(pos + dataLength > fileSize){
                        /* arraycopy(src, srcPos, dest, destPos, length) */
                        /* should contain payload less than dataLength */
                        System.arraycopy(byteBuffer, packetSize * i + HEADER_LENGTH, image, pos, fileSize - pos);
                        /* stop receiving data */
                        throw new DataReadCompleteException();
                    }
                    else{
                        /* should contain payload equal to dataLength */
                        System.arraycopy(byteBuffer,  packetSize * i + HEADER_LENGTH, image, pos, dataLength);
                        pos += dataLength;
                    }
                }
                System.out.println("Now " + pos + " bytes have been received!");
            }
        } catch(DataReadCompleteException e){
            System.out.println("Receiving Complete!");
        } catch(Exception e){
            e.printStackTrace();
            System.err.println("IO Exception...Shutting down...");
        } finally{
            /* close the socket */
            try{
                socket.close();
            }catch(IOException e){
                System.err.println("Error on closing socket...");
            }
        }
        /* ideally, the connection will be closed
         * once all data has been transfered
         */
        System.out.println("Writing data into file: " + fileName);
        try{
            OutputStream out = new FileOutputStream(fileName);
            out.write(image);
            out.flush();
            out.close();
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    /* server info */
    public static final String SERVER_ADDR_STR = "10.0.0.10";
    public static final int SERVER_PORT = BMPTransferServer.SERVER_PORT;
    /* file config */
    static final int FILE_SIZE = 80454;
    static final String FILE_NAME = "recon.bmp";

    public static void main(String[] args){
        BMPTransferClient client = new BMPTransferClient(SERVER_ADDR_STR, SERVER_PORT);
        try{
            // client.getFile(FILE_SIZE, FILE_NAME);
            client.getInfiniteData();
        } catch(Exception e){
            e.printStackTrace();
        }
    }
}
