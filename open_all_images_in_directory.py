import os
from ij import IJ

directory = "D:/Jacob/1-projects/frm2-gfp_verification/data/best"
filelist = os.listdir(directory)

for files in filelist: 
	img = IJ.openImage(os.path.join(directory,files))
	img.show()

