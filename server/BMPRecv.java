import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.io.OutputStream;
public class BMPRecv{
    public static byte[] short2byte(short s){
		byte[] res = new byte[2];
		res[1] = (byte)((s & 0xFF));
		res[0] = (byte)(((s >> 8) & 0xFF));
		return res;
	}
    public static void main(String[] args)throws IOException,InterruptedException {
        InetAddress bindIP = InetAddress.getByName("10.0.0.3");
        DatagramSocket socket = new DatagramSocket(20001,bindIP);
        int file_size = 80454;
        byte[] image = new byte[file_size];
        int field_count = Integer.parseInt(args[0]);
		byte[] buf = new byte[6+2*field_count];
		DatagramPacket packet = new DatagramPacket(buf,buf.length);
        int count = 0;
        int pos = 0;
		while(pos < file_size){

            socket.receive(packet);
            try{
                byte[] bytes = packet.getData();
                if(pos + field_count * 2 > file_size){
                    System.arraycopy(bytes, 6, image, pos, file_size - pos); 
                }
                else{
                    System.arraycopy(bytes, 6, image, pos, field_count * 2); 
                }
                pos += field_count * 2;
                System.out.println(pos);

            }catch(Exception e){
                e.printStackTrace();
            }
        } 
        try{
            OutputStream out = new FileOutputStream("recon3.bmp");
            out.write(image);
            out.flush();
            out.close();
        }catch(Exception e){
            e.printStackTrace();
        }
    }
}
