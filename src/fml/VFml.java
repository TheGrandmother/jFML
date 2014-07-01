package fml;

import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.filechooser.FileFilter;

import assembler.Assembler;
import assembler.Assembler.AssemblerError;
import components.Ram;
import components.Vm;
import components.Ram.InvalidAddressExcption;

@SuppressWarnings("serial")
public class VFml extends JFrame implements KeyListener{

	int screen_width =  640;
	int screen_height = 480;
	int scaling_factor = 2;
	int memory_size = 0xFFF_FFF;
	
	int refresh_rate = 1;
	
	long time;
	
	boolean running = false;
	boolean tick_once = false;
	boolean debug = false;
	
	Vm vm;
	Screen screen;
	
	public static  void main(String[] args) {
		VFml fml = new VFml();
	
			
		
		fml.vm.halt_flag = false;
			while(true){
				try {
					
					fml.runMe();
				} catch (Exception e) {
					fml.error(e);
					fml.running =false;
				}
			}	
		
		
		
		
		
		
	}
	
	public VFml (){
		super();
		vm = new Vm(memory_size);
		
		loadFile("standard/standard.mem", Ram.screen_start);
		loadFile("standard/font.mem", Ram.charset_start);
		
		
		screen = new Screen(screen_width, screen_height, scaling_factor);
		populateScreen();
		screen.drawScreen();
		screen.repaint();
		System.setProperty("awt.useSystemAAFontSettings", "on");
		System.setProperty("swing.aatext", "true");
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		add(screen);
		screen.addKeyListener(this);
		pack();
		setVisible(true);
		setResizable(false);
		
		
	}
	

	
	public synchronized void  runMe() throws Exception{
		
		if(running || tick_once){
			vm.step();
			
			//System.out.println("cycle: " + vm.cycles);
		}
		updateScreen();
		vm.ram.write((int) System.currentTimeMillis(),
				Ram.timer_address);
		//wait(1);
		
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
	
	
	public void error(Exception e) {
		JOptionPane.showMessageDialog(this, "Error: \n" + e.toString());
		//fillLabels();
	}
	
	public void updateScreen() {
		try {
			if ( ((vm.ram.read(Ram.update_bit) == 1 || debug) && ( (System
					.currentTimeMillis() - time > refresh_rate) || tick_once))) {
				populateScreen();
				screen.drawScreen();
			
				if (debug) {
					screen.drawDebug(vm);
				}
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

	public void assembleAndLoad(){
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
		
		fc.setAcceptAllFileFilterUsed(false);
		fc.addChoosableFileFilter(asm_filter);
		fc.showOpenDialog(this);
		File f = fc.getSelectedFile();
		if (f == null) {
			return;
		}
		String[] args = { f.getPath(),
				f.getName().replaceAll(".asm", ".fml"), "0" };
		try {
			Assembler.main(args);
		} catch (AssemblerError e1) {
			error(e1);
			return;
		}
		loadFile(f.getName().replaceAll(".asm", ".fml"), 0);
		
		
		
	}
	

	
	
	@Override
	public synchronized void keyTyped(KeyEvent e) {
		//System.out.println(e.getModifiersEx());
		//System.out.println((int)e.getKeyChar());
		if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && (int)e.getKeyChar() == 1){
			//System.out.println("assemble and load");
			assembleAndLoad();
			return;
		}else if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && (int)e.getKeyChar() == 19){
			//System.out.println("Starting");
			running = true;
			return;
			
		}
		//System.out.println((int)e.getKeyChar());
		//notifyAll();
		
	}

	@Override
	public void keyPressed(KeyEvent e) {
		// TODO Auto-generated method stub
		
		if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && (int)e.getKeyChar() == 4){
			//System.out.println("Debugging");
				debug = true;
			return;
			
		}else if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && (int)e.getKeyChar() == 17){
			//System.out.println("paused");
			running = false;
			return;
		
		}else{
			//System.out.println((int)e.getKeyChar());
			try {
				vm.ram.write((int)e.getKeyChar(), Ram.key_value);
				vm.ram.write(1, Ram.key_down);
				vm.interrupt = true;
				vm.irq = 1;
			} catch (InvalidAddressExcption e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		
		
	}

	@Override
	public void keyReleased(KeyEvent e) {
		if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && (int)e.getKeyChar() == 4){
			//System.out.println("Debugging");
				debug = false;
			return;
			
		}else if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && (int)e.getKeyChar() == 17){
			//System.out.println("paused");
			running = true;
			return;
		
		}else{
			try {
				vm.ram.write(0, Ram.key_down);
			} catch (InvalidAddressExcption e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		
	}
	
}
