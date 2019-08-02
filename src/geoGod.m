function y = geoGod(i,A)
% parser for GSE and GSM pages, creates a 1x20 cell array as output with information about the GEO page and hit information. See code below for details about individual cell information
setWebOptions;
load('BRAIN_PARTS.mat')
startLoopTimer = tic;
    %i
    c=10;
    tempurl = webread(strcat('https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE',string(A(i,1))),options);
    if ~contains(tempurl,'Could not find a public or private accession')
       if ~contains(tempurl,'is currently private and is scheduled to be released on')
           if ~contains(tempurl,'was deleted by the GEO staff on')
               samplesize_real = str2double(string(extractBetween(tempurl,'<td>Samples (',')')));
               GSMval = string(extractBetween(tempurl,'=GSM','"'));
               OUT(1,1) = {A(i,1)};
                 temptaxon = string(eraseBetween(extractBetween(tempurl, 'rganism</td>','</a></td>'), '<','>','Boundaries','inclusive'));
                 OUT(1,2) = {extractBetween(temptaxon , 2, strlength(temptaxon))};
                %if ~isempty(OUT{1,2})
                id = strcat("GSE",string(A(i,1)));
                OUT(1,15) = {''};
                       OUT(1,7) = {str2double(string(extractBetween(tempurl,'<td>Samples (',')')))};
                        temp_temp = eraseBetween(string(extractBetween(tempurl,'Summary</td>','</td>')),'<','>','boundaries','inclusive');
                        OUT(1,8) = {extractBetween(temp_temp,2,strlength(temp_temp))};
                        OUT(1,9) = {parsecharstics(string(extractBetween(tempurl,'<td>Submission date</td>','</tr>')))};
                        tempPLat = string(eraseBetween(extractBetween(tempurl,'<a href="/geo/query/acc.cgi?acc=GPL','</tr>','boundaries','inclusive'),'<','>','boundaries','inclusive'));
                        tempPLat = strjoin(tempPLat); 
                        OUT(1,10) = {tempPLat};
                        OUT(1,11) = {string(extractBetween(tempurl,'<td>Platforms (',')'))};  %number of platforms real 
                        temptaxon = string(eraseBetween(extractBetween(tempurl, '<tr valign="top"><td nowrap>Organism','</a></td>'), '<','>','Boundaries','inclusive'));
                            if isempty(temptaxon)
                                temptaxon = string(eraseBetween(extractBetween(tempurl, 'Sample organism','</a></td>'), '<','>','Boundaries','inclusive'));
                            else temptaxon = temptaxon;
                            end
                        OUT(1,12) = {extractBetween(temptaxon , 2, strlength(temptaxon))};
                        temptitle = eraseBetween(extractBetween(tempurl, '>Title</td>', '</td>'),'<','>','Boundaries','inclusive');
                        OUT(1,13) = {extractBetween(temptitle , 2 , strlength(temptitle))};
                        OUT(1,14) = {parsecharstics(string(extractBetween(tempurl,'<td nowrap>Experiment type</td>','</td>')))};
                if contains(tempurl,'This SuperSeries is composed of the following SubSeries:')
                    OUT(1,20) = {2};
                elseif contains(tempurl,'This SubSeries is part of SuperSeries')
                    OUT(1,20) = {1};
                else 
                    OUT(1,20) = {0};
                end
                
                 if length(GSMval) > 0
                tempurl = tempurl(1:max(strfind(tempurl,strcat("GSM",GSMval(end,1))))+5); %% cuts html short !
                 end
                 
           cleanedTempUrl = eraseBetween(eraseBetween(tempurl,'<','>','boundaries','inclusive'),'(',')','boundaries','inclusive');

                       [samplesize_gsm,v] = size(GSMval);
                       if contains(tempurl,BRAIN_PARTS,'ignorecase',true)
                           OUT(1,3) = {1};
                           OUT(1,15) = addLog(tempurl,BRAIN_PARTS,id,OUT(1,15));
                          if contains(cleanedTempUrl,BRAIN_PARTS,'ignorecase',true)
                              OUT(1,3) = {2};
                          end
                       end
                       if contains(tempurl,ACC_PARTS, 'ignorecase',true)
                            OUT(1,4) = {1};
                            OUT(1,15) = addLog(tempurl,ACC_PARTS,id,OUT(1,15));
                            if contains(cleanedTempUrl,ACC_PARTS,'ignorecase',true)
                              OUT(1,4) = {2};
                          end
                       end
                       
                       if contains(tempurl,GoodBrainParts, 'ignorecase',true) && myValidHit(tempurl,GoodBrainParts,hits,15)
                       OUT(1,16) = {1};
                       OUT(1,15) = addLog(tempurl,GoodBrainParts,id,OUT(1,15));
                       if contains(cleanedTempUrl,GoodBrainParts,'ignorecase',true)
                              OUT(1,16) = {2};
                          end
                       end
                       
                       if contains(tempurl,OtherParts, 'ignorecase',true) && myValidHit(tempurl,OtherParts,"=",10)
                       OUT(1,17) = {1};
                       OUT(1,15) = addLog(tempurl,OtherParts,id,OUT(1,15));
                       if contains(cleanedTempUrl,OtherParts,'ignorecase',true)
                              OUT(1,17) = {2};
                          end
                       end
                       j=1;
                               while j<samplesize_gsm
                                   id = strcat("GSM",string(GSMval(j,1)));
                                   
                                   tempgsmurl = webread(strcat('https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM',GSMval(j,1)),options);
                                cleanedTempgsmurl = eraseBetween(eraseBetween(tempgsmurl,'<','>','boundaries','inclusive'),'(',')','boundaries','inclusive');
                               if contains(tempgsmurl,BRAIN_PARTS, 'ignorecase',true)
                                   OUT(1,5) = {1};
                                   OUT(1,15) = addLog(tempgsmurl,BRAIN_PARTS,id,OUT(1,15));
                           if contains(cleanedTempgsmurl,BRAIN_PARTS,'ignorecase',true)
                              OUT(1,5) = {2};
                          end
                               end
                               
                               if contains(tempgsmurl,ACC_PARTS, 'ignorecase',true)
                                    OUT(1,6) = {1};
                                    OUT(1,15) = addLog(tempgsmurl,ACC_PARTS,id,OUT(1,15));
                                    if contains(cleanedTempgsmurl,ACC_PARTS,'ignorecase',true)
                              OUT(1,6) = {2};
                               end
                               end 
                               
                               if contains(tempgsmurl,GoodBrainParts, 'ignorecase',true) && myValidHit(tempgsmurl,GoodBrainParts,hits,15)
                               OUT(1,18) = {1};
                               OUT(1,15) = addLog(tempgsmurl,GoodBrainParts,id,OUT(1,15));
                               if contains(cleanedTempgsmurl,GoodBrainParts,'ignorecase',true)
                              OUT(1,18) = {2};
                               end
                               end
                       
                               if contains(tempgsmurl,OtherParts, 'ignorecase',true) && myValidHit(tempgsmurl,OtherParts,"=",10)
                               OUT(1,19) = {1};
                               OUT(1,15) = addLog(tempgsmurl,OtherParts,id,OUT(1,15));
                               if contains(cleanedTempgsmurl,OtherParts,'ignorecase',true)
                               OUT(1,19) = {2};
                               end
                               end
                       
                                    if samplesize_real<4
                                        j=j+1;
                                    elseif samplesize_real<10
                                    j= j+ 3;      
                                    elseif samplesize_real<20
                                        j=j+3;
                                    elseif samplesize_real<50
                                        j=j+9;
                                    else j= j + floor(samplesize_real/30);
                                    end
                               end
               % else OUT(1,2) = {'NO TAXON FOUND'};
               %     OUT(1,3:20) = {[]};
               % end 
         else OUT(1,2) = {'DELETED BY GEO'};
         OUT(1,3:20) = {[]};
        end
        else OUT(1,2) = {'PRIVATE'};
            OUT(1,3:20) = {[]};
        end
    else OUT(1,2) = {'NOT ON GEO'};
        OUT(1,3:20) = {[]}; 
    end
    
if( toc(startLoopTimer) < 1)
   pause(1)
end
%disp(toc(startLoopTimer))
y = OUT;
end


function y = addLog(url,lookArray,id,cell);
y = {strcat(cell{1,1},genTextForLogs(url,lookArray,id))};
function y = genTextForLogs(url, lookArray,id);
ind = unique(mystrfind(url,lookArray));
tempS = "";
for i = 1:size(ind,1)
    try 
        tempS(i,1) = url(ind(i,1)-20:ind(i,1)+20);
    catch ME 
    end
end
text = strjoin(tempS,' | ');
y = strcat(id,":",text," || ");
end
% y = {''}; stub
end
