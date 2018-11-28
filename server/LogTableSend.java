import java.io.IOException;
import java.io.InputStream;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileInputStream;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;


public class LogTableSend{
    public static byte[] short2byte(short s){
		byte[] res = new byte[2];
		res[1] = (byte)((s & 0xFF));
		res[0] = (byte)(((s >> 8) & 0xFF));
		return res;
    }
    public static byte[] intToByteArray(int a) {   
        return new byte[] {   
                (byte) ((a >> 24) & 0xFF),   
                (byte) ((a >> 16) & 0xFF),      
                (byte) ((a >> 8) & 0xFF),      
                (byte) (a & 0xFF)   
            };   
        } 
    public static void main(String[] args)throws IOException,InterruptedException {
        try{
            DatagramSocket socket = new DatagramSocket(20001);
            BufferedReader reader = new BufferedReader(new FileReader(args[1]));
            int field_count = Integer.parseInt(args[0]);
            int buffer_size = 6 + field_count*2; 
            int line_no = 0;
            String str = null;
            byte[] buffer = new byte[buffer_size];
            while((str = reader.readLine()) != null){
                if(line_no % 10000 == 0)Thread.sleep(1);
                if(line_no < 65536){
                    byte[] key = short2byte((short)line_no);
                    byte[] value = intToByteArray(Integer.parseInt(str));
                    byte[] type = short2byte((short)1);
                    System.arraycopy(type, 0, buffer, 0, 2);
                    System.arraycopy(value, 0, buffer, 2, 4);
                    for(int j = 0;j < field_count;j++){
                        System.arraycopy(key, 0, buffer, 6+2*j, 2);
                    }
                    DatagramPacket packet = new DatagramPacket(buffer,buffer_size,InetAddress.getByName("10.0.0.3"),20000);
                    socket.send(packet);
                }else{
                    byte[] key = intToByteArray(line_no-65536);
                    byte[] value = intToByteArray(Integer.parseInt(str));
                    byte[] type = short2byte((short)2);
                    System.arraycopy(type, 0, buffer, 0, 2);
                    System.arraycopy(key, 0, buffer, 2, 4);
                    for(int j = 0;j < field_count;j++){
                        System.arraycopy(value, 2, buffer, 6+2*j, 2);
                    }
                    DatagramPacket packet = new DatagramPacket(buffer,buffer_size,InetAddress.getByName("10.0.0.3"),20000);
                    socket.send(packet);


                }
                line_no++;
            }


/*
            int field_count = Integer.parseInt(args[0]);
            int buffer_size = 2 + field_count*2; 
            byte[] buffer = new byte[buffer_size];
            short i = 0;
            while((in.read(buffer, 2, buffer_size-2))!= -1){
                if(i % 30 == 0) Thread.sleep(1);
                byte[] index = short2byte(i);
                System.arraycopy(index,0,buffer,0,2);
                i += 1;
                DatagramPacket packet = new DatagramPacket(buffer,buffer_size,InetAddress.getByName("10.0.0.3"),20000);
                socket.send(packet);
            	buffer = new byte[buffer_size];
            }
            System.out.println("sent packet: " + i);
            socket.close();
            in.close();
*/
        } catch (Exception e){
            e.printStackTrace();
        }
    }
}
