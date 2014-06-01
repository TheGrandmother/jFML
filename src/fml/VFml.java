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

import components.Ram.InvalidAddressExcption;
import components.Vm;



public class VFml extends JFrame implements ActionListener{

	int memory_size = 100000;
	Vm vm = new Vm(memory_size);
	Screen screen;
	int screen_start = 80000;
	int screen_end = 90000;
	int update_bit = 90001;
	
	
	boolean tick_once = false;
	boolean running = false;
	
	
	JPanel big = new JPanel();
	JPanel settings = new JPanel();
	JPanel stats = new JPanel();
	
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
	
	long time;
	int screen_update_time;
	
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		VFml v = new VFml();
		
		v.setVisible(true);
		v.pack();
		v.fillLabels();
		v.vm.halt_flag = false;
		
		
		while(true){
			if(v.running || v.tick_once){
				
				try {
					v.vm.step();
					v.updateScreen();
				} catch (Exception e) {
					JOptionPane.showMessageDialog(v.big, "Error: \n" +e.toString());
					v.running = false;
				}
				
				
				v.fillLabels();
				

			}

			if(v.tick_once){
				v.tick_once = false;
			}
		}
		
	}
	public void anoyMe(){
		System.out.println("why u no work");
	}
	
	public void updateScreen(){
		try {
			if(vm.ram.read(update_bit) == 1){
				populateScreen();
				screen.drawScreen();
				screen.paint(screen.getGraphics());
				screen.repaint();
				vm.ram.write(0, update_bit);
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
		screen_update_time = 50;
		screen = new Screen(100,100,2);
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
		stack_size_value.setText(""+vm.s.getSize());
		
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
				// TODO: handle exception
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
		
		default:
			break;
		}
		
	}

}
