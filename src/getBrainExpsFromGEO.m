function Output = getBrainExpsFromGEO( geoStart, geoEnd, startLookingFromIndex, Inputfile, numWorkers, runGemma, myDir, varargin);
% main file that sets up parallel threads, calls gemma API, reads the skip file, and then in a parfor loop goes through the required GSEs, then calls the script processing_and_..._actual for stage 2 of cleaning/and saving to csv files 

%checks if previous unclosed parallel threads exist, (happens if program crashes, pauses etc.) closes them if needed before opening more threads
if ~isempty(gcp('nocreate')) 
disp("Prior unclosed matlab threads detected... ")
disp("Shutting down previously open threads")
delete(gcp);
end
if numWorkers>2*maxNumCompThreads
disp('Number of threads specified seems to be greater than # of physical + logical cores detected... Trying to test if parallel loop can be created...')
try
	if isempty(gcp('nocreate')) 
	parpool('local',numWorkers);
    else delete(gcp)
        Output = getBrainExpsFromGEO( geoStart, geoEnd, startLookingFromIndex, Inputfile, numWorkers, runGemma, myDir, varargin);
        return
    end
catch ME
    switch ME.identifier
        case 'parallel:cluster:LocalProfileNumWorkersExceeded'
        disp(ME.message)
        disp("Program shutting down since the number of threads requested exceeds machine capacity")
        disp(strcat("Hint: try rerunning the command with: ", string(2*maxNumCompThreads)," threads or less (OR 'preferably' run command on a bigger server)"))
	Output = 0;
        return
    end
end
end

% if specified workers is set to > 64, resets to 48, any more than 48 is not efficient since GEO starts kicking workers out if too many calls are placed
if numWorkers>64
    numWorkers = 48;
    warning('Specified workers to run was set to more than 64... resetting numThreads to 48')
end
if numWorkers >= 32 || numWorkers > maxNumCompThreads
    disp('Number of threads was set to more than the number of physical cores... Setting multithreading "on" for the active workers.')
    myParcluster = parcluster; 
    myParcluster.NumWorkers = numWorkers;
end

if string(geoEnd) == "autodetect" 
geoEnd = strcat('GSE',num2str(max(getLastFewMonthsGEO(3))));
disp(strcat("Detected ", string(geoEnd), " as the last GEO accession available"))
end

alwaysB = [str2num(geoStart(4:end)) : str2num(geoEnd(4:end)) ]';
A = alwaysB(startLookingFromIndex:end);
toSkip = [];

% calls gemma api: getGemmaInfo function file, gemmaEndAccession usually comes from the user file (which is downloaded from the wiki page) and adds the information to the "toSkip" accession list
if runGemma
gemmaIDlast = 10;
if length(varargin) ==1 gemmaIDlast = varargin{1,1};, end
disp('Fetching accessions already on Gemma (to skip)')
[y,z] = getGemmaInfo(-1,gemmaIDlast);

assignin('base','y',y)
assignin('base','z',z)

toSkip = parseGseAccession(z);
disp(strcat('Gemma API: Fetching complete... GEO accession list to skip obtained from Gemma'))
disp(" ");
else disp('User failed to call Gemma API, generated list might have experiments already on Gemma, unless manually put in the skipped file')
end
% similar to the gemma call, this section reads accessions from the inputfile specified to skip accessions
if string(Inputfile) ~= "noneToSkip"
    try 
tempCd = cd;
cd(myDir)
fileID = fopen(Inputfile);
scanned = textscan(fileID,'%s');
fclose(fileID);
cd(tempCd)
scannedArray = parseGseAccession(string(scanned{:,:}));
toSkip = [toSkip ; scannedArray];
disp(strcat("Skipped file: ", Inputfile, " read successfully"))
    catch ME
        warning('Something went wrong with reading file with accessions to skip, (most likely, the file name is wrong). Close and re-run program with the correct file name (TXT file) to include accessions to skip. This step will be skipped for now')
	disp(ME.identifier)
    end
else disp('User chose to not upload GSE accessions to skip')
end
disp(" ")

A = setdiff(A,toSkip);

%if length(varargin) ==1 A = varargin{1,1}, end  %% Override selection of double A, line useful in dev stage or debugging


if exist('Output','var')  , else Output = cell(length(A),2); end


if isempty(gcp('nocreate')) 
parpool('local',numWorkers);
end
% ppm = ParforProgressbar(length(A));
% sets weboptions and displays estimated time of completion for phase 1 since it takes a long time to run
[a,b] = size(A);
options = weboptions;
options.Timeout = 10000;
options.CertificateFilename = '';
disp('Running phase 1: Gathering and parsing GEO Data (Takes ~5 sec for 1 GEO experiment including its sample pages)')
disp('Estimated date and time of completion of Phase 1:')
disp(datetime() + hours(1.368*6.5*length(A)/numWorkers/3600))

% Stage that gathers and reads GEO pages, by calling the function "run"
tic
parfor i = 1:length(A)
        Output{i,2} = run(i,A,0);
        %ppm.increment();
end
disp(sprintf("\n\nPhase 1: first pass finished on %s... Will now check for skipped experiments",datetime()))

% goes through the list 4 times to re-do skipped accessions (skipped in case GEO kicked a worker out etc.) 
myCounter = 4;
while and(testIfReRunsLeft(Output),myCounter>0)
    pause(5)
    fprintf("\nNumber of re-trying for loops left: %s\n",string(myCounter))
    Output = helperRedoReruns(Output,A);
    pause(40)
    myCounter = myCounter - 1;
end

logse = listReRunsLeft(Output);
if ~isempty(logse{1,1})
fprintf("The following accessions could not be read: ")
for i = 1:size(logse,1)
    fprintf(logse(i,1))
    fprintf(",")
end
end
disp(" ");

disp(sprintf('\nPhase 2: Starting cleaning and processing parsed data...'))
for i = 1:size(Output,1)
    Output(i,1:20) = Output{i,2};
end
assignin('base','Output',Output)
clear myParcluster
save nextAutoSave
delete(gcp)
myDir = myDir;
processing_and_cleaning_scrape_data_actual
end

function h = helperRedoReruns(fullOutput,A)
fprintf("Re-running : ")
for i = 1: size(fullOutput,1)
    if contains(fullOutput{i,2}{1,2},"re-run")
        fprintf(strcat("GSE",string(A(i,1))," "))
        fullOutput{i,2} = run(i,A,0);
    end
end
h = fullOutput;
end
function runOrNo = testIfReRunsLeft(A);
runOrNo = 0;
for i = 1:size(A,1)
    if contains(A{i,2}{1,2},"re-run")
        runOrNo = 1;
    end
end
end

function logse = listReRunsLeft(A);
logse = "";
for i = 1:size(A,1)
    if contains(A{i,2}{1,2},"re-run")
        logse(i,1) = strcat("GSE",string(A{i,2}{1,1}));
    end
end
end
