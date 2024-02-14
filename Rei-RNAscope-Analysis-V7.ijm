Dialog.create("Please name the channels in order");
Dialog.addString("Channel 1", "DAPI", 5);
Dialog.addString("Channel 2", "488", 5);
Dialog.addString("Channel 3", "561", 5);
Dialog.addString("Channel 4", "640", 5);
Dialog.addString("Channel 5", "730", 5);
Dialog.show();
Ch1 = Dialog.getString();
Ch2 = Dialog.getString();;
Ch3 = Dialog.getString();;;
Ch4 = Dialog.getString();;;;
Ch5 = Dialog.getString();;;;;

inputFolder = getDirectory("Input directory");
outputImages = inputFolder + "Output-Images" + File.separator;
if ( !(File.exists(outputImages)) ) { File.makeDirectory(outputImages); }
Datafiles = inputFolder + "Data-files" + File.separator;
if ( !(File.exists(Datafiles)) ) { File.makeDirectory(Datafiles); }
processFolder(inputFolder);
 
function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i], ".tif"))// change to .tif is needed
            processFile(input, list[i]);
    }
}
 
function processFile(input, file) {
    // do the processing here by replacing
    // the following two lines by your own code
          print("Processing: " + input + file);
    //run("Bio-Formats Importer", "open=" + input + file + " color_mode=Default view=Hyperstack stack_order=XYCZT");
    open(inputFolder + file);

SaveName=getTitle();SaveName2=replace(SaveName,".ome.tif","");
run("Duplicate...", "title=Dup duplicate");run("Z Project...", "projection=[Max Intensity]");rename("MAX");
selectImage("MAX");
Stack.setChannel(1); run("Enhance Contrast", "saturated=0.05");
Stack.setChannel(2); run("Enhance Contrast", "saturated=0.05");
Stack.setChannel(3); run("Enhance Contrast", "saturated=0.05");
Stack.setChannel(4); run("Enhance Contrast", "saturated=0.05");
Stack.setChannel(5); run("Enhance Contrast", "saturated=0.05");

//creating ROIs for analysis
 waitForUser("Using the cursors, please create an ROI around your are of interest: holding Shift down will allow multiple ROIs");
run("ROI Manager...");
roiManager("Add");

//Separating and naming the channels
selectImage("Dup");
run("Split Channels");
selectImage("C5-Dup");
rename(Ch5);
selectImage("C4-Dup");
rename(Ch4);
selectImage("C3-Dup");
rename(Ch3);
selectImage("C2-Dup");
rename(Ch2);
selectImage("C1-Dup");
rename(Ch1);

//Analyzing Ch2
selectImage(Ch2);
run("Subtract Background...", "rolling=11 stack");
run("Enhance Contrast", "saturated=0.35");
run("Unsharp Mask...", "radius=11 mask=0.60 stack");
run("Enhance Contrast", "saturated=0.5");
run("Z Project...", "projection=[Max Intensity]");rename(SaveName2+"_"+Ch2);run("Grays");
run("Enhance Contrast", "saturated=0.35");
roiManager("Select", 0);
//setAutoThreshold("Otsu dark no-reset");
setAutoThreshold("RenyiEntropy dark no-reset");
//setAutoThreshold("RenyiEntropy dark no-reset");
waitForUser("Please check and set the threshold");
//roiManager("Select", 0);
run("Set Measurements...", "area mean standard min perimeter bounding fit shape skewness area_fraction limit redirect=None decimal=3");
run("Analyze Particles...", "size=.5-Infinity show=Masks summarize");
//selectImage("Mask of "+SaveName2+"_"+Ch2);  saveAs("Tiff", outputImages+Ch2+"-Mask_"+SaveName2);
//run("Threshold...");

//Analyzing Ch3
selectImage(Ch3);
run("Subtract Background...", "rolling=11 stack");
run("Enhance Contrast", "saturated=0.35");
run("Unsharp Mask...", "radius=11 mask=0.60 stack");
run("Enhance Contrast", "saturated=0.5");
run("Z Project...", "projection=[Max Intensity]");rename(SaveName2+"_"+Ch3);run("Grays");
run("Enhance Contrast", "saturated=0.35");
roiManager("Select", 0);
//setAutoThreshold("Otsu dark no-reset");
//setAutoThreshold("MaxEntropy dark no-reset");
setAutoThreshold("RenyiEntropy dark no-reset");
waitForUser("Please check and set the threshold");
//roiManager("Select", 0);
run("Analyze Particles...", "size=.5-Infinity show=Masks summarize");
//selectImage("Mask of "+SaveName2+"_"+Ch3);  saveAs("Tiff", outputImages+Ch3+"-Mask_"+SaveName2);

//Analyzing Ch4
selectImage(Ch4);
run("Subtract Background...", "rolling=11 stack");
run("Enhance Contrast", "saturated=0.5");
run("Unsharp Mask...", "radius=11 mask=0.60 stack");
run("Enhance Contrast", "saturated=0.35");
run("Z Project...", "projection=[Max Intensity]");rename(SaveName2+"_"+Ch4);run("Grays");
run("Enhance Contrast", "saturated=0.35");
roiManager("Select", 0);
//setAutoThreshold("Otsu dark no-reset");
setAutoThreshold("RenyiEntropy dark no-reset");
//setAutoThreshold("RenyiEntropy dark no-reset");
waitForUser("Please check and set the threshold");
//roiManager("Select", 0);
run("Analyze Particles...", "size=.5-Infinity show=Masks summarize");
//selectImage("Mask of "+SaveName2+"_"+Ch4);  saveAs("Tiff", outputImages+Ch4+"-Mask_"+SaveName2);

//Analyzing Ch5
selectImage(Ch5);
run("Subtract Background...", "rolling=11 stack");
run("Enhance Contrast", "saturated=0.35");
run("Unsharp Mask...", "radius=11 mask=0.60 stack");
run("Enhance Contrast", "saturated=0.5");
run("Z Project...", "projection=[Max Intensity]");rename(SaveName2+"_"+Ch5);run("Grays");
run("Enhance Contrast", "saturated=0.35");
roiManager("Select", 0);
//setAutoThreshold("Otsu dark no-reset");
setAutoThreshold("RenyiEntropy dark no-reset");
//setAutoThreshold("RenyiEntropy dark no-reset");
waitForUser("Please check and set the threshold");
//roiManager("Select", 0);
run("Analyze Particles...", "size=.5-Infinity show=Masks summarize");
//selectImage("Mask of "+SaveName2+"_"+Ch5);  saveAs("Tiff", outputImages+Ch5+"-Mask_"+SaveName2);

//Analyzing for area from Dapi
selectImage(Ch1);rename ("Area");
run("Z Project...", "projection=[Max Intensity]");rename ("Area");
run("Median...", "radius=6");
run("Enhance Contrast", "saturated=0.5");run("Grays");
roiManager("Select", 0);
setThreshold(90, 65535, "raw");
run("Analyze Particles...", "size=100-Infinity show=Masks summarize");
//selectImage("Mask of Area");  saveAs("Tiff", outputImages+"Area-Mask_"+SaveName2);


//Asking if you want to save the current data
Dialog.create("Do you want to save this dataset?");
Dialog.addCheckbox("Yes", true);
Dialog.show();
Pos=Dialog.getCheckbox();

if (Pos==true) {

//Saving Summary file
selectImage("Mask of "+SaveName2+"_"+Ch2);  saveAs("Tiff", outputImages+Ch2+"-Mask_"+SaveName2);
selectImage("Mask of "+SaveName2+"_"+Ch3);  saveAs("Tiff", outputImages+Ch3+"-Mask_"+SaveName2);
selectImage("Mask of "+SaveName2+"_"+Ch4);  saveAs("Tiff", outputImages+Ch4+"-Mask_"+SaveName2);
selectImage("Mask of "+SaveName2+"_"+Ch5);  saveAs("Tiff", outputImages+Ch5+"-Mask_"+SaveName2);
selectImage("Mask of Area");  saveAs("Tiff", outputImages+"Area-Mask_"+SaveName2);
selectWindow("Summary"); Table.save(Datafiles+"SUM_"+SaveName2+".csv");
}
selectWindow("Summary"); run("Close");
roiManager("Reset");
run("Close All");
}

