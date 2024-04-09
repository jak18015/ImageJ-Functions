/*
 * DynamiCrop tries to actively draw a bounding rectangle around the vacuole,
 * and then provides a dialogue option to be able to adjust box size and to
 * confirm the crop once accepted.
 * The original file is duplicated, so no effect occurs to the original file.
 * 
 * DynamiCrop takes a string argument for the name of the image.
 * 
 * Examples:
 * imgTitle = getTitle();
 * runMacro("DynamiCrop", imgTitle);
 * 
 * runMacro("DynamiCrop", "image_04.tif");
 */

macro "DynamiCrop" {
	squareSize = 800;
	centeringValue = squareSize/2;
	
	imgTitle = getArgument();
	noExtTitle = File.getNameWithoutExtension(imgTitle);
	selectWindow(imgTitle);
	Overlay.remove;
	Stack.getDimensions(width, height, channels, slices, frames);
	setLocation(10, 10, 256, 256);
	run("Duplicate...", "duplicate");
	dup = getTitle();
	setLocation(screenWidth/2-centeringValue, screenHeight/2-centeringValue, squareSize, squareSize);
	resetMinAndMax;
	
	setTool(0);
	selectWindow(dup);
	setAutoThreshold();
	run("Create Selection");
	getBoundingRect(x, y, width, height);
	resetThreshold;
	run("Select None");
	makeRectangle(x-10, y-10, width+20, height+20);
	waitForUser("Adjust rectangle size");
	roiManager("add");
	roiCount = roiManager("count");
	roiIndex = roiCount - 1;
	roiManager("select", roiIndex);
	roiName = Roi.getName;
	roiManager("rename", roiName + "_" + noExtTitle);
	roiName = Roi.getName;
	
	run("Crop");
	
	if (getBoolean("Confirm correct crop") == false) {
		close(dup);
		selectWindow(imgTitle);
		run("Select None");
		roiManager("deselect");
		roiManager("delete");
		selectWindow(imgTitle);
		title = getTitle();
		runMacro("dynamicCrop", title);	
	}else {
		// Original image closed and the duplicate renamed to the original's title
		selectWindow(imgTitle);
		oldTitle = getTitle();
		close(imgTitle);
		selectWindow(dup);
		rename(oldTitle);
		
	}
}
