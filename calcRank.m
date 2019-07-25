function ranks = calcRank(oMatrix,type,dir);
load('BRAIN_PARTS.mat')
temprankMatrix = oMatrix(:,[3:6,16:19]);
for i = 1:size(temprankMatrix,1)
for j = 1:size(temprankMatrix,2)
if isempty(temprankMatrix{i,j}) || temprankMatrix{i,j} ==0
rankMatrix(i,j) = 0;
else rankMatrix(i,j) = temprankMatrix{i,j};
end
end
end
for i = 1:size(rankMatrix,1)
if and(sum(rankMatrix(i,[5,7])) == 0 ,sum(rankMatrix(i,[6,8]))>=0)
rankMatrix(i,9) = sum(rankMatrix(i,[1:4]))/4;
elseif sum(rankMatrix(i,[6,8])) == 0
rankMatrix(i,9) = sum(rankMatrix(i,[5,7]));
else rankMatrix(i,9) = 1;
end
end
for i = 1: size(rankMatrix,1)
if contains(oMatrix{i,13},GoodBrainParts,'IgnoreCase',true)
rankMatrix(i,9) = rankMatrix(i,9) + 3;
end
end
for i = 1:size(rankMatrix,1)
rankMatrix(i,10) = (rankMatrix(i,9)) * ( (5 * sum(rankMatrix(i,[1,3]))) + 3*sum(rankMatrix(i,[2,4])));
end
ranks = rankMatrix(:,10);
makeOutputReadyAndPrintToFile(oMatrix,ranks,type,dir);
end

function g = makeOutputReadyAndPrintToFile(oMatrix,ranks,type,dir)
cd(dir)
pMatrix = "";
for i = 1:size(oMatrix,1)
    for j = 1: size(oMatrix,2)
        pMatrix(i,j) = strjoin(splitlines(string(oMatrix{i,j})));
        pMatrix(i,j) = strjoin(string(pMatrix{i,j}));
    end
end
[sz1,sz2]= size(pMatrix);
for i = 1:size(pMatrix,1)
    pMatrix(i,1) = strcat("GSE",pMatrix(i,1));
    pMatrix(i,sz2+1) = string(ranks(i,1));
end
pMatrix = pMatrix(:,[1,20,12,7,13,10,11,15]);

sortMatrix(:,1) = double(pMatrix(:,2));
sortMatrix(:,2) = 1:size(pMatrix(:,2),1);
sortMatrix = sortrows(sortMatrix,1,'descend');
pMatrix = pMatrix(sortMatrix(:,2),:);

tMatrix = array2table(pMatrix,'VariableNames',{'Accessions','Calculated_Score','Species','Sample_Size','Title','Platforms','Num_of_Platforms','GEO_keyword_hits'});
writetable(tMatrix,strcat('BrainExpsFromGEO_',type))
disp(strcat("Ranking completed || CSV saved for type: ", type))
end