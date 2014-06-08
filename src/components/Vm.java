package components;

import components.Ram.InvalidAddressExcption;
import components.Stack.StackEmptyException;

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
	int a1_code;
	int a2_code;
	int action;
	int operation;
	int a1;
	int a2;
	int a1_is_non_reg;
	int a2_is_non_reg;
	int increment_offset;
	final boolean DBG = true;

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
		timers[0][1] = 1;
		timers[1][1] = 1;
		timers[2][1] = 1;
		timers[3][1] = 1;
		timers[4][1] = 1;

	}

	public void step() throws Exception {
		if (halt_flag) {
			return;
		}
		int instruction = -1;
		try {
			instruction = ram.read(pc.getAddress());
		} catch (Exception e) {
			e.printStackTrace();
			halt_flag = true;
			return;
		}

		instructionBreakdown(instruction);

		resolveArguments();

		increment_offset = 1 + a1_is_non_reg + a2_is_non_reg;

		jumping = false;
		
		dbg("Instruction: " + Integer.toHexString(instruction)+ "\n"
				+ "Action: " + Integer.toHexString(action) + " Operation: " + Integer.toHexString(operation)
				+ " a1(code): " +Integer.toHexString(a1_code)+ " a2(code): " +Integer.toHexString(a2_code) +"\n"
				+ "a1: " + Integer.toHexString(a1) + " a2: " + Integer.toHexString(a2));
		
		if (!(action == 0 && operation == 0)) {
			// EXECUTE GOES HERE
			// Move is a bit special so it has its own thingy.
			if (action == 0xb && operation == 0) {
				executeMove();
				dbg("Executing Move.");
			} else if (action == 0 && operation != 0) {
				executeOperation();
				dbg("Executing Operation.");
			} else if (action != 0 && operation == 0) {
				executeAction();
				dbg("Executing Action.");
			}

		}

		if (!jumping) {
			pc.increment(increment_offset);
		}
		cycles++;
		dbg("\n");
	}

	private void resolveArguments() throws InvalidAddressExcption,
			StackEmptyException {
		if ((a1_code & 0b1000) == 0) {

			switch (a1_code & 0b0011) {
			case 0:
				a1 = s.pop();
				a1_is_non_reg = 0;
				break;
			case 1:
				a1 = x.read();
				a1_is_non_reg = 0;
				break;
			case 2:
				a1 = y.read();
				a1_is_non_reg = 0;
				break;
			case 3:
				a1 = ram.read(pc.getAddress() + 1);
				a1_is_non_reg = 1;
				break;

			default:
				break;
			}

			if ((a1_code & 0b0100) != 0) {
				a1 = ram.read(a1);
			}
		}

		if ((a2_code & 0b1000) == 0) {

			switch (a2_code & 0b0011) {
			case 0:
				a2 = s.pop();
				a2_is_non_reg = 0;
				break;
			case 1:
				a2 = x.read();
				a2_is_non_reg = 0;
				break;
			case 2:
				a2 = y.read();
				a2_is_non_reg = 0;
				break;
			case 3:
				a2 = ram.read(pc.getAddress() + 1 + a1_is_non_reg);
				a2_is_non_reg = 1;
				break;

			default:
				break;
			}

			if ((a2_code & 0b0100) != 0) {
				a2 = ram.read(a2);
			}
		}
	}

	private void executeMove() throws InvalidAddressExcption {

		if ((a2_code & 0b1000) == 0) {

			switch (a2_code & 0b0011) {
			case 0:
				s.push(a1);
				break;
			case 1:
				x.write(a1);
				break;
			case 2:
				y.write(a1);

				break;
			case 3:
				ram.write(a1, pc.getAddress() + 1 + a1_is_non_reg);
				break;

			default:
				break;
			}

			if ((a2_code & 0b0100) != 0) {
				ram.write(a1, a2);
			}
		}

	}

	private void executeOperation() throws InvalidAddressExcption,
			StackEmptyException, InvalidInstructionException {
		switch (operation) {
		case 1:
			if ((a1_code & 0b0100) != 0) {
				throw new InvalidInstructionException(
						"Impropper argument given to INC instruction: "
								+ Integer.toHexString(a1_code));
			}
			switch (a1_code & 0b0011) {
			case 0:
				s.push(s.pop() + 1);
				break;
			case 1:
				x.inc();

				break;
			case 2:
				y.inc();
				break;

			default:
				throw new InvalidInstructionException(
						"Impropper argument given to INC instruction: "
								+ Integer.toHexString(a1_code));
			}
			break;
		case 2:
			if ((a1_code & 0b0100) != 0) {
				throw new InvalidInstructionException(
						"Impropper argument given to DEC instruction: "
								+ Integer.toHexString(a1_code));
			}
			switch (a1_code & 0b0011) {
			case 0:
				s.push(s.pop() - 1);
				break;
			case 1:
				x.dec();

				break;
			case 2:
				y.dec();
				break;

			default:
				throw new InvalidInstructionException(
						"Impropper argument given to DEC instruction: "
								+ Integer.toHexString(a1_code));
			}
			break;
		case 3:
			s.push(a1 + a2);
			break;
		case 4:
			s.push(a1 - a2);
			break;
		case 5:
			s.push(a1 * a2);
			break;
		case 6:
			s.push(a1 / a2);
			break;
		case 7:
			s.push(a1 % a2);
		case 8:
			if (a1 == a2) {
				s.push(1);
			} else {
				s.push(0);
			}
			break;
		case 9:
			if (a1 > a2) {
				s.push(1);
			} else {
				s.push(0);
			}
			break;
		case 10:
			if (a1 < a2) {
				s.push(1);
			} else {
				s.push(0);
			}
			break;
		case 11:
			s.push(a1 & a2);
			break;
		case 12:
			s.push(a1 | a2);
			break;
		case 13:
			s.push(a1 ^ a2);
			break;
		case 14:
			s.push(~a1);
			break;
		case 15:
			if (a2 > 0) {
				s.push(a1 << a2);
			} else {
				s.push(a1 >> (-a2));
			}
		default:
			break;
		}
	}

	private void executeAction() throws StackEmptyException,
			InvalidAddressExcption, InvalidInstructionException {
		switch (action) {
		case 1:
			jumping = true;
			pc.jump(a1);
			break;
		case 2:
			jumping = true;
			pc.subroutineJump(a1, pc.getAddress() + increment_offset);
			break;
		case 3:
			jumping = true;
			pc.returnJump();
		case 4:
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
				pc.jump(increment_offset + skip_distance);
			}
			break;
		case 5:
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
				pc.jump(increment_offset + skip_distance);
			}
			break;
		case 6:
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
				pc.jump(increment_offset + skip_distance);
			}
			break;
		case 7:
			if (s.pop() == 1) {
				jumping = true;
				pc.jump(a1);
			}
			break;
		case 8:
			if (s.pop() == 0) {
				jumping = true;
				pc.jump(a1);
			}
			break;
		case 9:
			if (s.pop() == 1) {
				jumping = true;
				pc.subroutineJump(a1, pc.getAddress() + increment_offset);
			}
			break;
		case 10:
			if (s.pop() == 0) {
				jumping = true;
				pc.subroutineJump(a1, pc.getAddress() + increment_offset);
			}
			break;
		case 11:
			halt_flag = true;
			break;
		default:
			throw new InvalidInstructionException(
					"Something odd happened while executing an action");
		}
	}

	public class InvalidInstructionException extends Exception {
		public InvalidInstructionException() {
			super();
		}

		public InvalidInstructionException(String message) {
			super(message);
		}
	}

	public void dbg(String message) {
		if(DBG){
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
