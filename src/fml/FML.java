package fml;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;

import components.*;
import components.Ram.InvalidAddressExcption;

public class FML {

	public static void main(String[] args) throws Exception {
		
		BufferedReader reader = new BufferedReader(new FileReader("out.fml"));
		
		Vm vm = new Vm(100);
		
		int start_address = (int)Integer.parseInt(reader.readLine());
		String s;
		int i = 0;
		while((s = reader.readLine()) != null){
			try {
				vm.ram.write((int)Integer.parseInt(s), start_address+i);
				i++;
			} catch (NumberFormatException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (InvalidAddressExcption e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		System.out.println(vm.halt_flag);
		vm.halt_flag = false;
		long time;
		while(!vm.halt_flag){
			time = System.currentTimeMillis();
			vm.print();
			try {
				vm.step();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			while(System.currentTimeMillis() - time < 10){}
			
		}
		vm.print();
		
	}

}
