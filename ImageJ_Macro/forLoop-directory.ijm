directory = "D:/Jacob/3-resources/microscopy/20230925-myof-aid-ac-emfp/";
list = getFileList(directory);

for(i=0;i<list.length;i++){
	if (matches(list[i], ".*D3D.dv")){
		print(directory+list[i]);
	}
}