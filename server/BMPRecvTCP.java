import java.io.*;
import java.net.*;

class ServerThread extends Thread{

    private Socket socket;
    private DataInputStream in;

    public ServerThread(Socket s) throws IOException{
        socket = s;
        in = new DataInputStream(socket.getInputStream());
        System.out.println("Connection from " +
            socket.getInetAddress().toString() + ":" + socket.getPort());
        /* calls Thread.run() */
        start();
    }

    static final int FILE_SIZE = 80454;
    static final String FILE_NAME = "recon.bmp";
    static final int HEADER_LENGTH = BMPSendTCP.HEADER_LENGTH;
    static final int FIELD_COUNT = BMPSendTCP.FIELD_COUNT;


    @Override
    public void run() {
        byte[] image = new byte[FILE_SIZE];
        int pos = 0;
        int packetLength = HEADER_LENGTH + 2 * FIELD_COUNT;

        try{
            while(true){
                try{
                    byte[] byteBuffer = new byte[FILE_SIZE];
                    int readLength = 0;
                    /* read from inputstream */
                    readLength = in.read(byteBuffer);
                    System.out.println(readLength + " bytes read!");
                    if(readLength == -1)
                        break;
                    assert readLength == packetLength;
                    if(pos + FIELD_COUNT * 2 > FILE_SIZE){
                        /* should contain payload less than FIELD_COUNT * 2 */
                        System.arraycopy(byteBuffer, 6, image, pos, FILE_SIZE - pos);
                    }
                    else{
                        /* should contain payload equal to FIELD_COUNT * 2 */
                        System.arraycopy(byteBuffer, 6, image, pos, readLength);
                    }
                    pos += readLength;
                    System.out.println(pos);
                }catch(Exception e){
                    e.printStackTrace();
                }
            }
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
        assert pos == FILE_SIZE;
        System.out.println("Writing data into file: " + FILE_NAME);
        try{
            OutputStream out = new FileOutputStream(FILE_NAME);
            out.write(image);
            out.flush();
            out.close();
        }catch(Exception e){
            e.printStackTrace();
        }
    }
}

public class BMPRecvTCP{

    static final int PORT = 20001;

    public static void main(String[] args) throws IOException{
        ServerSocket serverSocket = new ServerSocket(PORT);
        // serverSocket.setReceiveBufferSize(1200);
        System.out.println("Server started");
        try{
            while(true){
                /* wait for connection */
                Socket socket = serverSocket.accept();
                try{
                    new ServerThread(socket);
                }catch(IOException e){
                    System.out.println("Failed on creating ServerThread");
                    socket.close();
                }
            }
        }finally{
            serverSocket.close();
        }
    }
}
