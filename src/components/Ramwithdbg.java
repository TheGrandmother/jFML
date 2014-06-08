package components;

public class Ramwithdbg {
	int[] ram;
	
	static int shared_start = 70000;
	static int page_index = 90002;
	static int page_size = 1000;
	static int page_enable = 90003;
	public static int timer_address =90004;
	
	public Ramwithdbg(int size){
		ram = new int[size];
	}
	
	public void write(int n, int addr) throws InvalidAddressExcption{
		if(resolvePA(addr) < 0 || resolvePA(addr) >= ram.length){throw new InvalidAddressExcption("Address " + resolvePA(addr) + "is not cool.");}
		ram[resolvePA(addr)] = n;
	}
	
	public int read(int addr) throws InvalidAddressExcption{
		if(resolvePA(addr) < 0 || resolvePA(addr) >= ram.length){throw new InvalidAddressExcption("Address " + resolvePA(addr) + "is not cool.");}
		return ram[resolvePA(addr)];
	}
	
	public void writeChunk(int[] data, int addr) throws InvalidAddressExcption{
		if(addr < 0 || addr >= ram.length){throw new InvalidAddressExcption("Address " + addr + "is not cool.");}
		if(addr+data.length >= ram.length){throw new InvalidAddressExcption("Cant write data to " + addr + " there is not enough\n"
				+ "memory avliable.");}
		for (int i = 0; i < data.length; i++) {
			ram[addr+i] = data[i];
		}

	}
	
	public int[] readChunk(int addr, int length) throws InvalidAddressExcption{
		if(addr < 0 || addr >= ram.length){throw new InvalidAddressExcption("Address " + addr + "is not cool.");}
		if(addr+length >= ram.length){throw new InvalidAddressExcption("Address + length is " + (length+addr) + " and lies "
				+ "outside of memory");}
		int[] ret = new int[length];
		for (int i = 0; i < ret.length; i++) {
			ret[i] = ram[addr+i];
		}
		return ret;
	}

	public class InvalidAddressExcption extends Exception{
		public InvalidAddressExcption(){super();}
		public InvalidAddressExcption(String message){super(message);}
	}
	
	public void dumpRam(){
		String s = "";
		int i = 0;
		while(i < ram.length){
			s += i +":::";
			for (int j = 0; j < 10; j++) {
				s += ram[i+j] + ":";  
			}
			s += "\n";
			i += 10;
		}
		if( i != ram.length){
			s += i +"::: ";
			for (int j = i; j < ram.length; j++) {
				s += ram[j] + ":";
			}
			s += "\n";
		}
		System.out.println(s);
	}
	
	public void dumpRam(int start, int end) throws InvalidAddressExcption{
		if(end > ram.length){throw new InvalidAddressExcption("Ending adress is outside of the ram.");}
		String s = "";
		int i = start;
		
		while(i < end){
			s += i +":::";
			for (int j = 0; j < 10; j++) {
				s += ram[i+j] + ":";  
			}
			s += "\n";
			i += 10;
		}
		if( i != end){
			s += i +"::: ";
			for (int j = i; j < ram.length; j++) {
				s += ram[j] + ":";
			}
			s += "\n";
		}
		System.out.println(s);
	}
	
	public String toString(int start, int end,int cells_per_line) throws InvalidAddressExcption{
		if(end > ram.length){throw new InvalidAddressExcption("Ending adress is outside of the ram.");}
		String s = "";
		int i = start;
		
		while(i < end){
			s += i +":::";
			for (int j = 0; j < cells_per_line; j++) {
				s += ram[i+j] + ":";  
			}
			s += "\n";
			i += cells_per_line;
		}
		if( i != end){
			s += i +"::: ";
			for (int j = i; j < ram.length; j++) {
				s += ram[j] + ":";
			}
			s += "\n";
		}
		return s;
	}
	
	public int resolvePA(int va) throws InvalidAddressExcption{
		if(va <= shared_start && (read(page_enable)==1)){
			return va + (page_index*page_size);
		}else{
			return va;
		}
	}
	
}