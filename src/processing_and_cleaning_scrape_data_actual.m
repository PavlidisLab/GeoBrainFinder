disp('Starting Phase 2: Cleaning and Ranking Data')
load('BRAIN_PARTS')

tempOutput = Output;
if size(Output,1) == 0 disp("No experiments were found with the given parameters"); return;, end 
%% processing 0: get only MESO/DRUG hits out 
fprintf('Cleaning: Getting hits out, ')

[a,b] = size(tempOutput);
for y = [3:6,16:19]
for i=1:a
    if isempty(tempOutput{i,y})
        tempOutput{i,y} = 0;
    else tempOutput{i,y} = tempOutput{i,y}/2;
    end
end
end
for i = 1:a
tempOutput{i,21} = tempOutput{i,3} + tempOutput{i,4} + tempOutput{i,5} + tempOutput{i,6} + tempOutput{i,16}+ tempOutput{i,18};
end
re_processed2 = tempOutput( ~(string(tempOutput(:,21)) == "0") , [1:20]);
 
% Processing 1: clean out tumor terms :: this is to look for oma not in
% terms
fprintf("cancer terms, ")
re_processed2(:,21) = {[]};
for i=1:size(re_processed2,1)
if contains(lower(re_processed2{i,13}),hits) == true
if contains(lower(re_processed2{i,13}),terms) == true
re_processed2(i,21) = {0};
else re_processed2(i,21) = {1};
end
else re_processed2(i,21) = {0};
end
end
re_processed3 = re_processed2( string(re_processed2(:,21)) == "0" ,1:20);
 

 
%% remove other species 
% % %   for i=1:length(re_processed4)  % to get unique temp species used 
% % % temp = [temp ; string(re_processed4{i,2})];
% % %   end
fprintf("species, ")
re_processed4 = re_processed3;
re_processed4(:,21) = {[]};
for i=1:size(re_processed4,1) 
    if sum(contains(re_processed4{i,12},["rat";"mus";"homo"] ,'ignorecase', true)) >0
        
        check = setdiff(mystrfind(re_processed4{i,12},["rat";"mus";"homo"]) - 1,0);
        myStr = char(re_processed4{i,12});
        if isempty(check) || sum(isletter(myStr(check))) < length(check)         
        re_processed4(i,21) = {1};
        else re_processed4(i,21) = {0};
        end

        
        
    else re_processed4(i,21) = {0};
    end
end 
re_processed5 = re_processed4( string(re_processed4(:,21)) == "1" ,1:20  );
 
%% Get geo data to parse futher into platform and Methylation/array type 
re_processed5(:,21) = {[]};
for i=1:size(re_processed5,1)
    if contains(lower(re_processed5{i,13}),tumorterms) == true
        re_processed5(i,21) = {1};
    else re_processed5(i,21) = {0};
    end
end
re_processed6 = re_processed5( string(re_processed5(:,21)) == "0" ,1:20  );
 

 
%% Filter out expTypes which are needed - array MPSS and High throughput 
fprintf("choosing platform types, ")
re_processed6(:,21) = {[]};
for i=1:size(re_processed6,1)
    if sum(contains(re_processed6{i,14},expTypesNeeded)) > 0 
        re_processed6(i,21) = {1};
    else re_processed6(i,21) = {0};
    end
end
re_processed7 = re_processed6( string(re_processed6(:,21)) == "1" ,1:20);
 
%% sample size filter 
fprintf("restrincting sample size to 0<ss<250")
re_processed7(:,21) = {[]};
for i=1:size(re_processed7,1)
% re_processed7(i,11) = {string(extractBetween(re_processed7(i,10),'<td>Samples (',')'))};
if and(double(re_processed7{i,7})>5 , re_processed7{i,7} < 250) 
    re_processed7(i,21) = {1};
else re_processed7(i,21) = {0};
end
end
re_processed7 = re_processed7( string(re_processed7(:,21)) == "1" ,1:20);
 
%% check if sample organism is Human rat or mouse || 1 is good filter


re_processed8 = re_processed7;

%% Filter title liver, heart etc  || 1 means remove
fprintf("reading title, and filtering...")
re_processed8(:,21) = {[]};
temp = re_processed8;
for i=1:size(temp,1) 
    if contains(temp{i,13},[OtherParts;"single cell";"single-cell"] ,'ignorecase', true) == 1
        temp(i,21) = {1};
    else temp(i,21) = {0};
    end
end
re_processed8 = temp( string(temp(:,21)) == "0" ,1:20);
 

 
 
%% find supersubseries column 16 has 1=super/subseries 0 = no 

re_nonsubsuper = re_processed8( string(re_processed8(:,20)) == "0" ,1:19);
re_subsuper = re_processed8( or(string(re_processed8(:,20)) == "1" ,string(re_processed8(:,20)) == "2"),1:19);
% save nextAutoSave
disp(sprintf("Cleaning complete, \nGenerating score matrices...\n\n")) 
if size(re_nonsubsuper,1) > 0 
tempDir = cd;
calcRank(re_nonsubsuper,'NonSubSuper',myDir);
cd(tempDir)
else disp("No (non sub/super) brain experiments were found with the given parameters")
end
if size(re_subsuper,1) > 0
    tempDir = cd;
calcRank(re_subsuper,'SubSuper',myDir);
cd(tempDir)
else disp("No sub/super series brain experiments were found with the given parameters")
end


%% before you save Output to excel, remove things like 5x1 cell using 
% try strjoin(strsplit(string(re_processed9{7,13})))  and catch  MATLAB:strsplit:InvalidStringType
% if error caught, run: strjoin(strsplit(strjoin(string(re_processed9{7,13}))))
