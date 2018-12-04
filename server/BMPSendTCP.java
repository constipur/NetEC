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


public class BMPSendTCP{
    public static byte[] short2byte(short s){
		byte[] res = new byte[2];
		res[1] = (byte)((s & 0xFF));
		res[0] = (byte)(((s >> 8) & 0xFF));
		return res;
    }

    public static final String serverAddrStr = "192.168.1.3";
    public static final String INPUT_FILE_NAME = "/home/kongxiao0532/blue.bmp";
    public static final int FIELD_COUNT = 8;

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
        /* get file inputstream */
        InputStream fileIn = new FileInputStream(inputFileName);
        try{
            System.out.println("Client Socket: " + socket);
            // socket.setTcpNoDelay(true);
            /* get outputstream */
            OutputStream out = new DataOutputStream(socket.getOutputStream());
            int bufferSize = 6 + FIELD_COUNT * 2;
            byte[] buffer = new byte[bufferSize];
            int i = 0;
            while((fileIn.read(buffer, 6, bufferSize - 6))!= -1){
                // sleep
                // if(i % 30 == 0) Thread.sleep(1);
                /* prepare tcp payload */
                byte[] index = intToByteArray(i);
                byte[] type= short2byte((short)(0));
                /* arraycopy(src, srcPos, dest, destPos, length) */
                System.arraycopy(type, 0, buffer, 0, 2);
                System.arraycopy(index, 0, buffer, 2, 4);
                /* send to outputstream */
                out.write(buffer);
                // out.flush();
                /* packet counting */
                i += 1;
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
