package assembler;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.sun.corba.se.spi.ior.MakeImmutable;

/**
 * This is an Assembler for the FML machine.
 * 
 * @author TheGrandmother
 *
 */
public class Assembler {

	String current_file = "";
	int line_number = 1;
	static String default_name = "in.asm";
	static String default_out = "out.fml";
	static int default_start_address = 0;
	String in_name;
	String out_name;

	HashMap<String, Pointer> pointer_map;
	HashMap<String, Label> label_map;
	HashMap<String, Constant> constant_map;
	LinkedList<Token> token_list;
	LinkedList<Integer> machinecode_list;
	int current_address;
	int start_address;
	static final String int_regex = "((-?0x[a-fA-F[0-9]]+)|(-?\\d+))";
	static final String raw_regex = ":" + int_regex;
	static final String include_regex = "<\\s*[\\w.-]+\\.asm";
	static final String pointer_regex = "@\\s*\\D[\\w.-]+\\s*(\\+\\s*"
			+ int_regex + ")?";
	static final String label_regex = "#\\s*\\D[\\w.-]+";
	static final String constant_regex = "!\\s*\\D[\\w.-]+\\s*=\\s*"
			+ int_regex;
	static final String instruction_regex = "([a-zA-Z]{3})(\\s+\\$?(([\\w.-]+)|"
			+ int_regex + "))?(\\s+\\$?(([\\w.-]+)|" + int_regex + "))?";

	public Assembler() {
		pointer_map = new HashMap<String, Pointer>();
		label_map = new HashMap<String, Label>();
		constant_map = new HashMap<String, Constant>();
		token_list = new LinkedList<Token>();
		machinecode_list = new LinkedList<Integer>();
		current_address = default_start_address;
	}

	public static void main(String[] args) throws AssemblerError {

		Assembler a = new Assembler();

		switch (args.length) {

		case 1:
			a.start_address = default_start_address;
			a.current_address = a.start_address;
			a.in_name = args[0];
			a.out_name = default_out;
			break;

		case 2:
			a.start_address = default_start_address;
			a.current_address = a.start_address;
			a.in_name = args[0];
			a.out_name = args[1];
			break;
		case 3:
			a.start_address = Integer.parseInt(args[2]);
			a.current_address = a.start_address;
			a.in_name = args[0];
			a.out_name = args[1];
			break;

		default:
			a.start_address = default_start_address;
			a.current_address = a.start_address;
			a.in_name = default_name;
			a.out_name = default_out;
			break;
		}

		try {
			a.scanFile(a.in_name);
		} catch (IOException e) {
			e.printStackTrace();
		}

		for (Token p : a.token_list) {
			p.print();
		}


			a.resolvePointers();
			a.resolveAllRefernces();


		try {
			File output_file = new File(a.out_name);
			BufferedWriter out_buffer;
			if (output_file.exists()) {
				output_file.delete();
				output_file.createNewFile();
				out_buffer = new BufferedWriter(new FileWriter(output_file,
						true));
			} else {
				output_file.createNewFile();
				out_buffer = new BufferedWriter(new FileWriter(output_file,
						true));
			}

			// out_buffer.write(Integer.toString(a.start_address)+"\n");
			for (Integer i : a.machinecode_list) {
				out_buffer.write(Integer.toString(i) + "\n");
			}
			out_buffer.close();

		} catch (IOException e) {
			e.printStackTrace();
		}
		System.out.println("Wrote " + (a.current_address - a.start_address)
				+ " lines to " + a.out_name);

	}

	static String beautify(String s) {
		return s.trim().replaceAll("_", "").replaceAll("/.*", "");
	}
	
	public void scanFile(String file_name) throws IOException, AssemblerError {

		BufferedReader reader = new BufferedReader(new FileReader(file_name));

		String s;

		line_number = 1;
		while ((s = reader.readLine()) != null) {
			current_file = file_name;
			try {

				parseLine(s);

			} catch (SyntaxError e) {
				System.out.println("Syntax Error: " + "In file: " + file_name
						+ ". At line: " + line_number);
				System.out.println("\t" + e.getMessage());
				throw new AssemblerError("Failed to parse file: " + file_name);

			}
			line_number++;
		}
		System.out.println("Parsed file: " + file_name);
		reader.close();

	}

	public void parseLine(String line) throws SyntaxError, AssemblerError {
		String pretty_line = beautify(line).trim();
		if (pretty_line.matches("\\s*") || pretty_line == "") {
			return;
		}else if (pretty_line.matches(include_regex)) {
			int temp_line_number = line_number;
			try {

				scanFile(pretty_line.substring(pretty_line.indexOf("<") + 1)
						.trim());

			} catch (IOException e) {
				throw new SyntaxError("I/O error: " + e.getMessage());
			}

			line_number = temp_line_number;

		} else if (pretty_line.matches(raw_regex)) {
			parseRaw(pretty_line);
		} else if (pretty_line.matches(constant_regex)) {
			parseConstant(pretty_line);
		} else if (pretty_line.matches(label_regex)) {
			parseLabel(pretty_line);
		} else if (pretty_line.matches(pointer_regex)) {
			parsePointer(pretty_line);
		} else if (pretty_line.matches(instruction_regex)) {
			parseInstruction(pretty_line);
		} else {
			throw new SyntaxError("Line does not match anny known pattern: "
					+ line);
		}
	}

	void parseLabel(String line) throws SyntaxError {
		String name = line.substring(line.indexOf("#") + 1).trim();
		assertUnique(name);
		label_map.put(name, new Label(name, current_address, line_number,
				current_file));

	}

	void parsePointer(String line) throws SyntaxError {
		String name;
		String data = "";
		if (line.contains("+")) {
			name = line.substring(line.indexOf("@") + 1, line.indexOf("+"))
					.trim();
			data = line.substring(line.indexOf("+") + 1).trim();
		} else {
			name = line.substring(line.indexOf("@") + 1).trim();
		}
		assertUnique(name);
		if (data == "") {
			pointer_map.put(name, new Pointer(name, 0, line_number,
					current_file));
		} else {
			pointer_map.put(name, new Pointer(name, getNumber(data),
					line_number, current_file));
		}
	}

	void parseConstant(String line) throws SyntaxError {
		String name = beautify(line.substring(line.indexOf("!") + 1,
				line.indexOf("=")).trim());
		String data = line.substring(line.indexOf("=") + 1).trim();
		assertUnique(name);
		constant_map.put(name, new Constant(name, getNumber(data), line_number,
				current_file));

	}

	void parseRaw(String line) throws SyntaxError {
		try {
			token_list.add(new Data(getNumber(line)));
			current_address++;
		} catch (Exception e) {
			throw new SyntaxError(e.getMessage());
		}

	}

	void parseInstruction(String line) throws SyntaxError {
		line = line.trim();
		String[] arguments = line.split("\\s+");

		int action = 0;
		int operation = 0;
		int a1 = 0;
		int a2 = 0;
		int instruction = 0;
		// boolean a1_is_address = false;
		// boolean a2_is_address = false;

		final int not_used = 0b1000;
		final int is_address = 0b0100;
		final int stack = 0b0000;
		final int x_reg = 0b0001;
		final int y_reg = 0b0010;
		final int non_reg = 0b0011;

		// Token instruction_token = null;
		Token a1_token = null;
		Token a2_token = null;

		switch (arguments[0].toUpperCase()) {
		// Operations
		case "NOP":
			action = 0;
			operation = 0;
			a1 = not_used;
			a2 = not_used;
			if (arguments.length != 1) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "INC":
			action = 0;
			operation = 1;
			a2 = not_used;
			if (arguments.length != 2) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "DEC":
			action = 0;
			operation = 2;
			a2 = not_used;
			if (arguments.length != 2) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "ADD":
			action = 0;
			operation = 3;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "SUB":
			action = 0;
			operation = 4;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "MUL":
			action = 0;
			operation = 5;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "DIV":
			action = 0;
			operation = 6;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "MOD":
			action = 0;
			operation = 7;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "EQL":
			action = 0;
			operation = 8;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "GRT":
			action = 0;
			operation = 9;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "LES":
			action = 0;
			operation = 10;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "AND":
			action = 0;
			operation = 11;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "OOR":
			action = 0;
			operation = 12;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "XOR":
			action = 0;
			operation = 13;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "NOT":
			action = 0;
			operation = 14;
			a2 = not_used;
			if (arguments.length != 2) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "SFT":
			action = 0;
			operation = 15;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		// ACTIONS
		case "JMP":
			action = 1;
			operation = 0;
			a2 = not_used;
			if (arguments.length != 2) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "JSR":
			action = 2;
			operation = 0;
			a2 = not_used;
			if (arguments.length != 2) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "RET":
			action = 3;
			operation = 0;
			a1 = not_used;
			a2 = not_used;
			if (arguments.length != 1) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "SEQ":
			action = 4;
			operation = 0;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "SGR":
			action = 5;
			operation = 0;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "SLE":
			action = 6;
			operation = 0;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "JOO":
			action = 7;
			operation = 0;
			a2 = not_used;
			break;
		case "JOZ":
			action = 8;
			operation = 0;
			a2 = not_used;
			if (arguments.length != 2) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "S00":
			action = 9;
			operation = 0;
			a2 = not_used;
			if (arguments.length != 2) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "SOZ":
			action = 10;
			operation = 0;
			a2 = not_used;
			if (arguments.length != 2) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "HLT":
			action = 11;
			operation = 0;
			a1 = not_used;
			a2 = not_used;
			if (arguments.length != 1) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;
		case "MOV":
			action = 12;
			operation = 0;
			if (arguments.length != 3) {
				throw new SyntaxError("Wrong number of arguments: " + line);
			}
			break;

		default:
			throw new SyntaxError("Unknown mnemonic: " + line);
		}

		if (arguments.length >= 2 && a1 != not_used) {
			String match_me;
			if (arguments[1].charAt(0) == "$".charAt(0)) {
				a1 |= is_address;
				match_me = arguments[1].substring(1);

			} else {
				a1 = 0;
				match_me = arguments[1];
			}
			switch (match_me) {
			case "s":
				a1 |= stack;
				break;
			case "x":
				a1 |= x_reg;
				break;
			case "y":
				a1 |= y_reg;
				break;

			default:
				if (match_me == "") {
					throw new SyntaxError("Must have atleast one argument: "
							+ line);
				}
				a1 += non_reg;
				if (match_me.matches(int_regex)) {

					a1_token = new Data(getNumber(match_me));
				} else {
					a1_token = new Entry(match_me);
				}
				break;
			}
		}

		if (arguments.length == 3 && a2 != not_used) {
			String match_me;

			if (arguments[2].charAt(0) == "$".charAt(0)) {
				a2 |= is_address;
				match_me = arguments[2].substring(1);

			} else {
				a2 = 0;
				match_me = arguments[2];
			}

			switch (match_me) {
			case "s":

				a2 |= stack;
				break;
			case "x":

				a2 |= x_reg;
				break;
			case "y":

				a2 |= y_reg;
				break;

			default:

				if (match_me == "") {
					throw new SyntaxError("Must have a second argument: "
							+ line);
				}
				a2 |= non_reg;
				if (match_me.matches(int_regex)) {
					a2_token = new Data(getNumber(match_me));
				} else {
					a2_token = new Entry(match_me);
				}
				break;
			}
		}

		// Here we do some horrible argument checking
		if (action == 12 && a2 == 0b0011) {
			throw new SyntaxError(
					"You can't move stuff to a numeric constant here: " + line);
		}
//		if ((operation == 1 || operation == 2)
//				&& !(a1 == 0b0000 || a1 == 0b0001 || a1 == 0b0010)) {
//			throw new SyntaxError(
//					"You can only increment/decrement the registers or the stack: "
//							+ line);
//		}

		instruction = a1;
		instruction = instruction | (a2 << 4);
		instruction = instruction | (operation << 8);
		instruction = instruction | (action << 12);
		token_list.add(new Instruction(line, instruction));
		current_address++;
		if (a1_token != null) {
			token_list.add(a1_token);
			current_address++;
		}
		if (a2_token != null) {

			token_list.add(a2_token);
			current_address++;
		}

	}

	void assertUnique(String name) throws SyntaxError {
		if (pointer_map.containsKey(name)) {
			throw new SyntaxError("Duplicate reference: " + name
					+ ". First defined at line: "
					+ pointer_map.get(name).defined_at_line + ". In file: "
					+ pointer_map.get(name).defined_in_file);
		}

		if (constant_map.containsKey(name)) {
			throw new SyntaxError("Duplicate reference: " + name
					+ ". First defined at line: "
					+ constant_map.get(name).defined_at_line + ". In file: "
					+ constant_map.get(name).defined_in_file);
		}

		if (label_map.containsKey(name)) {
			throw new SyntaxError("Duplicate reference: " + name
					+ ". First defined at line: "
					+ label_map.get(name).defined_at_line + ". In file: "
					+ label_map.get(name).defined_in_file);
		}
	}

	static boolean numberIsHex(String s) {
		return s.contains("0x");
	}

	int getNumber(String s) throws SyntaxError {
		String number;
		Matcher m = Pattern.compile(Assembler.int_regex).matcher(s);
		// m.find();
		m.find();
		try {
			number = m.group(0);
		} catch (Exception e) {
			throw new SyntaxError("This is not a proper number: " + s);
		}
		if (numberIsHex(s)) {
			return Integer.parseInt(number.substring(2), 16);
		} else {
			return Integer.parseInt(number);
		}
	}

	void resolvePointers() {
		current_address++;
		for (Pointer p : pointer_map.values()) {
			p.value = current_address + p.offset;
			p.resolved = true;
			current_address += 1 + p.offset;
		}
	}

	void resolveAllRefernces() throws AssemblerError {
		String entry_name;
		for (Token t : token_list) {
			if (t.getClass() == Entry.class) {
				entry_name = ((Entry) t).name;

				if (pointer_map.containsKey(entry_name)) {
					if (!pointer_map.get(entry_name).resolved) {
						throw new AssemblerError("Unserloved token: "
								+ entry_name + ". Defined at line "
								+ pointer_map.get(entry_name).defined_at_line
								+ " in file "
								+ pointer_map.get(entry_name).defined_in_file);
					}
					machinecode_list.add(pointer_map.get(entry_name).value);
				} else if (label_map.containsKey(entry_name)) {
					machinecode_list.add(label_map.get(entry_name).value);
				} else if (constant_map.containsKey(entry_name)) {
					machinecode_list.add(constant_map.get(entry_name).value);
				} else {
					System.out.println("#############");
					for (Constant c : constant_map.values()) {
						c.print();
					}
					throw new AssemblerError("Entry " + entry_name
							+ " has not been defined.");
				}

			} else {
				machinecode_list.add(t.value);
			}
		}
	}

	@SuppressWarnings("serial")
	public class SyntaxError extends Exception {
		public SyntaxError() {
			super();
		}

		public SyntaxError(String s) {
			super(s);
		}
	}

	@SuppressWarnings("serial")
	public class AssemblerError extends Exception {
		public AssemblerError() {
			super();
		}

		public AssemblerError(String s) {
			super(s);
		}
	}

	public class AssemblerWarning extends Exception {
		public AssemblerWarning() {
			super();
		}

		public AssemblerWarning(String message) {
			super(message);
		}
	}

}
