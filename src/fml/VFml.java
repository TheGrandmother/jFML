package fml;



import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.HeadlessException;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.FileReader;
import java.sql.Time;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.JTextField;
import javax.swing.JToggleButton;

import components.Ram;
import components.Ram.InvalidAddressExcption;
import components.Vm;



public class VFml extends JFrame implements ActionListener{

	int memory_size = 1_000_000;
	Vm vm = new Vm(memory_size);
	Screen screen;
	int screen_start = 80000;
	int screen_end = 90000;
	int update_bit = 90001;
	boolean debug = false;
	
	
	boolean tick_once = false;
	boolean running = false;
	
	
	JPanel big = new JPanel();
	JPanel settings = new JPanel();
	JPanel stats = new JPanel();
	JFrame thing = new JFrame();
	
	JToggleButton run = new JToggleButton("Run");
	JButton step = new JButton("Step");
	JButton reset = new JButton("Reset");
	JButton standard = new JButton("Load out.fml");
	JTextField in_file = new JTextField("Input File");
	JLabel halt_label = new JLabel("Halt Flag: ");
	JLabel halt_flag_value = new JLabel("void");
	JLabel irq1_flag = new JLabel("IRQ1: ");
	JLabel irq2_flag = new JLabel("IRQ2: ");
	JLabel irq1_flag_value = new JLabel("void");
	JLabel irq2_flag_value = new JLabel("void");
	JLabel x_reg = new JLabel("X: ");
	JLabel x_reg_value = new JLabel("void");
	JLabel y_reg = new JLabel("Y: ");
	JLabel y_reg_value = new JLabel("void");
	JLabel pc_label = new JLabel("Program Counter");
	JLabel addr = new JLabel("Current Addr: ");
	JLabel addr_value = new JLabel("void");
	JLabel virtual_addr = new JLabel("Virtual Addr: ");
	JLabel virtual_addr_value = new JLabel("void");
	JLabel instruction = new JLabel("Current Inst: ");
	JLabel inst_value = new JLabel("void");
	JLabel cycles = new JLabel("Cycles: ");
	JLabel cycles_value = new JLabel("void");
	JLabel stack_size = new JLabel("Stack size: ");
	JLabel stack_size_value = new JLabel("void");
	
	
	JTextField dump_start = new JTextField("Dump start");
	JTextField dump_end = new JTextField("Dump end");
	JButton dump = new JButton("Dump");
	JButton force_update = new JButton("Force screen update");
	
	JButton load_memmory = new JButton("Load Memmory");
	JTextField memmory_file = new JTextField("Memmory File");
	JTextField memmory_start = new JTextField("Memmory Address");
	
	  
	long time;
	int screen_update_time = 5;
	
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		VFml v = new VFml();
		
		v.setVisible(true);
		v.pack();
		v.fillLabels();
		v.vm.halt_flag = false;
		
		long time = 0;
		long big_time = 0;
		Time lol = new Time(0);
		
		while(true){
			if(v.running || v.tick_once){
				
				try {
					
					time = System.nanoTime();
					v.vm.step();
					big_time += System.nanoTime()-time;
					//v.anoyMe(""+big_time);
					if(v.vm.cycles % 100000 ==0 && v.debug){
						System.out.println( (int)(1/((big_time)/(100000.0*1_000_000_000)))  +"hz");
						System.out.println("Mov time: " +(v.vm.timers[0][0]/v.vm.timers[0][1]));
						System.out.println("Arithmetic time: " +(v.vm.timers[1][0]/v.vm.timers[1][1]));
						System.out.println("Logic Time: " +(v.vm.timers[2][0]/v.vm.timers[2][1]));
						System.out.println("Jump Time: " +(v.vm.timers[3][0]/v.vm.timers[3][1]));
						long sum = 0;
						for (int i = 0; i < 4; i++) {
							sum += (v.vm.timers[i][0]/v.vm.timers[i][1]);
						}
						
						System.out.println("Total: " + (int)(((big_time)/(100000.0))));
						System.out.println("Total Operation Time: " + sum);
						System.out.println("Diff: "+ ((int)(((big_time)/(100000.0))) - (sum)) );
						
						System.out.println();
						big_time = 0;
					}
					
					v.updateScreen();
					v.updateTimer();
					
				} catch (Exception e) {
					JOptionPane.showMessageDialog(v.big, "Error: \n" +e.toString());
					v.running = false;
				}
				
				if((v.vm.cycles % 10000 ==0)|| v.tick_once){
				v.fillLabels();
				}
				

			}

			if(v.tick_once){
				v.tick_once = false;
			}
		}
		
	}
	public void anoyMe(String s){
		System.out.println(s);
	}
	
	public void updateScreen(){
		try {
			if(vm.ram.read(update_bit) == 1 && (System.currentTimeMillis()-time > screen_update_time )){
				populateScreen();
				screen.drawScreen();
				screen.paint(screen.getGraphics());
				//screen.repaint();
				vm.ram.write(0, update_bit);
				time = System.currentTimeMillis();
			}
		} catch (InvalidAddressExcption e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void waitFor(int n){
		long time = System.currentTimeMillis();
		while(System.currentTimeMillis()-time < n){};
	}
	
	public VFml(){
		super();
		time = System.currentTimeMillis();
		
		screen = new Screen(100,100,3);
		populateScreen();
		screen.drawScreen();
		screen.repaint();
		System.setProperty("awt.useSystemAAFontSettings","on");
		System.setProperty("swing.aatext", "true");
		setSize(750,500);
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		run.addActionListener(this);
		run.setActionCommand("Run");
		step.addActionListener(this);
		step.setActionCommand("Step");
		reset.addActionListener(this);
		reset.setActionCommand("Reset");
		in_file.addActionListener(this);
		in_file.setActionCommand("Input File");
		dump.addActionListener(this);
		dump.setActionCommand("Dump");
		force_update.addActionListener(this);
		force_update.setActionCommand("Force");
		standard.addActionListener(this);
		standard.setActionCommand("Standard");
		load_memmory.addActionListener(this);
		load_memmory.setActionCommand("Load");
		//memmory_file.addActionListener(this);
		//memmory_file.addAction
		

		settings.setLayout(new BoxLayout(settings, BoxLayout.PAGE_AXIS));
		settings.add(run);
		settings.add(step);
		settings.add(reset);
		settings.add(standard);
		settings.add(in_file);
		settings.add(dump);
		settings.add(dump_start);
		settings.add(dump_end);
		settings.add(force_update);
		settings.add(load_memmory);
		settings.add(memmory_file);
		settings.add(memmory_start);
		
		
		stats.setLayout(new GridLayout(0, 2));
		stats.setBorder(BorderFactory.createLineBorder(Color.gray,1));
		stats.add(halt_label);
		stats.add(halt_flag_value);
		stats.add(irq1_flag);
		stats.add(irq1_flag_value);
		stats.add(irq2_flag);
		stats.add(irq2_flag_value);
		stats.add(x_reg);
		stats.add(x_reg_value);
		stats.add(y_reg);
		stats.add(y_reg_value);
		stats.add(stack_size);
		stats.add(stack_size_value);
		stats.add(new JLabel());
		stats.add(new JLabel());
//		stats.add(pc_label);
//		stats.add(new JLabel());
		stats.add(addr);
		stats.add(addr_value);
		stats.add(virtual_addr);
		stats.add(virtual_addr_value);
		stats.add(instruction);
		stats.add(inst_value);
		stats.add(cycles);
		stats.add(cycles_value);
		

		big.add(settings);

		big.add(stats);
		big.add(screen);
		//thing.setSize(screen.width*screen.size,screen.height*screen.size);
		//thing.add(screen);
		//thing.setVisible(true);
		populateScreen();
		add(big);
		settings.setVisible(true);
		screen.setVisible(true);
		
	}
	   
	void fillLabels(){
		halt_flag_value.setText(""+vm.halt_flag);
		irq1_flag_value.setText(""+vm.irq1_flag);
		irq2_flag_value.setText(""+vm.irq2_flag);
		x_reg_value.setText(""+Integer.toHexString(vm.x.read()));
		y_reg_value.setText(""+Integer.toHexString(vm.y.read()));
		addr_value.setText(""+Integer.toHexString(vm.pc.getAddress()));
		try {
			virtual_addr_value.setText(""+Integer.toHexString(vm.ram.resolvePA(vm.pc.getAddress())));
		} catch (InvalidAddressExcption e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		stack_size_value.setText(""+vm.s.getSize());
		
		try {
			inst_value.setText(""+Integer.toHexString(vm.ram.read(vm.pc.getAddress())));
		} catch (InvalidAddressExcption e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			running = false;
			
		}
		cycles_value.setText(""+vm.cycles);
	}
	

	void populateScreen(){
		int[] tmp = new int[screen.width*screen.height];
		for (int i = 0; i < tmp.length; i++) {
			try {
				tmp[i] = vm.ram.read(screen_start+i);
			} catch (InvalidAddressExcption e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		screen.setBitmap(tmp);
	}
	
	@Override
	public void actionPerformed(ActionEvent e){
		switch (e.getActionCommand()) {
		case "Input File":
			try {
				BufferedReader reader = new BufferedReader(new FileReader(in_file.getText()),10000);
				int start_address = (int)Integer.parseInt(reader.readLine());
				String s;
				int i = 0;
				while((s = reader.readLine()) != null){
					s = s.replace("~", "-"); //This needs to be here due to the fact that fucking SML uses ~ to denote negative numbers
					vm.ram.write((int)Integer.parseInt(s), start_address+i);
					i++;
				}
				reader.close();
			} catch (Exception e2) {
				JOptionPane.showMessageDialog(big, "Error: \n" +e2.toString());
			}

			break;
		
		case "Run":
			if(running){
				running = false;
			}else{
				running = true;
			}
			break;
		
		case "Reset":
			running = false;
			vm = new Vm(memory_size);
			vm.halt_flag = false;
			break;
		
		case "Step":
			tick_once =true;
			break;
		
		case "Dump":
			//System.out.println(dump_start.getText());
			try {
				JOptionPane.showMessageDialog(big, vm.ram.toString(Integer.parseInt(dump_start.getText()),Integer.parseInt(dump_end.getText()),100));
			} catch (Exception e1) {
				JOptionPane.showMessageDialog(big, "Error: \n" +e1.toString());
				
			}
			break;
			
		case "Force":
			populateScreen();
			screen.drawScreen();
			screen.repaint();
			break;
		
		case "Standard":
			try {
				BufferedReader reader = new BufferedReader(new FileReader("out.fml"),100000);
				reader.mark(100000);
				int start_address = (int)Integer.parseInt(reader.readLine());
				String s;
				int i = 0;
				while((s = reader.readLine()) != null){
					s = s.replace("~", "-");
					vm.ram.write((int)Integer.parseInt(s), start_address+i);
			
					i++;
				}
				reader.close();
			} catch (Exception e2) {
				JOptionPane.showMessageDialog(big, "Error: \n" +e2.toString());
			}
			break;
			
		case "Load":
			try {
				
				BufferedReader reader = new BufferedReader(new FileReader(memmory_file.getText()));
				int start_address = (int)Integer.parseInt(memmory_start.getText());
				String s;
				int i = 0;
				while((s = reader.readLine()) != null){
					s = s.replace("~", "-"); //This needs to be here due to the fact that fucking SML uses ~ to denote negative numbers
					vm.ram.write((int)Integer.parseInt(s), start_address+i);
					i++;
				}
				reader.close();
			} catch (Exception e2) {
				error(e2);
			}
			break;
		
		default:
			break;
		}
		
	}
	
	public void updateTimer() throws InvalidAddressExcption{
		vm.ram.write((int)System.currentTimeMillis(), Ram.timer_address);
	}
	
	public void error(Exception e){
		JOptionPane.showMessageDialog(big, "Error: \n" +e.toString());
	}

}
