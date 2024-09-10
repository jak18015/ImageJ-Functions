# ImageJ Functions
The same way you can call built-in ImageJ functions like

	run("Split Channels..."); 

custom functions can be created and used in the same way.
## Absolute basics of IJMacro scripting
- It's effectively baby javascript + a sprinkle of python.
- The IJMacro documentation has every single command listed, google it.
- Make sure enable autocompletion is on in the ImageJ script editor
- Plugins -> Macros -> Record is your friend for getting commands.
- The interpretor uses semi-colons to know when a command stops
i.e.

	This will give an error:

		run("Split Channels...") // missing semi-colon

	This will run
	
		run("Split Channels...");


- comments can be made with two forward slashes (//), or you can make a multi-line comment using with a forward slash + asterisk at the beginning and an asterisk + forward slash at the end.

```javascript
run("Split Channels..."); // a comment that gets ignored
/*
a multi-line comment that also gets ignored
*/
```
## Function basics and definitions of terms
Example function:
```javascript
	function Multiply(a, b) {
		MyFunction_output = a * b;
		return MyFunction_output;
	}
```
"Multiply()" has 2 **PARAMETERS** called "a" and "b",
meaning this function requires 2 things in order to work.
If I want to use this function, I can provide my own **ARGUMENTS** to satisfy the parameters, 
in this case two numbers, and Multiply() will return their product.
```javascript
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
```	
So by providing the arguments 2 and 3 to satisfy the parameters 
of the function Multiply(), I am returned the value 6.
	PARAMETERS are the variables in the declaration of the function
		(a and b)
	ARGUMENTS are the actual values you pass to the function
		(2 and 3)

Even though the function comes after the commands that use it, this will still work because functions are asynchronous, meaning that unlike the rest of your code that runs line by line, functions are already in memory before the first line is executed.
## Good practices
It's good practice that a function only needs its parameters and 
returns a value, which makes that function modular and not tied to 
a specific use case that can cause frustration down the road.
	
Good example:
```javascript
directory = "Desktop/image_folder/";
image_name = "image_01.tif";
SaveImage(directory, image_name);

function SaveImage(dir, img) {
	// below concatenates the two together into the full path.
	image_path = dir + img; 
	save(image_path);
}
```
I can now use the function SaveImage() to save any image I have, anywhere I want.

Bad example:
```javascript
image_name = "image_01.tif";
SaveImage(image_name);

function SaveImage(img) {
	directory = "C:/Users/username/Desktop/image_folder/";
	// below concatenates the two together into the full path.
	image_path = dir + img; 
	save(image_path);
}
```
I can still save any image I want, but because I've "hardcoded" a directory into the function, it can only save images to that one specific folder, unlike the good example above.
## Returns from a function
If a function doesn't return something (i.e. there is no "return" line at the end), then the function can just be called.

Example:
- I want to adjust the brightness and contrast of all channels in a 3-channel image called "minusiaa_01.tif" using a function I created called StackBrightness(). StackBrightness() has only 1 parameter for the image name.

	- If I run:
	```javascript
		StackBrightness("minusiaa_01.tif");
	```
	everything within the function `StackBrightness(image);`
	will be ran on the specified image. Since `StackBrightness()` doesn't return anything, just calling it is fine.
	
	However, another function I've created that normalizes all pixel values between 0 and 1 called `ImageNormalization()` does return the name of the newly created 32-bit image. 
	
	If I run:
	```javascript	
		ImageNormalization("minusiaa_01.tif");
	```
	I'll get a normalized image, but without knowing ahead of time what the 
	name of the new image is and hardcoding for it, I'll have no easy way of getting that inside
	of the script for further processing.
	
	Instead, I can run:
	```javascript
		normalized_image = ImageNormalization("minusiaa_01.tif");
	```
	Which will still create the new image, but `ImageNormalization()` returns the name of the newly created image that I have captured inside the variable `normalized_image`, meaning I can then use commands like `selectWindow(normalized_image);` to select that image and do further processing on it, save it to a specific directory, or close it.

