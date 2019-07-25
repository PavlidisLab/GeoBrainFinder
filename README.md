# GeoBrainFinder
Built on Matlab R2018a 

Finds "Brain" experiments on GEO by parsing individual experiment and sample pages in the specified range of accession numbers. 


Steps to run: 
1) Clone this repository
2) Run Matlab R2018a (or newer) and set your working directory to this repository (Note: the file "getBrainMasterGEO.m" should be in your working directory). For ex. use: cd /xxx/../GeoBrainFinder
3) Run the function: getBrainMasterGEO(gseStartAccession, gseEndAccession, ...) 

where
(a) gseStartAccesion is a GSE accession number (type: char). For ex : 'GSE1'
(b) gseEndAccession is a GSE accession number > gseStartAccession (type: char). For ex: 'GSE100'
--------   Other optional arguments include:  --------
(c) 'numThreads' : number of parallel threads to run (type double)
(d) 'fileToSkip' : a txt file name with GSE accessions to skip .. with all accessions on new lines (type char)  
(e) 'runGemma' : whether or not to make a gemma call (0 or 1)
(f) 'gemmaLasteeID' : last Gemma accession for the gemma call. By default the call is made from accession 1 to 15000. But you can specify the caller to call the Gemma API from 1 to gemmaLasteeID (type double)

Optional arguments are passed as: field, value pairs. 
Here's an example of all arguments being used: 
getBrainMasterGEO('GSE1','GSE133000', 'numThreads',54, 'runGemma',1,'fileToSkip','blacklistedExpsFile', 'gemmaLasteeID',16000); 

See the documentation on the pavlab wiki page for more information and documentation. 
