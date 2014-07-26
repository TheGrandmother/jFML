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
	int scaling_factor = 1;
	int memory_size = 0xFFF_FFF;
	
	int refresh_rate = 0;
	
	long time;
	long repeating_key_timer = 0;
	long repeating_key_timeout = 20;
	
	boolean repeating_key_block = false;
	boolean running = false;
	boolean tick_once = false;
	boolean debug = false;

	

	
	
	Vm vm;
	Screen screen;
	
	
	public static  void main(String[] args) {
		VFml fml = new VFml();
		boolean big_dbg = false;
		long dbg_time = System.currentTimeMillis();
		long elapsed_time = 1;
		long prev_cycles = 0;
			
		
		fml.vm.halt_flag = false;
			while(true){
				try {
					fml.runMe();
					if (big_dbg && (System.currentTimeMillis() - dbg_time >= 1000)) {
						elapsed_time = System.currentTimeMillis() - dbg_time;
						System.out.println((int)(((double)fml.vm.cycles-prev_cycles)/(elapsed_time)) + " KHZ");
						
						System.out.println((int)((
								1 / (((double)(fml.vm.cycles-prev_cycles)/elapsed_time)*1000))*1_000_000_000)+" ns per step");
						
						prev_cycles = fml.vm.cycles;
						dbg_time = System.currentTimeMillis();
					}
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
		setResizable(false);
		setSize(screen_width*scaling_factor, screen_height*scaling_factor);
		add(screen);
		screen.addKeyListener(this);
		pack();
		setVisible(true);
		setResizable(false);
		
		
	}
	

	
	public synchronized void  runMe() throws Exception{
		
		if(running || tick_once){
			vm.step();
		}
		updateScreen();
		
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
				"tmp.fml", "0" };
		try {
			Assembler.main(args);
		} catch (AssemblerError e1) {
			error(e1);
			return;
		}
		loadFile("tmp.fml", 0);
		
	}
	

	
	
	@Override
	public synchronized void keyTyped(KeyEvent e) {

		if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && (int)e.getKeyChar() == 1){
			
			assembleAndLoad();
			return;
		}else if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && ((int)e.getKeyChar() == 19  || (int)e.getKeyChar() == 26 )){
			
			running = true;
			return;
			
		}

		
	}

	
	
	
	@Override
	public synchronized void  keyPressed(KeyEvent e) {
		//System.out.println((int)e.getKeyChar());
		//We need to have this shit here in order to fix the horrible bug of repeating key presses in linux.
		if(repeating_key_block){
			if(System.currentTimeMillis() - repeating_key_timer > repeating_key_timeout){
				repeating_key_block = false;
			}else{
				repeating_key_timer = System.currentTimeMillis();
				
				return;
			}
		}
		
		if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && (int)e.getKeyChar() == 4){
			
			debug = true;
			return;
			
		}else if(e.getModifiersEx() == (InputEvent.CTRL_DOWN_MASK| InputEvent.ALT_DOWN_MASK) && ((int)e.getKeyChar() == 17  )  ){
			//System.out.println("paused");
			running = false;
			return;
		
		}else{
		
			try {
				vm.ram.write((int)e.getKeyChar(), Ram.key_value);
				vm.ram.write(1, Ram.key_down);
				vm.interrupt = true;
				vm.irq = 1;
			} catch (InvalidAddressExcption e1) {
				
				e1.printStackTrace();
			}
		}
		repeating_key_timer = System.currentTimeMillis();
		repeating_key_block = true;
		
	}

	@Override
	public synchronized void keyReleased(KeyEvent e) {
		//We need to have this shit here in order to fix the horrible bug of repeating key presses in linux.
		if(repeating_key_block){
			
			if(System.currentTimeMillis() - repeating_key_timer > repeating_key_timeout){
				repeating_key_block = false;
			}else{
				repeating_key_timer = System.currentTimeMillis();
				
				return;
			}
		}
		
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
				
				e1.printStackTrace();
			}
		}
		repeating_key_timer = System.currentTimeMillis();
		repeating_key_block = true;
	}
	
}
