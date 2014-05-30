package components;

import components.Ram.InvalidAddressExcption;

public class Vm {
	Register x;
	Register y;
	Stack s;
	ProgramCounter pc;
	Ram ram;
	boolean irq1_flag;
	boolean irq2_flag;
	boolean halt_flag;
	
	public Vm(int memory_size){
		x = new Register();
		y = new Register();
		pc = new ProgramCounter();
		ram = new Ram(memory_size);
		s = new Stack(100);
		irq1_flag = false;
		irq2_flag = false;
		halt_flag = true;
	}
	
	public void step() throws Exception{
		int instruction = ram.read(pc.getAddress());
		int[] digits = instructionBreakdown(instruction);
		boolean non_reg_type = nonReg(instruction);
	}
	
	private boolean nonReg(int instruction) throws Exception{
		int[] digits = instructionBreakdown(instruction);
		if(digits[0] == 6 || digits[0] == 4 || digits[0] == 5 ||digits[1] == 8 ||
				digits[1] == 4 || digits[1] == 5){
			return true;
		}else{
			return false;
		}
					
	}
	
	private int[] instructionBreakdown(int instruction) throws InvalidInstructionException{
		int[] ret = new int[6];
		if(instruction < 0 || instruction > 200000){
			throw new InvalidInstructionException("Invalid instruction:" + instruction);
		}
		
		for (int i = 0; i < ret.length; i++) {
			ret[0] = ((int)(instruction/((int)Math.pow(10, i)))) - ((int)(instruction/((int)Math.pow(10, i+1))*10));
		}
		return ret;
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
		throw new InvalidInstructionException();
	}
	
	public void move(int source,int destination) throws Exception{
		writeFromDigit(destination,readFromReadDigit(source));
	}
	
	public void arithmetic(int write_digit, int read_digit, int type) throws Exception{
		switch (type) {
		case 1:
			writeFromDigit(write_digit,readFromWriteDigit(write_digit)+1);
			break;
		case 2:
			writeFromDigit(write_digit,readFromWriteDigit(write_digit)-1);
			break;
		case 3:
			s.push(readFromWriteDigit(write_digit) + readFromReadDigit(read_digit));
			break;
		case 4:
			s.push(readFromWriteDigit(write_digit) - readFromReadDigit(read_digit));
			break;
		case 5:
			s.push(readFromWriteDigit(write_digit) * readFromReadDigit(read_digit));
			break;
		case 6:
			s.push(readFromWriteDigit(write_digit) / readFromReadDigit(read_digit));
			break;
		case 7:
			s.push(readFromWriteDigit(write_digit) % readFromReadDigit(read_digit));
			break;

		default:
			throw new InvalidInstructionException("Invalid arithmetic digit: " + type);
		}
	}
	
	public void logical(int write_digit, int read_digit, int type) throws Exception{
		switch (type) {
		case 1:
			if(readFromWriteDigit(write_digit) == readFromReadDigit(read_digit)){
				s.push(1);
			}else{
				s.push(0);
			}
			break;
			
		case 2:
			if(readFromWriteDigit(write_digit) < readFromReadDigit(read_digit)){
				s.push(1);
			}else{
				s.push(0);
			}
			break;

		case 3:
			if(readFromWriteDigit(write_digit) > readFromReadDigit(read_digit)){
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
			s.push(readFromWriteDigit(write_digit) & readFromReadDigit(read_digit));
			break;
			
		case 7:
			s.push(readFromWriteDigit(write_digit) | readFromReadDigit(read_digit));
			break;
			
		case 8:
			s.push(readFromWriteDigit(write_digit) ^ readFromReadDigit(read_digit));
			break;
			
		case 9:
			s.push(~readFromWriteDigit(write_digit));
			break;
		
		default:
			throw new InvalidInstructionException("Invalid logic digit: " + type);
		}
	}

	//IN THIS FUNCTION CONFUSION IS KING!
	public void jump(int write_digit, int read_digit, int type,boolean non_reg_type) throws Exception{
		switch (type) {
		case 1:
			pc.jump(readFromReadDigit(read_digit));
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
			if(readFromWriteDigit(write_digit) < readFromReadDigit(read_digit)){
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
			if(readFromWriteDigit(write_digit) > readFromReadDigit(read_digit)){
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
			pc.subroutineJump(readFromReadDigit(read_digit), non_reg_type);
			break;
		case 6:
			pc.returnJump();
			break;
		default:
			throw new InvalidInstructionException("Invalid jump digit: " + type);
		}
	}
	
	public void special(int type) throws Exception{
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
			throw new InvalidInstructionException("Invalid special digit: " + type);
		}
	}
	
	
	public int readFromReadDigit(int d) throws Exception{
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
			
		case 6:
			return ram.read(pc.getAddress()+1);

		default:
			throw new InvalidInstructionException("Invalid read digit: " + d);
		}
	}
	
	public int readFromWriteDigit(int d) throws Exception{
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
			throw new InvalidInstructionException("Invalid write digit (for reading): " + d);
		}
	}
	
	public void writeFromDigit(int d,int n) throws Exception{
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
			throw new InvalidInstructionException("Invalid write digit (for reading): " + d);
		}
	}
	
	public class InvalidInstructionException extends Exception{
		public InvalidInstructionException(){super();}
		public InvalidInstructionException(String message){super(message);}
	}
	
	
	
	
	public enum Types {
		NOP(0,0), MOVE(1,76), ARITHMETIC(100,776), LOGICAL(1000,9076), JUMP(10000,70000), SPECIAL(100000,20000);
		final int start;
		final int end;
		Types(int start, int end){
			this.start = start;
			this.end = end;
		}
	}
	
	
}
