macro "dirMaker" {
	x = getArgument();
	if (File.exists(x) == false) {
		File.makeDirectory(x);
	}
}