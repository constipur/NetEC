import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.DataOutputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.Socket;


class EOReadingFileException extends Exception{
    public EOReadingFileException(){
        super();
    }
}
public class BMPSendTCP{
    public static byte[] short2byte(short s){
		byte[] res = new byte[2];
		res[1] = (byte)((s & 0xFF));
		res[0] = (byte)(((s >> 8) & 0xFF));
		return res;
    }

    public static final String serverAddrStr = "202.112.237.136";
    public static final String INPUT_FILE_NAME = "/home/guest/NetEC/RS/blue.bmp";
    public static final int FIELD_COUNT = 200;
    public static final int HEADER_LENGTH = 6;
    public static final int PACKET_AT_A_TIME = 3;

    public static byte[] intToByteArray(int a) {
        return new byte[] {
            (byte) ((a >> 24) & 0xFF),
            (byte) ((a >> 16) & 0xFF),
            (byte) ((a >> 8) & 0xFF),
            (byte) (a & 0xFF)
        };
    }

    public static void main(String[] args) throws IOException, InterruptedException {
        String inputFileName = INPUT_FILE_NAME;

        int serverPort = BMPRecvTCP.PORT;
        InetAddress serverAddr = InetAddress.getByName(serverAddrStr);
        System.out.println("Server: " + serverAddr + ":" + serverPort);

        /* open socket to server */
        Socket socket = new Socket(serverAddr, serverPort);
        // socket.setTcpNoDelay(true);
        /* get file inputstream */
        InputStream fileIn = new FileInputStream(inputFileName);
        try{
            System.out.println("Client Socket: " + socket);
            // socket.setTcpNoDelay(true);
            /* get outputstream */
            OutputStream out = new DataOutputStream(socket.getOutputStream());

            /* calculate packet size */
            int dataSize = FIELD_COUNT * 2;
            int packetSize = HEADER_LENGTH + dataSize;
            System.out.println("Packet size is: " + packetSize);
            int bufferSize = 2 * packetSize;
            byte[] buffer = new byte[bufferSize];
            int packetCount = 0;
            int packetAtATime = PACKET_AT_A_TIME;

            while(true){
                /* prepare data */
                for(int i = 0;i < packetAtATime;i++){
                    if(fileIn.read(buffer, i * packetSize + HEADER_LENGTH, dataSize) == -1){
                        if(i == 0)
                            /* no data to send */
                            throw new EOReadingFileException();
                        else{
                            packetAtATime = i;
                            break;
                        }
                    }
                }
                /* prepare header */
                for(int i = 0;i < packetAtATime;i++){
                    byte[] type = short2byte((short)(0));
                    byte[] index = intToByteArray(packetCount);
                    /* arraycopy(src, srcPos, dest, destPos, length) */
                    System.arraycopy(type, 0, buffer, packetCount * i, 2);
                    System.arraycopy(index, 0, buffer, packetCount * i + 2, 4);
                }
                /* send to outputstream */
                out.write(buffer);
                // out.flush();
                /* packet counting */
                packetCount += packetAtATime;
                /* assign new memory for buffer */
                buffer = new byte[bufferSize];
            }
        } catch (Exception e){
            e.printStackTrace();
        }finally{
            System.out.println("Client socket closing...");
            socket.close();
            fileIn.close();
        }
    }
}
