package components;

import components.Ram.InvalidAddressExcption;
import components.Stack.StackEmptyException;

/**
 * This is the class for the actual VM. It is here where all the magic happens.
 * 
 * @author TheGrandmother
 * 
 */
public class Vm {
	public Register x;
	public Register y;
	public Stack s;
	public ProgramCounter pc;
	public Ram ram;
	public boolean irq1_flag;
	public boolean irq2_flag;
	public boolean halt_flag;
	/**
	 * This field is necessary for the VM to keep track of weather or not it is executing a instruction which jumps.
	 * Since if the machine jumps the step() method must not increment the program counter on its own.
	 */
	boolean jumping = false;
	public long cycles;
	public long[][] timers = new long[5][2];
	long time = 0;
	long wierd_time = 0;
	int a1_code;
	int a2_code;
	int action;
	int operation;
	int a1;
	int a2;
	
	/**
	 * This field keeps track of how much the step() method must increment the PC to get the 
	 * correct address for the next instruction. 
	 */
	int increment_offset;
	
	final boolean debug_flag = false;

	public Vm(int memory_size) {
		x = new Register();
		y = new Register();
		pc = new ProgramCounter();
		ram = new Ram(memory_size);
		s = new Stack(100);
		irq1_flag = false;
		irq2_flag = false;
		halt_flag = true;
		cycles = 0;
		for (int i = 0; i < timers.length; i++) {
			timers[i][1] = 0;
		}

	}

	/**
	 * When this method is called the VM executes one step.
	 * 
	 * 
	 * @throws Exception
	 */
	public void step() throws Exception {
		// All the debug timers are commented out due to performance reasons.
		// wierd_time = System.nanoTime();
		if (halt_flag) {
			return;
		}
		// time = System.nanoTime();
		int instruction = -1;
		try {
			instruction = ram.read(pc.getAddress());
		} catch (Exception e) {
			e.printStackTrace();
			halt_flag = true;
			return;
		}
		// timers[3][0] += System.nanoTime()-time;
		// timers[3][1]++;
		//
		// time = System.nanoTime();
		instructionBreakdown(instruction);
		// timers[2][0] += System.nanoTime()-time;
		// timers[2][1]++;

		increment_offset = 1;

		jumping = false;

		// dbg("Instruction: " + Integer.toHexString(instruction)+ "\n"
		// + "Action: " + Integer.toHexString(action) + " Operation: " +
		// Integer.toHexString(operation)
		// + " a1(code): " +Integer.toHexString(a1_code)+ " a2(code): "
		// +Integer.toHexString(a2_code) +"\n");

		if (!(action == 0 && operation == 0)) {
			if (action == 0 && operation != 0) {
				// time = System.nanoTime();
				executeOperation();
				// timers[0][0] += System.nanoTime()-time;
				// timers[0][1]++;
				// dbg("Executing Operation.");
			} else if (action != 0 && operation == 0) {
				// time = System.nanoTime();
				executeAction();
				// timers[1][0] += System.nanoTime()-time;
				// timers[1][1]++;
				// dbg("Executing Action.");
			}

		}
		// dbg("Increment offsett: " + increment_offset);

		if (!jumping) {
			pc.increment(increment_offset);
		}

		cycles++;
		// dbg("\n");
		// timers[4][0] += System.nanoTime()-wierd_time;
		// timers[4][1]++;
	}

	/**
	 * Resolves the first argument
	 * 
	 * If both arguments are used A1 needs to be resolved first. this is so that
	 * the top of the stack will be the first argument and the second argument
	 * will be the second entry in the stack when using the stack as both
	 * arguments
	 * 
	 * @throws InvalidAddressExcption
	 * @throws StackEmptyException
	 */
	void resolveA1() throws InvalidAddressExcption, StackEmptyException {
		if ((a1_code & 0b1000) == 0) {

			switch (a1_code & 0b0011) {
			case 0:
				a1 = s.pop();

				break;
			case 1:
				a1 = x.read();

				break;
			case 2:
				a1 = y.read();

				break;
			case 3:
				a1 = ram.read(pc.getAddress() + 1);
				increment_offset += 1;
				break;

			default:
				break;
			}

			if ((a1_code & 0b0100) != 0) {
				a1 = ram.read(a1);
			}
		}
	}

	/**
	 * Resolves the second argument
	 * 
	 * Should be called after resolveA1() if both arguments are used.
	 * 
	 * @throws InvalidAddressExcption
	 * @throws StackEmptyException
	 */
	void resolveA2() throws InvalidAddressExcption, StackEmptyException {
		if ((a2_code & 0b1000) == 0) {

			switch (a2_code & 0b0011) {
			case 0:
				a2 = s.pop();

				break;
			case 1:
				a2 = x.read();

				break;
			case 2:
				a2 = y.read();

				break;
			case 3:
				a2 = ram.read(pc.getAddress() + increment_offset);
				increment_offset += 1;

				break;

			default:
				break;
			}

			if ((a2_code & 0b0100) != 0) {
				a2 = ram.read(a2);
			}
		}
	}

	/**
	 * This method executes Operation type instructions.
	 * 
	 * @throws InvalidAddressExcption
	 * @throws StackEmptyException
	 * @throws InvalidInstructionException
	 */
	private void executeOperation() throws InvalidAddressExcption,
			StackEmptyException, InvalidInstructionException {
		int tmp_addr;
		int tmp;
		
		switch (operation) {
		// INC
		case 1:
			if ((a1_code & 0b1000) != 0 || (a1_code == 0b0011)) {
				throw new InvalidInstructionException(
						"Impropper argument given to INC instruction: "
								+ Integer.toHexString(a1_code));
			}
			switch (a1_code & 0b0111) {

			case 0:
				s.push(s.pop() + 1);
				break;
			case 1:
				x.inc();

				break;
			case 2:
				y.inc();
				break;
			case 4:
				tmp_addr = s.pop();
				tmp = ram.read(s.pop());
				ram.write(tmp+1,tmp_addr);
				
				break;
			case 5:
				tmp = ram.read(x.read());
				ram.write(tmp+1, x.read());
				break;
			case 6:
				tmp = ram.read(y.read());
				ram.write(tmp+1, y.read());
				break;
			case 7:
				tmp = ram.read(ram.read(pc.getAddress() + 1));
				ram.write(tmp+1, ram.read(pc.getAddress() + 1));
				increment_offset += 1;
				break;
			

			default:
				throw new InvalidInstructionException(
						"Impropper argument given to INC instruction: "
								+ Integer.toHexString(a1_code));
			}
			break;
		// DEC
		case 2:
			if ((a1_code & 0b1000) != 0|| (a1_code == 0b0011)) {
				throw new InvalidInstructionException(
						"Impropper argument given to DEC instruction: "
								+ Integer.toHexString(a1_code));
			}
			switch (a1_code & 0b0111) {
			case 0:
				s.push(s.pop() - 1);
				break;
			case 1:
				x.dec();

				break;
			case 2:
				y.dec();
				break;
			case 4:
				tmp_addr = s.pop();
				tmp = ram.read(s.pop());
				ram.write(tmp-1,tmp_addr);
				
				break;
			case 5:
				tmp = ram.read(x.read());
				ram.write(tmp-1, x.read());
				break;
			case 6:
				tmp = ram.read(y.read());
				ram.write(tmp-1, y.read());
				break;
			case 7:
				tmp = ram.read(ram.read(pc.getAddress() + 1));
				ram.write(tmp-1, ram.read(pc.getAddress() + 1));
				increment_offset += 1;
				break;

			default:
				throw new InvalidInstructionException(
						"Impropper argument given to DEC instruction: "
								+ Integer.toHexString(a1_code));
			}
			break;
		// ADD
		case 3:
			resolveA1();
			resolveA2();
			s.push(a1 + a2);
			break;
		// SUB
		case 4:
			resolveA1();
			resolveA2();
			s.push(a1 - a2);
			break;
		// MUL
		case 5:
			resolveA1();
			resolveA2();
			s.push(a1 * a2);
			break;
		// DIV
		case 6:
			resolveA1();
			resolveA2();
			s.push(a1 / a2);
			break;
		// MOD
		case 7:
			resolveA1();
			resolveA2();
			s.push(a1 % a2);
			break;
		// EQL
		case 8:
			resolveA1();
			resolveA2();
			if (a1 == a2) {
				s.push(1);
			} else {
				s.push(0);
			}
			break;
		// GRT
		case 9:
			resolveA1();
			resolveA2();
			if (a1 > a2) {
				s.push(1);
			} else {
				s.push(0);
			}
			break;
		// LES
		case 0xA:
			resolveA1();
			resolveA2();
			if (a1 < a2) {
				s.push(1);
			} else {
				s.push(0);
			}
			break;
		// AND
		case 0xB:
			resolveA1();
			resolveA2();
			s.push(a1 & a2);
			break;
		// OOR
		case 0xC:
			resolveA1();
			resolveA2();
			s.push(a1 | a2);
			break;
		// XOR
		case 0xD:
			resolveA1();
			resolveA2();
			s.push(a1 ^ a2);
			break;
		// NOT
		case 0xE:
			resolveA1();
			s.push(~a1);
			break;
		// SFT
		case 0xF:
			resolveA1();
			resolveA2();
			if (a2 > 0) {
				s.push(a1 << a2);
			} else {
				s.push(a1 >> (-a2));
			}
			break;
		default:
			break;
		}
	}
	
	/**
	 * This method handles the execution of Action type instructions 
	 * @throws StackEmptyException
	 * @throws InvalidAddressExcption
	 * @throws InvalidInstructionException
	 */
	private void executeAction() throws StackEmptyException,
			InvalidAddressExcption, InvalidInstructionException {

		switch (action) {
		// JMP
		case 1:
			resolveA1();
			jumping = true;
			pc.jump(a1);
			break;
			
		// JSR
		case 2:
			resolveA1();
			jumping = true;
			pc.subroutineJump(a1, pc.getAddress() + increment_offset);
			break;
			
		// RET
		case 3:
			jumping = true;
			pc.returnJump();
			break;
			
		// SEQ
		case 4:
			resolveA1();
			resolveA2();
			if (a1 == a2) {
				jumping = true;
				int next_instruction = ram.read(pc.getAddress()
						+ increment_offset);
				int skip_distance = 1;
				if ((next_instruction & 0b0000_0000_0000_1011) == 0b0011) {
					skip_distance++;
				}
				if ((next_instruction & 0b0000_0000_1011_0000) == 0b0011_0000) {
					skip_distance++;
				}
				pc.jump(pc.getAddress() + increment_offset + skip_distance);
			}
			break;

		// SGR
		case 5:
			resolveA1();
			resolveA2();
			if (a1 > a2) {
				jumping = true;
				int next_instruction = ram.read(pc.getAddress()
						+ increment_offset);
				int skip_distance = 1;
				if ((next_instruction & 0b0000_0000_0000_1011) == 0b0011) {
					skip_distance++;
				}
				if ((next_instruction & 0b0000_0000_1011_0000) == 0b0011_0000) {
					skip_distance++;
				}
				pc.jump(pc.getAddress() + increment_offset + skip_distance);
			}
			break;

		// SLE
		case 6:
			resolveA1();
			resolveA2();
			if (a1 < a2) {
				jumping = true;
				int next_instruction = ram.read(pc.getAddress()
						+ increment_offset);
				int skip_distance = 1;
				if ((next_instruction & 0b0000_0000_0000_1011) == 0b0011) {
					skip_distance++;
				}
				if ((next_instruction & 0b0000_0000_1011_0000) == 0b0011_0000) {
					skip_distance++;
				}
				pc.jump(pc.getAddress() + increment_offset + skip_distance);
			}
			break;
			
		// JOO
		case 7:
			resolveA1();
			if (s.pop() == 1) {
				jumping = true;
				pc.jump(a1);
			}
			break;

		//JOZ
		case 8:
			resolveA1();
			if (s.pop() == 0) {
				jumping = true;
				pc.jump(a1);
			}
			break;
		
		//SOO
		case 9:
			resolveA1();
			if (s.pop() == 1) {
				jumping = true;
				pc.subroutineJump(a1, pc.getAddress() + increment_offset);
			}
			break;
		
		//SOZ
		case 0xA:
			resolveA1();
			if (s.pop() == 0) {
				jumping = true;
				pc.subroutineJump(a1, pc.getAddress() + increment_offset);
			}
			break;
			
		//HLT
		case 0xB:
			halt_flag = true;
			break;
			
		//MOV
		case 0xC:

			resolveA1();
			if (a2_code == 0b0000) {
				s.push(a1);
			} else if (a2_code == 0b0001) {
				x.write(a1);
			} else if (a2_code == 0b0010) {
				y.write(a1);
			} else if (a2_code == 0b0100) {
				ram.write(a1, s.pop());
			} else if (a2_code == 0b0101) {
				ram.write(a1, x.read());
			} else if (a2_code == 0b0110) {
				ram.write(a1, y.read());
			} else if (a2_code == 0b0111) {
				increment_offset++;
				ram.write(a1, ram.read(pc.getAddress() + increment_offset - 1));
			} else {

				throw new InvalidInstructionException(
						"Invalid destination for move operation.");
			}
			break;
		default:
			throw new InvalidInstructionException(
					"Something odd happened while executing an action");
		}
	}

	@SuppressWarnings("serial")
	public class InvalidInstructionException extends Exception {
		public InvalidInstructionException() {
			super();
		}

		public InvalidInstructionException(String message) {
			super(message);
		}
	}

	public void dbg(String message) {
		if (debug_flag) {
			System.out.println(message);
		}
	}

	public void print() throws InvalidAddressExcption {
		String s;

		s = "" + "Address Pointer: " + pc.getAddress() + "\n"
				+ "Current instruction: " + ram.read(pc.getAddress()) + "\n"
				+ "Register X: " + x.read() + "\n" + "Register Y: " + y.read()
				+ "\n" + "::::STACK::::" + "\n";

		int[] stack = this.s.toArray();
		for (int i = stack.length - 1; i >= 0; i--) {
			s += stack[i] + "\n";
		}
		s += ":::::::::::::" + "\n";

		System.out.println(s);
	}

	public void instructionBreakdown(int instruction) {
		a1_code = instruction & 0x000F;
		a2_code = (instruction & 0x00F0) >> 4;
		operation = (instruction & 0x0F00) >> 8;
		action = (instruction & 0xF000) >> 12;
	}

}
