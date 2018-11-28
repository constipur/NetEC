import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;


public class BMPSend{
    public static byte[] short2byte(short s){
		byte[] res = new byte[2];
		res[1] = (byte)((s & 0xFF));
		res[0] = (byte)(((s >> 8) & 0xFF));
		return res;
	}
    public static void main(String[] args)throws IOException,InterruptedException {
        try{
            DatagramSocket socket = new DatagramSocket(20001);
            InputStream in = new FileInputStream(args[1]);
            int field_count = Integer.parseInt(args[0]);
            int buffer_size = 6 + field_count*2; 
            byte[] buffer = new byte[buffer_size];
            short i = 0;
            while((in.read(buffer, 6, buffer_size-6))!= -1){
                if(i % 30 == 0) Thread.sleep(1);
                byte[] index = short2byte(i);
                byte[] type= short2byte((short)(0));
                System.arraycopy(type,0,buffer,0,2);
                System.arraycopy(index,0,buffer,4,2);
                i += 1;
                DatagramPacket packet = new DatagramPacket(buffer,buffer_size,InetAddress.getByName("10.0.0.3"),20000);
                socket.send(packet);
            	buffer = new byte[buffer_size];
            }
            System.out.println("sent packet: " + i);
            socket.close();
            in.close();
        } catch (Exception e){
            e.printStackTrace();
        }

    }
}
