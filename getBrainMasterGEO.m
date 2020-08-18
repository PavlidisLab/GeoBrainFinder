function getBrainMasterGEO(geoStart, geoEnd, varargin)
disp(sprintf('\n\n\n'))
clc
userDir = cd;
runGemma = 1;
myfilename = 'noneToSkip';
numWorkers = maxNumCompThreads;
lastGemmaID = 15000;
varargin = varargin';
for i = 1:length(varargin)   
    if mod(i,2) == 1
        if string(varargin{i,1}) == "fileToSkip"
            myfilename = char(varargin{i+1,1});
        elseif string(varargin{i,1}) == "runGemma"
            runGemma = double(varargin{i+1,1});
        elseif string(varargin{i,1}) == "numThreads"
            numWorkers = double(varargin{i+1,1});
        else disp(strcat("Typo found in name of parameter: ",varargin{i,1}, ". Use one of: 'fileToSkip', 'runGemma', or 'numThreads'"));
            if get(0, 'ScreenSize') == [1,1,1024,768] exit(), else return;,end
        end
    end
end
% commented line: cd /space/grp/asharma/getBrainExps : for github use, if you want to save the getBrainMaster in a different location, add the cd line with the folder containing all the rest of the files
cd src
y = getBrainExpsFromGEO(geoStart,geoEnd, 1,myfilename,numWorkers, runGemma, userDir);
cd(userDir)
if get(0, 'ScreenSize') == [1,1,1024,768] exit(), else return;,end
end
