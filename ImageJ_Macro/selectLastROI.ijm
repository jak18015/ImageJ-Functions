macro "selectLastROI" {
	roiCount = roiManager("count");
	roiManager("select", roiCount-1);
}
