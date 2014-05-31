package fml;



import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.FileReader;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.JTextField;
import javax.swing.JToggleButton;

import components.Ram.InvalidAddressExcption;
import components.Vm;



public class VFml extends JFrame implements ActionListener{

	int memory_size = 100000;
	Vm vm = new Vm(memory_size);
	Screen screen;
	int screen_start = 80000;
	int screen_end = 90000;
	
	
	boolean tick_once = false;
	boolean running = false;
	
	
	JPanel big = new JPanel();
	JPanel settings = new JPanel();
	JPanel stats = new JPanel();
	
	JToggleButton run = new JToggleButton("Run");
	JButton step = new JButton("Step");
	JButton reset = new JButton("Reset");
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
	JLabel instruction = new JLabel("Current Inst: ");
	JLabel inst_value = new JLabel("void");
	JLabel cycles = new JLabel("Cycles: ");
	JLabel cycles_value = new JLabel("void");
	
	
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		VFml v = new VFml();
		
		v.setVisible(true);
		v.pack();
		v.fillLabels();
		v.vm.halt_flag = false;
		long time =System.currentTimeMillis();
		while(true){
			if(v.running || v.tick_once){
				
				try {
					v.vm.step();
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				//time = System.currentTimeMillis();
				v.waitFor(0);
				//while(System.currentTimeMillis()-time < 0){};
				v.populateScreen();
				v.screen.repaint();
				v.fillLabels();

			}
			if(v.tick_once){
				v.tick_once = false;
			}
			

			
		}
		
		
		
		
		

	}
	
	public void waitFor(int n){
		long time = System.currentTimeMillis();
		while(System.currentTimeMillis()-time < n){};
	}
	
	public VFml(){
		super();
		screen = new Screen(100,100,2);
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

		settings.setLayout(new BoxLayout(settings, BoxLayout.PAGE_AXIS));
		settings.add(run);
		settings.add(step);
		settings.add(reset);
		settings.add(in_file);
		
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
		stats.add(new JLabel());
		stats.add(new JLabel());
//		stats.add(pc_label);
//		stats.add(new JLabel());
		stats.add(addr);
		stats.add(addr_value);
		stats.add(instruction);
		stats.add(inst_value);
		stats.add(cycles);
		stats.add(cycles_value);
		

		big.add(settings);

		big.add(stats);
		big.add(screen);
		populateScreen();
		add(big);
		settings.setVisible(true);
		
	}
	
	void fillLabels(){
		halt_flag_value.setText(""+vm.halt_flag);
		irq1_flag_value.setText(""+vm.irq1_flag);
		irq2_flag_value.setText(""+vm.irq2_flag);
		x_reg_value.setText(""+vm.x.read());
		y_reg_value.setText(""+vm.y.read());
		addr_value.setText(""+vm.pc.getAddress());
		try {
			inst_value.setText(""+vm.ram.read(vm.pc.getAddress()));
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
				BufferedReader reader = new BufferedReader(new FileReader("out.fml"));
				int start_address = (int)Integer.parseInt(reader.readLine());
				String s;
				int i = 0;
				while((s = reader.readLine()) != null){
					
					vm.ram.write((int)Integer.parseInt(s), start_address+i);
					i++;
				}
				reader.close();
			} catch (Exception e2) {
				// TODO: handle exception
			}

			break;
		
		case "Run":
			running = true;
			break;
		
		case "Reset":
			running = false;
			vm = new Vm(memory_size);
			vm.halt_flag = false;
			break;
		
		case "Step":
			tick_once =true;
			break;
		
		default:
			break;
		}
		
	}

}
