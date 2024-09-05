# ImageJ Functions
The same way you can call built-in ImageJ functions like 
	run("Split Channels..."); 
custom functions can be created and used in the same way.
## Absolute basics of IJMacro scripting
	- It's effectively baby javascript + a sprinkle of python.
	- The IJMacro documentation has every single command listed, google it.
	- Make sure enable autocompletion is on in the options tab above.
	- Plugins -> Macros -> Record is your friend for getting commands.
	- The interpretor uses semi-colons to know when a command stops
	i.e.
		run("Split Channels...") will not run
		run("Split Channels..."); will
	- comments (like all of this text that won't be run) 
	can be made with two forward slashes (//), or you can make a multi-line
	comment using with a forward slash + asterisk at the beginning and an
	asterisk + forward slash at the end, like used here for all of this text.
## Function basics and definitions of terms
	Example:
		function Multiply(a, b) {
			MyFunction_output = a * b;
			return MyFunction_output;
		}
	The FUNCTION "Multiply()" has 2 PARAMETERS called "a" and "b",
	meaning this function requires 2 things in order to work.
	If I want to use this function, I can provide my own ARGUMENTS, 
	in this case two numbers, and Multiply() will return their product.

	Example:
		first_num = 2;
		second_num = 3;
		product = Multiply(first_num, second_num);
		print(product);
			
		function Multiply(a, b) {
			a_times_b = a * b;
			return a_times_b;
		}
		
		[OUTPUT]
		6
		
	So by providing the arguments 2 and 3 to satisfy the parameters 
	of the function Multiply(), I am returned the value 6.
		PARAMETERS are the variables in the declaration of the function
			(a and b)
		ARGUMENTS are the actual values you pass to the function
			(2 and 3)
## Good practices
	It's good practice that a function only needs its parameters and 
	returns a value, which makes that function modular and not tied to 
	a specific use case that can cause frustration down the road.
		
		Good example:
			directory = "Desktop/image_folder/";
			image_name = "image_01.tif";
			SaveImage(directory, image_name);
			
			function SaveImage(dir, img) {
				// below concatenates the two together into the full path.
				image_path = dir + img; 
				save(image_path);
			}
			
				I can now use the function SaveImage()
				to save any image I have, anywhere I want.
		
		Bad example:
			image_name = "image_01.tif";
			SaveImage(image);
			
			function SaveImage(image_name) {
				directory = "C:/Users/username/Desktop/image_folder/";
				save(directory + image_name);
			}
			
				This function is now only good for saving images 
				to one specific folder on one specific computer,
				much less useful . . .
## Returns from a function
	If a function doesn't return something
	(i.e. there is no "return" line at the end),
	Then the function can just be called.
	Example:
		I want to adjust the brightness and contrast 
		of all channels in a 3-channel image called "minusiaa_01.tif".
		
		If I run:
		
			StackBrightness("minusiaa_01.tif");
			
		everything within the function StackBrightness(image) 
		below will be ran. StackBrightness() doesn't return anything
		so just calling it is fine.
		
		However, for a function like ImageNormalization() 
		that does return the name of the normalized image, 
		if I only run:
		
			ImageNormalization("minusiaa_01.tif");
			
		I'll get a normalized image, but without knowing ahead of time what the 
		name of the new image is, I'll have no easy way of getting that inside
		of the script for further processing.
		
		Instead, I can run:
		
			normalized_image = ImageNormalization("minusiaa_01.tif");
			
		Which will do the same thing as before, 
		except I now have a new variable called normalized_image that holds 
		the name of the new image, which I can then use to do 
/*
saves all ROI's to path, then clears the ROI Manager
path should end in ".zip"
*/
function RoiSave(path) {
roiManager("deselect");
roiManager("save", path);
roiManager("delete");
}
/*
saves each image in image_array to the directory dir, then closes the image
*/
function SaveImages(image_array, dir) {
for (img = 0; img<image_array.length; img++) {
	selectWindow(image_array[img]);
	save(dir + image_array[img]);
	close();
}
}
		further processing, save it, or close it later in a script.