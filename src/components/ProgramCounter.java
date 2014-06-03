package components;

import components.Stack.StackEmptyException;

public class ProgramCounter {
	private Register address_pointer;
	private Register irq1;
	private Register irq2;
	private Stack jump_stack;
	
	public ProgramCounter(){
		address_pointer = new Register();
		irq1 = new Register();
		irq2 = new Register();
		jump_stack =  new Stack(100);
	}
	
	public void increment(int n){
		address_pointer.write(address_pointer.read()+n);
	}
	
	public void jump(int n){
		address_pointer.write(n);
	}
	
	public void interrupt1(){
		address_pointer.write(irq1.read());
	}
	
	public void interrupt2(){
		address_pointer.write(irq2.read());
	}
	
	public void setIRQ1(int n){
		irq1.write(n);
	}
	
	public void setIRQ2(int n){
		irq2.write(n);
	}
	
	public int getAddress(){
		return address_pointer.read();
	}
	
	public void subroutineJump(int target, boolean non_reg_type){
		if(non_reg_type){
			jump_stack.push(address_pointer.read()+2);
		}else{
			jump_stack.push(address_pointer.read()+1);
		}
		address_pointer.write(target);
	}
	
	public void returnJump() throws StackEmptyException{

			address_pointer.write(jump_stack.pop());

	}
	
	
	
	
	
}
