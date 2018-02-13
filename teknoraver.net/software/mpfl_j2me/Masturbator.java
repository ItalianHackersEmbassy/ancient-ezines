/*
Masturbator Pro - A J2ME program for women's pleasure
Copyright (C) 2007  Matteo Croce <rootkit85@yahoo.it>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import java.io.IOException;

import java.util.Random;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;
import javax.microedition.lcdui.Choice;
import javax.microedition.lcdui.ChoiceGroup;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.CommandListener;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.Displayable;
import javax.microedition.lcdui.Form;
import javax.microedition.lcdui.Gauge;
import javax.microedition.lcdui.Image;
import javax.microedition.lcdui.Item;
import javax.microedition.lcdui.ItemStateListener;

import javax.microedition.midlet.MIDlet;

public final class Masturbator extends MIDlet implements Runnable, CommandListener, ItemStateListener {
	private final ChoiceGroup mode = new ChoiceGroup("Vibration", Choice.EXCLUSIVE, new String[]{"Continuous", "Alternate", "Random"}, null);
	private Gauge speed = new Gauge("Speed", true, 9, 5);
	private final Form form = new Form("Masturbator Pro", new Item[]{mode});
	private Display display;
	private Image icon;
	private int vibrationTime = 1000, sleepTime = 900, rep;
	private Random rnd = new Random();

	public Masturbator() {
		form.append("by Matteo Croce");
		form.addCommand(new Command("About", Command.SCREEN, 2));
		form.addCommand(new Command("Exit", Command.EXIT, 3));
		form.addCommand(new Command("Pause", Command.STOP, 1));
		form.setCommandListener(this);
		form.setItemStateListener(this);
		try {
			icon = Image.createImage("/icon.png");
		} catch(IOException ioe) { }
		display = Display.getDisplay(this);
		display.setCurrent(form);
		new Thread(this).start();
	}

	public void itemStateChanged(Item item)
	{
		display.vibrate(0);
		if(item == mode)
			if(mode.getSelectedIndex() == 0) {
				if(form.size() == 3)
					form.delete(1);
				vibrationTime = 1000;
				sleepTime = 900;
			} else if(mode.getSelectedIndex() == 1) {
				form.insert(1, speed);
				vibrationTime = (10 - ((Gauge)speed).getValue()) * 100;
				sleepTime = (10 - ((Gauge)speed).getValue()) * 200;
			} else /*if(mode.getSelectedIndex() == 2)*/ {
				if(form.size() == 3)
					form.delete(1);
			}
		else if(item == speed) {
			vibrationTime = (10 - ((Gauge)speed).getValue()) * 100;
			sleepTime = (10 - ((Gauge)speed).getValue()) * 200;
		}
	}

	public void run() {
		while(true) {
			if(mode.getSelectedIndex() == 2 && (rep++ & 3) == 0) {
				vibrationTime = Math.abs(rnd.nextInt()) % 900 + 100;
				sleepTime = Math.abs(rnd.nextInt()) % 900 + 100 + vibrationTime;
			}
			display.vibrate(vibrationTime);
			try {
				Thread.sleep(sleepTime);
			} catch(InterruptedException i) { }
		}
	}

	public void commandAction(Command cmd, Displayable dsp) {
		if(cmd.getCommandType() == Command.EXIT)
			notifyDestroyed();
		else if(cmd.getCommandType() == Command.SCREEN) {
			Alert alert = new Alert("Masturbator Pro", "Masturbator Pro\nA program for women pleasure\nby Matteo Croce <rootkit85@yahoo.it>\nhttp://teknoraver.net/", icon, AlertType.INFO);
			alert.setTimeout(Alert.FOREVER);
			display.setCurrent(alert);
		} else if(cmd.getCommandType() == Command.STOP) {
			mode.setSelectedIndex(0, true);
			if(form.size() == 3)
				form.delete(1);
			vibrationTime = 0;
			sleepTime = 100;
		}
	}

	protected void startApp() { }
	protected void pauseApp() { }
	protected void destroyApp(boolean unconditional) { }
}
