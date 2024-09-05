/* 
  ================================================================================
  # ImageJ Functions
  ================================================================================
	  The same way you can call built-in ImageJ functions like 
	  run("Split Channels..."), custom functions can be created and used 
	  in the same way.
  --------------------------------------------------------------------------------
  ## Absolute basics of IJMacro scripting
  --------------------------------------------------------------------------------
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
  --------------------------------------------------------------------------------
  ## Function basics and definitions of terms
  --------------------------------------------------------------------------------
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
  	--------------------------------------------------------------------------------
  	## Good practices
  	--------------------------------------------------------------------------------
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
  	--------------------------------------------------------------------------------
  	## Returns from a function
  	--------------------------------------------------------------------------------
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
			further processing, save it, or close it later in a script.
   ================================================================================
   # Function List
   ================================================================================
*/
/*
16-bit image -> 32-bit float, rescaled 0-1
The intensity range is maintained, unlike the "Enhance Local Contrast (CLAHE)" function
built into ImageJ, useful for image calculation.
*/
function ImageNormalization(image) {
	setBatchMode("hide");
	selectWindow(image);
	bit = bitDepth() 
	if (bit == 16) {
		type = "16-bit";
		min_x = 0;
		max_x = 65535;
	} else {
		exit("error; bit depth");
	}
	Stack.getDimensions(width, height, channels, slices, frames);
	newImage("norm_"+image, "32-bit", width, height, slices);
	norm_image = getTitle();
	for (x=0; x<width; x++0) {
		for (y=0; y<height; y++) {
			for (z=1; z<=slices; z++) {
				Normalize();
			}
		}
	}
	function Normalize() {
		selectWindow(image);
		setSlice(z);
		px = getPixel(x, y);
		px = (px - min_x) / (max_x - min_x);
		selectWindow(norm_image);
		setSlice(z);
		setPixel(x, y, px);		
	}
	selectWindow(norm_image);
	resetMinAndMax();
	setBatchMode("exit and display");
	return norm_image;
}
/*
adjust brightness-contrast for all channels in a stack
*/
function StackBrightness(image) {
	selectWindow(image);
	resetMinAndMax();
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Split Channels");
	channel_array = newArray();
	for (c=1; c<=channels; c++) {
		channel_image = "C"+c+"-"+image;
		channel_array = Array.concat(channel_array, "c"+c+"="+channel_image);
		selectWindow("C"+c+"-"+image);
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		setMinAndMax(min, 0.5*max);
	}
	arg = String.join(channel_array, " ");
	arg = arg + " create";
	run("Merge Channels...", arg);
}
/*
Convert all DV's in input_dir into TIFF's and save in output_dir 
*/
function DvToTiff(input_dir, output_dir) {
	setBatchMode("hide");
	input_count = getFileList(input_dir);
	input_count = input_count.length;
	metrics = newArray("input filecount  = " + input_count);
	// change Windows-style file separators (if present) into UNIX-style with trailing slash
	input_dir = split(input_dir, File.separator);
	input_dir = String.join(input_dir, "/") + "/";
	output_dir = split(output_dir, File.separator);
	output_dir = String.join(output_dir, "/") + "/";
	// loop files
	filelist = getFileList(input_dir);
	dv_list = newArray();
	for (i=0; i<filelist.length; i++) {
		if (matches(filelist[i], ".*D.dv")) {
			dv_list = Array.concat(dv_list, filelist[i]);
		}
	}
	metrics = Array.concat(metrics, "" + dv_list.length + " .dv images");
	for (i=0; i<dv_list.length; i++) {
		open(input_dir + dv_list[i]);
		x_image = File.getNameWithoutExtension(getTitle());
		saveAs("tiff", output_dir + x_image + ".tif");
		close();
		if (i==0) {
			fontsize = 12;
			Dialog.createNonBlocking("Post-first file check");
			Dialog.addMessage(
				"The file \n\t" + input_dir + dv_list[i] + "\n"
				+ "was saved to:" + "\n"
				+ output_dir + x_image + ".tif", fontsize
			);
			Dialog.addMessage("Is this correct?", 2*fontsize);
			Dialog.addMessage("OK will continue with the rest of the files", fontsize);
			Dialog.addMessage("Cancel will exit the macro", fontsize);
			Dialog.show();
		}
	}
	output_count = getFileList(output_dir);
	output_count = output_count.length;
	metrics = Array.concat(metrics, "output filecount = " + dv_list.length);
	metrics = String.join(metrics, "\n");
	showMessage(metrics);
	setBatchMode("show");
}
/*
adds custom metadata to an image.
*/
function InterphaseToDivision(image) {
	selectWindow(image);
	bad_meta = "cellCycle: interphase";
	meta = getMetadata("Info");
	meta = replace(meta, ".*"+bad_meta+".*", "cellCycle: division");
	setMetadata("Info", meta);	
}
/*
changes custom image metadata
*/
function DivisionToInterphase(image) {
	selectWindow(image);
	bad_meta = "cellCycle: division";
	meta = getMetadata("Info");
	meta = replace(meta, ".*"+bad_meta+".*", "cellCycle: interphase");
	setMetadata("Info", meta);	
}

/*
Creates a dialog from image_list to choose a specific image 
to start a for loop at idx rather than the beginning.
Returns the index of the image_list of the chosen item
replace "for (i=0;..." with "for (i=idx;..." in your for loop
*/
function ImageSelection(image_list) {
	Dialog.createNonBlocking("Image Select...");
	Dialog.addChoice("img", image_list);
	Dialog.show();
	chosen_image = Dialog.getChoice();
	idx = 0;
	for (i=0; i<image_list.length; i++) {
		if (matches(image_list[i], chosen_image)) {
			idx = i;
			break;
		}
	}
	return idx;
}
/*
Organizes the original image and projections of that image to the side.
Returns an array of the projected image titles.
*/
function LayoutProjections(image) {
	menubar_width = 26;
	menubar_height = 56;
	scalar = 4;
	projection_array = newArray("[Max Intensity]", "[Sum Slices]", "Median");
	projected_images = newArray();
	for (p=0; p<projection_array.length; p++) {
		selectWindow(image);
		run("Z Project...", "projection="+projection_array[p]);
		projected_images = Array.concat(projected_images, getTitle());
	}
	selectWindow(image);
	run("Original Scale");
	Stack.getDimensions(width, height, channels, slices, frames);
	setLocation(10, 10, scalar*width+menubar_width, scalar*height+menubar_height);
	getLocationAndSize(main_x, main_y, main_width, main_height);
	subheight = scalar*height/3+menubar_height;
	subwidth = scalar*width + menubar_width;
	
	for (p=0; p<projected_images.length; p++) {
		selectWindow(projected_images[p]);
		setLocation(main_x+main_width, main_y+(subheight*p), subwidth, subheight);
	}
	return projected_images;
}

/*
Uses ROI's in the ROI Manager to create crops of a provided image
Returns an array of the crop image names
*/
function RoiCrop(image) {
	selectWindow(image);
	image_array = newArray();
	for (roi=0; roi<roiManager("count"); roi++) {
		selectWindow(image);
		roi_image = x_image + "-" + roi+1 + ".tif";
		roiManager("select", roi);
		Roi.setProperty("img", roi_image);
		roiManager("update");
		run("Duplicate...", "duplicate");
		rename(roi_image);
		image_array = Array.concat(image_array, roi_image);
	}
	return image_array;
}
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