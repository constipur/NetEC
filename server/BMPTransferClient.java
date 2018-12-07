import java.io.*;
import java.net.*;

public class BMPTransferClient{

    /* packet para */
    static final int HEADER_LENGTH = BMPTransferServer.HEADER_LENGTH;
    static final int FIELD_COUNT = BMPTransferServer.FIELD_COUNT;
    static final int PKT_PER_RECV_BUFFER = 10;

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
        int dataLength = 2 * FIELD_COUNT;
        int packetLength = HEADER_LENGTH + dataLength;
        int packetPerBuffer = PKT_PER_RECV_BUFFER;
        int buffersize = packetPerBuffer * packetLength;

        try{
            while(true){
                byte[] byteBuffer = new byte[buffersize];
                int readLength = 0;
                /* read from inputstream */
                readLength = in.read(byteBuffer);
                System.out.println(readLength + " bytes read!");
                if(readLength == -1)
                    break;
                for(int i = 0;i < packetPerBuffer;i++){
                    if(pos + dataLength > fileSize){
                        /* arraycopy(src, srcPos, dest, destPos, length) */
                        /* should contain payload less than dataLength */
                        System.arraycopy(byteBuffer, packetLength * i + HEADER_LENGTH, image, pos, fileSize - pos);
                        /* stop receiving data */
                        throw new DataReadCompleteException();
                    }
                    else{
                        /* should contain payload equal to dataLength */
                        System.arraycopy(byteBuffer,  packetLength * i + HEADER_LENGTH, image, pos, dataLength);
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
    public static final String SERVER_ADDR_STR = "192.168.1.2";
    public static final int SERVER_PORT = BMPTransferServer.SERVER_PORT;
    /* file config */
    static final int FILE_SIZE = 80454;
    static final String FILE_NAME = "recon.bmp";

    public static void main(String[] args){
        BMPTransferClient client = new BMPTransferClient(SERVER_ADDR_STR, SERVER_PORT);
        try{
            client.getFile(FILE_SIZE, FILE_NAME);
        } catch(Exception e){
            e.printStackTrace();
        }
    }
}