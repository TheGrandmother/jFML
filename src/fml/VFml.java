package fml;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.HeadlessException;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.sql.Time;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.JTextField;
import javax.swing.JToggleButton;
import javax.swing.filechooser.FileFilter;

import assembler.Assembler;
import assembler.Assembler.AssemblerError;
import components.Ram;
import components.Ram.InvalidAddressExcption;
import components.Vm;

/**
 * This is a very basic class to handle the running of the FML machine. It basicly just provides a GUI
 * 
 * 
 * @author TheGrandmother
 */
public class VFml extends JFrame implements ActionListener {

	int memory_size = 1_000_000;
	Vm vm = new Vm(memory_size);
	Screen screen;

	boolean debug = false;

	boolean tick_once = false;
	boolean running = false;

	JPanel big = new JPanel();
	JPanel settings = new JPanel();
	JPanel stats = new JPanel();
	JFrame thing = new JFrame();
	File f;

	final JFileChooser fc = new JFileChooser(System.getProperty("user.dir"));
	FileFilter asm_filter = new FileFilter() {

		@Override
		public String getDescription() {
			return "Assembly files";
		}

		@Override
		public boolean accept(File f) {
			if (f.isDirectory()) {
				return true;
			}
			if (f.getName() == "") {
				return false;
			} else if (f.getName().contains(".asm")) {
				return true;
			} else {
				return false;
			}
		}
	};

	FileFilter mem_filter = new FileFilter() {

		@Override
		public String getDescription() {
			return "Memmory files (.mem or .fml)";
		}

		@Override
		public boolean accept(File f) {
			// TODO Auto-generated method stub
			if (f.isDirectory()) {
				return true;
			}
			if (f.getName() == "") {
				return false;
			} else if (f.getName().contains(".mem")
					|| f.getName().contains(".fml")) {
				return true;
			} else {
				return false;
			}
		}

	};

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
	JTextField memmory_start = new JTextField("Memmory Address");

	JButton assemble_and_load = new JButton("Assemble and load");

	long time;
	int screen_update_time = 33;

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		VFml v = new VFml();

		v.setVisible(true);
		v.pack();
		v.fillLabels();
		v.vm.halt_flag = false;

		long time = 0;
		long dbg_time = System.nanoTime();
		long big_time = 0;
		long cyles_dbg = 0;

		long dbg_wait_time = 1_000_000_000;
		int burst_length = 10;

		while (true) {
			if (v.running || v.tick_once) {

				if ((v.vm.cycles % 1000000 == 0) || v.tick_once) {
					v.fillLabels();
				}

				try {
					if(!v.tick_once){
					//We run a sequence of vm steps like this to increase the efective number of steps per second.
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					v.vm.step();v.vm.step();v.vm.step();v.vm.step();v.vm.step();
					}else{
						v.vm.step();
					}
					
					if (v.debug) {
						big_time = System.nanoTime() - dbg_time;
						if (big_time >= dbg_wait_time) {
							System.out
									.println("Effective cycles per second:\n"+(int)(((double) v.vm.cycles - cyles_dbg)
											/ (big_time) * 1_000_000_000.0));
							System.out.println("Actual cyle time:\n"+ (v.vm.timers[4][0]/v.vm.timers[4][1]));
							System.out.println("Actual cyles per second:\n"+
									(int)((1.0/(v.vm.timers[4][0]/v.vm.timers[4][1]))*1_000_000_000)
									);
							System.out.println();
							dbg_time = System.nanoTime();
							cyles_dbg = v.vm.cycles;
						}

					}

					if ((v.vm.ram.read(Ram.update_bit) == 1 && ((System
							.currentTimeMillis() - time > v.screen_update_time) || v.tick_once))) {
						v.populateScreen();
						v.screen.drawScreen();
						v.screen.paint(v.screen.getGraphics());
						// screen.repaint();
						v.vm.ram.write(0, Ram.update_bit);
						time = System.currentTimeMillis();
					}
					v.vm.ram.write((int) System.currentTimeMillis(),
							Ram.timer_address);

				} catch (Exception e) {
					v.fillLabels();
					JOptionPane.showMessageDialog(v.big,
							"Error: \n" + e.toString());
					e.printStackTrace();
					v.running = false;
				}
			}

			if (v.tick_once) {
				v.tick_once = false;
			}
		}

	}


	public VFml() {
		super();
		time = System.currentTimeMillis();

		screen = new Screen(320, 200, 3);
		loadFile("standard/standard.mem", Ram.screen_start);
		loadFile("standard/font.mem", Ram.charset_start);
		populateScreen();
		screen.drawScreen();
		screen.repaint();
		System.setProperty("awt.useSystemAAFontSettings", "on");
		System.setProperty("swing.aatext", "true");
		setSize(800, 500);
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

		assemble_and_load.addActionListener(this);
		assemble_and_load.setActionCommand("Assemble");

		settings.setLayout(new GridBagLayout());

		GridBagConstraints cons = new GridBagConstraints();
		cons.fill = GridBagConstraints.BOTH;
		cons.weightx = 1;
		cons.weighty = 1;
		cons.gridx = 0;

		settings.add(run, cons);
		settings.add(step, cons);
		settings.add(reset, cons);
		settings.add(standard, cons);
		settings.add(in_file, cons);
		settings.add(dump, cons);
		settings.add(dump_start, cons);
		settings.add(dump_end, cons);
		settings.add(force_update, cons);
		settings.add(load_memmory, cons);

		settings.add(memmory_start, cons);
		settings.add(assemble_and_load, cons);

		stats.setLayout(new GridLayout(0, 2));
		stats.setBorder(BorderFactory.createLineBorder(Color.gray, 1));
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
		// stats.add(pc_label);
		// stats.add(new JLabel());
		stats.add(addr);
		stats.add(addr_value);
		stats.add(virtual_addr);
		stats.add(virtual_addr_value);
		stats.add(instruction);
		stats.add(inst_value);
		stats.add(cycles);
		stats.add(cycles_value);

		big.setLayout(new BoxLayout(big, BoxLayout.LINE_AXIS));
		big.add(settings);
		stats.setPreferredSize(new Dimension(250, 500));
		big.add(stats);
		big.add(screen);
		populateScreen();
		add(big);
		settings.setVisible(true);
		screen.setVisible(true);

	}

	void fillLabels() {
		halt_flag_value.setText("" + vm.halt_flag);
		irq1_flag_value.setText("" + vm.irq1_flag);
		irq2_flag_value.setText("" + vm.irq2_flag);
		x_reg_value.setText("" + Integer.toHexString(vm.x.read()));
		y_reg_value.setText("" + Integer.toHexString(vm.y.read()));
		addr_value.setText("" + Integer.toHexString(vm.pc.getAddress()));
		try {
			virtual_addr_value
					.setText(""
							+ Integer.toHexString(vm.ram.resolvePA(vm.pc
									.getAddress())));
		} catch (InvalidAddressExcption e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		stack_size_value.setText("" + vm.s.getSize() + "(" + vm.s.peek() + ")");

		try {
			inst_value.setText(""
					+ Integer.toHexString(vm.ram.read(vm.pc.getAddress()))
					+ "/" + Integer.toString(vm.ram.read(vm.pc.getAddress())));
		} catch (InvalidAddressExcption e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			running = false;

		}
		cycles_value.setText("" + vm.cycles);
	}

	void populateScreen() {
		int[] tmp = new int[screen.width * screen.height];
		for (int i = 0; i < tmp.length; i++) {
			try {
				tmp[i] = vm.ram.read(Ram.screen_start + i);
			} catch (InvalidAddressExcption e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		screen.setBitmap(tmp);
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		switch (e.getActionCommand()) {
		case "Input File":
			loadFile(in_file.getText(), 0);
			break;

		case "Run":
			if (running) {
				running = false;
			} else {
				running = true;
			}
			break;

		case "Reset":
			running = false;
			vm = new Vm(memory_size);
			vm.halt_flag = false;
			loadFile("standard/standard.mem", Ram.screen_start);
			loadFile("standard/font.mem", Ram.charset_start);
			break;

		case "Step":
			tick_once = true;
			break;

		case "Dump":
			// System.out.println(dump_start.getText());
			try {
				JOptionPane.showMessageDialog(big, vm.ram.toString(
						Integer.parseInt(dump_start.getText()),
						Integer.parseInt(dump_end.getText()), 100));
			} catch (Exception e1) {
				JOptionPane.showMessageDialog(big, "Error: \n" + e1.toString());

			}
			break;

		case "Force":
			populateScreen();
			screen.drawScreen();
			screen.repaint();
			break;

		case "Standard":
			loadFile("out.fml", 0);
			break;

		case "Load":
			fc.setAcceptAllFileFilterUsed(false);
			//fc.addChoosableFileFilter(mem_filter);
			fc.showOpenDialog(big);
			f = fc.getSelectedFile();
			loadFile(f.getPath(), Integer.parseInt(memmory_start.getText()));
			break;
		case "Assemble":

			fc.setAcceptAllFileFilterUsed(false);
			fc.addChoosableFileFilter(asm_filter);
			fc.showOpenDialog(big);
			f = fc.getSelectedFile();
			if (f == null) {
				break;
			}
			String[] args = { f.getPath(),
					f.getName().replaceAll(".asm", ".fml"), "0" };
			try {
				Assembler.main(args);
			} catch (AssemblerError e1) {
				error(e1);
				break;
			}
			loadFile(f.getName().replaceAll(".asm", ".fml"), 0);
			break;

		default:
			break;
		}

	}

	public void loadFile(String name, int start_address) {
		try {

			BufferedReader reader = new BufferedReader(new FileReader(name));
			String s;
			int i = 0;
			while ((s = reader.readLine()) != null) {
				vm.ram.write((int) Integer.parseInt(s), start_address + i);
				i++;
			}
			reader.close();
		} catch (Exception e2) {
			error(e2);
		}
	}

	public void updateScreen() {
		try {
			if ((vm.ram.read(Ram.update_bit) == 1 && ((System
					.currentTimeMillis() - time > screen_update_time) || tick_once))) {
				populateScreen();
				screen.drawScreen();
				screen.paint(screen.getGraphics());
				// screen.repaint();
				vm.ram.write(0, Ram.update_bit);
				time = System.currentTimeMillis();
			}
		} catch (InvalidAddressExcption e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void waitFor(int n) {
		long time = System.currentTimeMillis();
		while (System.currentTimeMillis() - time < n) {
		};
	}

	public void updateTimer() throws InvalidAddressExcption {
		vm.ram.write((int) System.currentTimeMillis(), Ram.timer_address);
	}

	public void error(Exception e) {
		JOptionPane.showMessageDialog(big, "Error: \n" + e.toString());
		fillLabels();
	}

}
