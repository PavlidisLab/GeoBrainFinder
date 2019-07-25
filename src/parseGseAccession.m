function y = parseGseAccession(x)
% x is a length(x) by 1 string array, y is just the double of the
% accesssion
y = [];
t = char(x);
for i = 1:size(x,1)
    temp = t(i,1:end);
    if string(t(i,1:3)) == "GSE" 
         lastMarker(1,1) = 0;
         if isempty(strfind(temp,"_")) lastMarker(1,1) = 0;, else lastMarker(1,1) = min(strfind(temp,"_")) -1;, end;
         if isempty(strfind(temp,".")) lastMarker(2,1) =  0;, else lastMarker(2,1) = min(strfind(temp,".")) -1;, end;
         lastMarker = setdiff(lastMarker,0);
         if isempty(lastMarker)
             lastMarker = length(temp);
         else lastMarker = min(lastMarker);
         end
         y(end+1,1) = str2num(temp(4:lastMarker));
%    else throw(MException('MyComponent:noSuchVariable',strcat('Format error in text file, line: ', string(i))));
    end
    
    %if 
        
end
y = unique(y);
disp(strcat("Successfully read ",string(length(y))," unique GEO accessions"))
end
