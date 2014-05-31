package fml;

import java.awt.Canvas;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;


public class Screen extends Canvas {
	
	int[] bitmap;
	int width;
	int height;
	int size;
	
	public Screen(int width, int height,int size){
		setSize(width*size, height*size);
		bitmap = new int[width*height]; 
		this.width = width;
		this.height = height;
		this.size = size;
	}
	
	public void setBitmap(int[] bitmap){
		this.bitmap = bitmap;
	}
	
	public void paint(Graphics g1){
		Graphics2D g = ((Graphics2D) g1);
		int x = 0;
		int y = 0;
		for (int i = 0; i < height; i++) {
			for (int j = 0; j < width; j++) {
				
				g.setColor(new Color(bitmap[j+height*i],bitmap[j+height*i],bitmap[j+height*i]));
				g.fillRect(x, y, x+size, y+size);
				
				x += size;
			}
			x = 0;
			y += size;
		}
	}
}
