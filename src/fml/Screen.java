package fml;

import java.awt.Canvas;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.awt.image.WritableRaster;


public class Screen extends Canvas {
	
	int[] bitmap;
	int width;
	int height;
	int size;
	BufferedImage buffer1;
	BufferedImage buffer2;
	Graphics2D g;
	int buffer = 0;
	
	
	public static Image getImageFromArray(int[] pixels, int width, int height) {
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        WritableRaster raster = (WritableRaster) image.getRaster();
        raster.setPixels(0,0,width,height,pixels);
        return image;
    }
	
	
	public Screen(int width, int height,int size){
		
		setSize(width*size, height*size);
		bitmap = new int[width*height]; 
		this.width = width;
		this.height = height;
		this.size = size;
		buffer1 = new BufferedImage(width*size, height*size, BufferedImage.TYPE_INT_ARGB);
		buffer2 = new BufferedImage(width*size, height*size, BufferedImage.TYPE_INT_ARGB);
		g = buffer1.createGraphics();
	}
	
	public void setBitmap(int[] bitmap){
		int[] temp = new int[bitmap.length*3];
		int j = 0;
		for (int i = 0; i < bitmap.length; i++) {
			temp[j] = (int)((((double)bitmap[i])/255) * Integer.MAX_VALUE); 
			temp[j+1] = (int)((((double)bitmap[i])/255) * Integer.MAX_VALUE);
			temp[j+2] = (int)((((double)bitmap[i])/255) * Integer.MAX_VALUE);

			j += 3; 
		}
		this.bitmap = temp;
	}
	
	public void drawScreen(){
		if(buffer == 0){
			buffer1 =  (BufferedImage) getImageFromArray(bitmap, width, height);
		}else{
			buffer2 =  (BufferedImage) getImageFromArray(bitmap, width, height);
		}
	}
	
	public void paint(Graphics g1){
		Graphics2D g2 = ((Graphics2D) g1);
		
		if(buffer == 0){
			BufferedImage rescaled = new BufferedImage(width*size,height*size,BufferedImage.TYPE_INT_ARGB);
			rescaled.getGraphics().drawImage(buffer1, 0, 0, width*size, height*size, null);
			g2.drawImage( rescaled, null, 0, 0);
			g2.dispose();
		}else{
			BufferedImage rescaled = new BufferedImage(width*size,height*size,BufferedImage.TYPE_INT_ARGB);
			rescaled.getGraphics().drawImage(buffer2, 0, 0, width*size, height*size, null);
			g2.drawImage( rescaled, null, 0, 0);
			g2.dispose();
		}
		flip();
		
	}
	

	
	
	public void flip(){
		if(buffer == 0){
			g.dispose();
			g = (Graphics2D) buffer1.getGraphics();
			buffer = 1;
		}else{
			g.dispose();
			g = (Graphics2D) buffer2.getGraphics();
			buffer = 0;
		}
	}
}

