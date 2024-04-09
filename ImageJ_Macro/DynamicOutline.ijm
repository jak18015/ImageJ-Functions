/*
 * DynamicOutline tries to draw a polygonal selection around the parasite
 * vacuole using thresholding and ROI selections. Normally the coordinates of
 * the polygon are oversampled, and so the polygon is also simplified.
 * 
 * DynamicOutline takes the image title as an argument, either passed as a
 * string [runMacro("DynamicOutline", "image_04.tif");] or a varialbe containing
 * a string:
 * imageTitle = getTitle();
 * runMacro("DynamicOutline", imageTitle);
 */
 
macro "DynamicOutline" {
	imgTitle = getArgument();
	noExtTitle = File.getNameWithoutExtension(imgTitle);
	selectWindow(imgTitle);
	
	resetThreshold;
	run("Select None");
	setTool(2);

	run("Duplicate...", "duplicate");
	d1 = getTitle();
	setAutoThreshold("Triangle dark");
	run("Create Mask");
	msk = getTitle();
	run("Fill Holes");
	run("Gaussian Blur...", "sigma=1.5");
	setAutoThreshold("Triangle dark");
	run("Create Selection");
	Roi.getCoordinates(xpoints, ypoints);
	close(d1);
	close(msk);

	xDiffArray = newArray();
	yDiffArray = newArray();
	
	for(i=0; i < xpoints.length; i++) {
		if (i == 0) {
			xDiff = abs(xpoints[0] - xpoints[xpoints.length-1]);
			yDiff = abs(ypoints[0] - ypoints[ypoints.length-1]);
		}
		if (i == xpoints.length-1) {
			xDiff = abs(xpoints[xpoints.length-1]-xpoints[0]);
			yDiff = abs(ypoints[ypoints.length-1]-ypoints[0]);		
		}
		else {
			xDiff = abs(xpoints[i+1] - xpoints[i]);
			yDiff = abs(ypoints[i+1] - ypoints[i]);
		}
		xDiffArray = Array.concat(xDiffArray, xDiff);
		yDiffArray = Array.concat(yDiffArray, yDiff);
	}

	simpleX = newArray();
	simpleY = newArray();
	
	for(i=0; i < xpoints.length; i++) {
		if (xDiffArray[i] + yDiffArray[i] > 1) {
			simpleX = Array.concat(simpleX, xpoints[i]);
			simpleY = Array.concat(simpleY, ypoints[i]);
		}
	}

	selectWindow(imgTitle);
	run("Duplicate...", "duplicate");
	dup = getTitle();
	close(imgTitle);
	selectWindow(dup);
	rename(imgTitle);
	makeSelection("polygon", simpleX, simpleY);
	setLocation(0.5*screenWidth-250, 0.5*screenHeight-250, 500, 500);
}
