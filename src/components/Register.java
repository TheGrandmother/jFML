package components;

public class Register {
	int value;
	public Register(){
		value = 0;
	}
	
	public void inc(){
		value++;
	}
	
	public void dec(){
		value--;
	}
	
	public void write(int v){
		value = v;
	}
	
	public int read(){
		return value;
	}
}
