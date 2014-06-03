package components;

import components.Ram.InvalidAddressExcption;

public class Vm {
	public Register x;
	public Register y;
	public Stack s;
	public ProgramCounter pc;
	public Ram ram;
	public boolean irq1_flag;
	public boolean irq2_flag;
	public boolean halt_flag;
	boolean jumping = false;
	public long cycles;
	public long[][] timers = new long[5][2];
	long time = 0;
	 
	public Vm(int memory_size){
		x = new Register();
		y = new Register();
		pc = new ProgramCounter();
		ram = new Ram(memory_size);
		s = new Stack(100);
		irq1_flag = false;
		irq2_flag = false;
		halt_flag = true;
		cycles = 0;
		timers[0][1] =1;
		timers[1][1] =1;
		timers[2][1] =1;
		timers[3][1] =1;
		timers[4][1] =1;
		
	} 
	
	public void step() throws Exception{
		int instruction =-1;
		try {
			instruction = ram.read(pc.getAddress());
		} catch (Exception e) {
			e.printStackTrace();
			halt_flag = true;
			return;
		}
		
		int[] digits = instructionBreakdown(instruction);
		boolean non_reg_type = nonReg(instruction);
		int read_digit = digits[0];
		int write_digit = digits[1];
		jumping = false;
		
		if(irq1_flag){
			pc.interrupt1();
			irq1_flag = false;
			return;
			}
		if(irq2_flag){
			pc.interrupt2();
			irq2_flag = false;
			return;
			}
		
		if(!halt_flag){
			switch (getType(instruction)) {
			case NOP:
				break;
				
			case MOVE:
				time = System.nanoTime();
				try {
					move(read_digit, write_digit);
				} catch (Exception e) {
					halt_flag = true;
					e.printStackTrace();
				}
				timers[0][0] += System.nanoTime() -time;
				timers[0][1] ++;
				
				break;
	
			case ARITHMETIC:
				time = System.nanoTime();
				try {
					arithmetic(write_digit, read_digit, digits[2]);
				}catch (Exception e){
					halt_flag = true;
					throw new Exception(e.getMessage());
				}
				timers[1][0] += System.nanoTime() -time;
				timers[1][1] ++;
				break;
				
			case LOGICAL:
				time = System.nanoTime();
				try {
					logical(write_digit, read_digit, digits[3]);
				} catch (Exception e) {
					halt_flag = true;
					throw new Exception(e.getMessage());
				}
				timers[2][0] += System.nanoTime() -time;
				timers[2][1] ++;
				break;
			
			case JUMP:
				time = System.nanoTime();
				try {
					jump(write_digit, read_digit, digits[4], non_reg_type);
				} catch (Exception e) {
					halt_flag = true;
					throw new Exception(e.getMessage());
				}
				timers[3][0] += System.nanoTime() -time;
				timers[3][1] ++;
				break;
			
			case SPECIAL:
				time = System.nanoTime();
				try {
					special(digits[5]);
				} catch (Exception e) {
					halt_flag = true;
					throw new Exception(e.getMessage());
				}
				timers[4][0] += System.nanoTime() -time;
				timers[4][1] ++;
				
				break;
			
			default:
				break;
			}
			if(!jumping && !halt_flag){
				if (non_reg_type) {
					pc.increment(2);
				}else{
					pc.increment(1);
				}
			}
			cycles++;
		}

	}
	
	private boolean nonReg(int instruction) throws Exception{
		int[] digits = instructionBreakdown(instruction);
		if(digits[0] == 6  || digits[0] == 5 ||digits[1] == 8
				 || digits[1] == 5){
			return true;
		}else{
			return false;
		}
					
	}
	

	
	private Types getType(int instruction) throws InvalidInstructionException{
		if(instruction == 0){
			return Types.NOP;
		}else if(instruction >= Types.MOVE.start && instruction <= Types.MOVE.end){
			return Types.MOVE;
		}else if(instruction >= Types.ARITHMETIC.start && instruction <= Types.ARITHMETIC.end){
			return Types.ARITHMETIC;
		}else if(instruction >= Types.LOGICAL.start && instruction <= Types.LOGICAL.end){
			return Types.LOGICAL;
		}else if(instruction >= Types.JUMP.start && instruction <= Types.JUMP.end){
			return Types.JUMP;
		}else if(instruction >= Types.SPECIAL.start && instruction <= Types.SPECIAL.end){
			return Types.SPECIAL;
		}
		halt_flag = true;
		throw new InvalidInstructionException("Instruction " + instruction + " can't be resolved \n"+ "At address " + pc.getAddress());
	}
	
	private void move(int read_digit,int write_digit) throws Exception{
		writeFromDigit(write_digit,readFromReadDigit(read_digit));
	}
	
	private void arithmetic(int write_digit, int read_digit, int type) throws Exception{
		switch (type) {
		case 1:
			writeFromDigit(write_digit,readFromWriteDigit(write_digit)+1);
			break;
		case 2:
			writeFromDigit(write_digit,readFromWriteDigit(write_digit)-1);
			break;
		case 3:
			s.push(readFromReadDigit(read_digit) + readFromWriteDigit(write_digit));
			break;
		case 4:
			s.push(readFromReadDigit(read_digit) - readFromWriteDigit(write_digit));
			break;
		case 5:
			s.push(readFromReadDigit(read_digit) * readFromWriteDigit(write_digit));
			break;
		case 6:
			s.push(readFromReadDigit(read_digit) / readFromWriteDigit(write_digit));
			break;
		case 7:
			s.push(readFromReadDigit(read_digit) % readFromWriteDigit(write_digit));
			break;

		default:
			halt_flag = true;
			throw new InvalidInstructionException("Invalid arithmetic digit: " + type);
		}
	}
	
	private void logical(int write_digit, int read_digit, int type) throws Exception{
		switch (type) {
		case 1:
			if(readFromWriteDigit(write_digit) == readFromReadDigit(read_digit)){
				s.push(1);
			}else{
				s.push(0);
			}
			break;
			
		case 2:
			if(readFromReadDigit(read_digit) < readFromWriteDigit(write_digit)){
				s.push(1);
			}else{
				s.push(0);
			}
			break;

		case 3:
			if(readFromReadDigit(read_digit) > readFromWriteDigit(write_digit) ){
				s.push(1);
			}else{
				s.push(0);
			}
			break;
			
		case 4:
			s.push(readFromWriteDigit(write_digit)*10 );
			break;
			
		case 5:
			s.push(readFromWriteDigit(write_digit)/10 );
			break;
			
		case 6:
			s.push(readFromReadDigit(read_digit) & readFromWriteDigit(write_digit));
			break;
			
		case 7:
			s.push(readFromReadDigit(read_digit) | readFromWriteDigit(write_digit));
			break;
			
		case 8:
			s.push(readFromReadDigit(read_digit) ^ readFromWriteDigit(write_digit));
			break;
			
		case 9:
			s.push(~readFromWriteDigit(write_digit));
			break;
		
		default:
			halt_flag = true;
			throw new InvalidInstructionException("Invalid logic digit: " + type);
		}
	}

	
	private void jump(int write_digit, int read_digit, int type,boolean non_reg_type) throws Exception{
		switch (type) {
		case 1:
			pc.jump(readFromWriteDigit(write_digit));
			jumping = true;
			break;
		case 2:
			if(readFromWriteDigit(write_digit) == readFromReadDigit(read_digit)){
				int next_instruction;
				if(non_reg_type){
					next_instruction = ram.read(pc.getAddress()+2);
				}else{
					next_instruction = ram.read(pc.getAddress()+1);
				}
				if(nonReg(next_instruction)){
					pc.increment(2);
				}else{
					pc.increment(1);
				}
			}
			break;
		case 3:
			if(readFromReadDigit(read_digit) < readFromWriteDigit(write_digit)){
				int next_instruction;
				if(non_reg_type){
						next_instruction = ram.read(pc.getAddress()+2);
				}else{
					next_instruction = ram.read(pc.getAddress()+1);
				}
				if(nonReg(next_instruction)){
					pc.increment(2);
				}else{
					pc.increment(1);
				}
			}
			break;
		case 4:
			if(readFromReadDigit(read_digit) > readFromWriteDigit(write_digit)){
				int next_instruction;
				if(non_reg_type){
						next_instruction = ram.read(pc.getAddress()+2);
				}else{
					next_instruction = ram.read(pc.getAddress()+1);
				}
				if(nonReg(next_instruction)){
					pc.increment(2);
				}else{
					pc.increment(1);
				}
			}
			break;
		case 5:
			pc.subroutineJump(readFromWriteDigit(write_digit), non_reg_type);
			jumping = true;
			break;
		case 6:
			pc.returnJump();
			jumping = true;
			break;
			
		default:
			halt_flag = true;
			throw new InvalidInstructionException("Invalid jump digit: " + type);
		}
	}
	
	private void special(int type) throws Exception{
		switch (type) {
		case 1:
			halt_flag = true;
			break;
			
		case 2:
			if(s.isEmpty()){
				s.push(1);
			}else{
				s.push(0);
			}
			
		default:
			halt_flag = true;
			throw new InvalidInstructionException("Invalid special digit: " + type);
		}
	}
	
	
	private int readFromReadDigit(int d) throws Exception{
		switch (d) {
		case 0:
			return x.read();
			
		case 1:
			return y.read();
			
		case 2:
			try {
				return s.pop();
			} catch (Exception e) {
				throw new Exception("Tried to pop a empty data stack.");
			}
			
			
		case 3:
			return ram.read(x.read());
			
		case 4:
			return ram.read(y.read());
			
		case 5:
			
			return ram.read(ram.read(pc.getAddress()+1));
			
		case 6:
			return ram.read(pc.getAddress()+1);

		default:
			halt_flag = true;
			throw new InvalidInstructionException("Invalid read digit: " + d);
		}
	}
	
	private int readFromWriteDigit(int d) throws Exception{
		switch (d) {
		case 0:
			return x.read();
			
		case 1:
			return y.read();
			
		case 2:
			return s.pop();
			
		case 3:
			return ram.read(x.read());
			
		case 4:
			return ram.read(y.read());
			
		case 5:
			return ram.read(ram.read(pc.getAddress()+1));
			
		case 8:
			return ram.read(pc.getAddress()+1);

		default:
			halt_flag = true;
			throw new InvalidInstructionException("Invalid write digit (for reading): " + d);
		}
	}
	
	private void writeFromDigit(int d,int n) throws Exception{
		switch (d) {
		case 0:
			x.write(n);
			break;
			
		case 1:
			y.write(n);
			break;
			
		case 2:
			s.push(n);
			break;
			
		case 3:
			ram.write(n, x.read());
			break;
			
		case 4:
			ram.write(n, y.read());
			break;
			
		case 5:
			ram.write(n, ram.read(pc.getAddress()+1));
			break;
			
		case 6:
			pc.setIRQ1(n);
			break;
			
		case 7:
			pc.setIRQ2(n);
			break;

		default:
			halt_flag = true;
			throw new InvalidInstructionException("Invalid write digit (for reading): " + d);
		}
	}
	
	public class InvalidInstructionException extends Exception{
		public InvalidInstructionException(){super();}
		public InvalidInstructionException(String message){super(message);}
	}
	
	
	
	
	public enum Types {
		NOP(0,0), MOVE(1,76), ARITHMETIC(100,786), LOGICAL(1000,9076), JUMP(10000,70000), SPECIAL(100000,200000);
		final int start;
		final int end;
		Types(int start, int end){
			this.start = start;
			this.end = end;
		}
	}
	
	public void print() throws InvalidAddressExcption{
		String s;

			s = ""
					+ "Address Pointer: " + pc.getAddress()+"\n"
					+ "Current instruction: " + ram.read(pc.getAddress()) +"\n"
					+ "Register X: " + x.read()+"\n"
					+ "Register Y: " + y.read()+"\n"
					+ "::::STACK::::"+"\n";

		int[] stack = this.s.toArray();
		for (int i = stack.length-1; i >= 0; i--) {
			s += stack[i] + "\n";
		}
		s +=  ":::::::::::::"+"\n";
		
		System.out.println(s);
	}
	
	static int[] instructionBreakdown(int instruction){
		int[] ret = new int[6];
		ret[0] = instruction - ((instruction/(10)*10));
		ret[1] = ((instruction/(10)))     - ((instruction/(100)*10));
		ret[2] = ((instruction/(100)))    - ((instruction/(1000)*10));
		ret[3] = ((instruction/(1000)))   - ((instruction/(10000)*10));
		ret[4] = ((instruction/(10000)))  - ((instruction/(100000)*10));
		ret[5] = ((instruction/(100000))) - ((instruction/(1000000)*10));
		return ret;
	}
	
	
}
