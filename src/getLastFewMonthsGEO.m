function y = getLastFewMonthsGEO(months)
% NOTE: Output is GSE accession without the "GSE" infront; typically you should call about 3 months of GSEs to get the max
setWebOptions;
if months < 3
months = 3; 
disp("Calling eutils with less than 3 months is not allowed, resetting update to 3 months")
end
util = webread(strcat('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=gds&term=GSE[ETYP]+AND+%22published+last+',string(months),'+months%22[Filter]&retmax=10000&retmode=json'));
save nextAutosave2
y = str2double(string(cell2mat(util.esearchresult.idlist))) - 200000000;
end 
