package components;

public class Ram {
	int[] ram;
	
	public Ram(int size){
		ram = new int[size];
	}
	
	public void write(int n, int addr) throws InvalidAddressExcption{
		if(addr < 0 || addr >= ram.length){throw new InvalidAddressExcption("Address " + addr + "is not cool.");}
		ram[addr] = n;
	}
	
	public int read(int addr) throws InvalidAddressExcption{
		if(addr < 0 || addr >= ram.length){throw new InvalidAddressExcption("Address " + addr + "is not cool.");}
		return ram[addr];
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

	class InvalidAddressExcption extends Exception{
		public InvalidAddressExcption(){super();}
		public InvalidAddressExcption(String message){super(message);}
	}
	
}
