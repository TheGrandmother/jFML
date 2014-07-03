package components;

public class Stack{
	
	int[] stack;
	private int frame_pointer;
	private int initial_capacity;

	private static final int multiplicand = 2;
	private static final int threshold = 3; 
	
	public Stack(int capacity){
		initial_capacity = capacity;
		stack = new int[capacity];
		frame_pointer = -1;

	}
	
	public void push(int n){

		frame_pointer++;
		if(frame_pointer == stack.length){increase();}
		stack[frame_pointer] = n;
	}
	
	public int pop() throws StackEmptyException {
		if(frame_pointer == -1){throw new StackEmptyException();}
		if(stack.length >= initial_capacity && frame_pointer <= (stack.length/threshold)){decrease();}
		frame_pointer--;
		
		return stack[frame_pointer+1];
		
	}

	public boolean isEmpty(){
		if(frame_pointer == -1){
			return true;
		}else{
			return false;
		}
			
	}
	
	public int[] toArray(){
		int[] ret = new int[frame_pointer+1];
		for (int i = 0; i <= frame_pointer; i++) {
			ret[i] = stack[i];
		}
		return ret;
	}
	
	public int getArraySize(){
		return stack.length;
	}
	
	public int getSize(){
		return frame_pointer+1;
	}
	
	
	private void increase(){
		int[] new_stack = new int[stack.length*multiplicand];
		for (int i = 0; i < stack.length; i++){
			new_stack[i] = stack[i];
		}
		stack = new_stack;
	}
	
	private void decrease(){
		int[] new_stack = new int[frame_pointer+1];
		for (int i = 0; i <= frame_pointer; i++){
			new_stack[i] = stack[i];
		}
		stack = new_stack;
	}
	
	class StackEmptyException extends Exception{
		public StackEmptyException() {
			super();
		}
		public StackEmptyException(String message) {
			super(message);
		}
	}
	
	
	
}
