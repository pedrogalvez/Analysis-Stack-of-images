//Data analysis II - Test4 - highpowersomefilter
//This macro takes a set of stacks in the XY plane (they have already been cropped and rotated), 
//and processes them (filtering and segmentation) in the plane XY


//Destination Folder
roi_xy = "F:\\CT-Scans_data\\In-Process 2017\\01. In_process_2017_LauraPickard\\03. Analysis_Test4_Highpowersomefilter\\00. ROI_XY_Test4\\";

for (i = 2 ; i<=44 ; i++){

	var step = i; //Time-step we are analyzing
	var time = "t" + step + "\\";
	
	// Input folder -> We take the image stacks from here
	input_dir = "E:\\Test4_highpowersomefiltering\\" + time + "Test 4\\Test 4.vol";

	//Output directory
	output_dir_xy = roi_xy + "t" + step + "_xy\\";
	File.makeDirectory(output_dir_xy);

	//Creation of sub__folders in order to save the modified stacks

	var xy_orig = "t" + step + "_xy_orig_test4";
	var xy_filter = "t" + step + "_xy_filter_test4";
	var xy_binary = "t" + step + "_xy_binary_test4";

	output_dir_xy_orig = output_dir_xy + xy_orig;
	File.makeDirectory(output_dir_xy_orig);
	output_dir_xy_filter = output_dir_xy + xy_filter;
	File.makeDirectory(output_dir_xy_filter);
	output_dir_xy_binary= output_dir_xy + xy_binary;
	File.makeDirectory(output_dir_xy_binary);

	//Open .Vol data as Raw Data
	run("Raw...", "open=[" + input_dir + "] image=[32-bit Real] width=2000 height=2000 number=480 little-endian");

	//ANALYSIS
	
	//Remove Slices so that we keep only the slices [135 - 270]
	run("Slice Remover", "first=1 last=134 increment=1");
	run("Slice Remover", "first=136 last=346 increment=1");

	// Rotate the image 24.5 degrees
	run("Rotate... ", "angle=24.5 grid=1 interpolation=Bilinear stack");

	//ROI --> setTool("rectangle");
	makeRectangle(399, 621, 1296, 567);
	run("Specify...", "width=1266 height=333 x=356 y=849 slice=150");
	run("Duplicate...", "duplicate");
	selectWindow("Test 4.vol");
	selectWindow("Test 4-1.vol");
	selectWindow("Test 4.vol");
	close();
	selectWindow("Test 4-1.vol");
	run("Image Sequence... ", "format=TIFF name=slice_ save=[" + output_dir_xy_orig + "\\slice_0000.tif" + "]"); //Save the set of original images
	
	//Filter: 3D-Mean (Radius=3R)
	run("Mean 3D...", "x=3 y=3 z=3");
	run("Image Sequence... ", "format=TIFF name=slice_ save=[" + output_dir_xy_filter + "\\slice_0000.tif" + "]"); //Save this filtered image
	run("8-bit"); // Conversion to 8bit image

	//Thresholded Image
	setAutoThreshold("Default stack"); // Apply threshold to the whole stack
	setThreshold(0, 128); 
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Light");
	run("Invert", "stack"); //Invert the threshold so that the object is the air for our application
	run("Image Sequence... ", "format=TIFF name=slice_ save=[" + output_dir_xy_binary + "\\slice_0000.tif" + "]"); //Save the thresholded image
	close();

	
}
