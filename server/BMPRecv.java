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
        InetAddress bindIP = InetAddress.getByName(args[0]);
        DatagramSocket socket = new DatagramSocket(20001,bindIP);

        byte[] image = new byte[998574];

		byte[] buf = new byte[34];
		DatagramPacket packet = new DatagramPacket(buf,buf.length);
        int count = 0;
        int pos = 0;
		while(count < 31206){
            socket.receive(packet);
            count++;
            try{
                byte[] bytes = packet.getData();
                if(bytes.length < 34) break;
                System.arraycopy(bytes, 2, image, pos, 32); 
                pos += 32;
            }catch(Exception e){
                e.printStackTrace();
            }
            count++;
			//System.out.println(count);
        } 
        
        try{
            OutputStream out = new FileOutputStream("recon.bmp");
            out.write(image);
            out.flush();
            out.close();
        }catch(Exception e){
            e.printStackTrace();
        }
    }
}
