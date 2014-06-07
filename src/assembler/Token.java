package assembler;

public abstract class Token {
	 
	int value;
	
	abstract public void print();
}

abstract class Reference{
	
	String name;
	int value;
	boolean resolved;
	int defined_at_line;
	String defined_in_file;
	
	abstract public void print();
	
}

class Pointer extends Reference{
	
	int offset;
	
	public Pointer(String name, int offset, int defined_at_line, String defined_in_file) {
		super.name = name;
		super.resolved = false;
		super.value = 0;
		super.defined_at_line = defined_at_line;
		super.defined_in_file = defined_in_file;
		this.offset = offset;
	}
	

	public void print() {
		System.out.print("Pointer: " + name +". ");
		if (resolved) {
			System.out.print("Value: " + value);
			}else{
			System.out.print("Not resolved.");
		}
		System.out.println();
	}
}

class Label extends Reference{
	
	public Label(String name,int address, int defined_at_line, String defined_in_file) {
		super.name = name;
		super.resolved = true;
		super.value = address;
		super.defined_at_line = defined_at_line;
		super.defined_in_file = defined_in_file;
	}
	
	public void print() {
		System.out.print("Label: " + name +". ");
		if (resolved) {
			System.out.print("Value: " + value);
			}else{
			System.out.print("Not resolved.");
		}
		System.out.println();
	}
}

class Constant extends Reference{
	
	public Constant(String name, int value, int defined_at_line, String defined_in_file) {
		super.name = name;
		super.resolved = true;
		super.value = value;
		super.defined_at_line = defined_at_line;
		super.defined_in_file = defined_in_file;
	}
	
	public void print() {
		System.out.print(name + " = " + value);
		System.out.println();
	}
	
}

class Instruction extends Token{

	String original;
	
	public Instruction(String original, int instruction){
		this.original = original;
		value = instruction;
	}
	
	@Override
	public void print() {
		// TODO Auto-generated method stub
		System.out.println(value  + "/"+ Integer.toHexString(value) + "   \t(" + original +")" );
	}
}

class Data extends Token{

	///int value;
	
	public Data(int data) {
		super.value = data;
	}
	@Override
	public void print() {
		System.out.println(value + "\t\tData");
	}
}

class Entry extends Token{

	String name;
	public Entry(String name) {
		this.name = name;
	}
	
	@Override
	public void print() {
		System.out.println(name + "\t\tEntry");
		
	}
	
}


