/*
 * CenterImage will center the image specified in the 
 * runMacro() function as a string argument.
 * The title of the image should be given as an explicit string or as a variable
 * containing the image title string.
 * 
 * Examples:
 * runMacro("CenterImage", "image_04.tif");
 * 
 * imageTitle = getTitle();
 * runMacro("CenterImage", imageTitle);
 */

macro "CenterImage" {
	imgTitle = getArgument();
	selectWindow(imgTitle);
	getLocationAndSize(x, y, width, height);
	setLocation(0.5*screenWidth - 0.5*width, 0.5*screenHeight - 0.5*height, width, height);
}
