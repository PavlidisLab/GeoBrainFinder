function [y , z] = getGemmaInfo(startAcc,endAcc,varargin);
% call with (1,1) or (start#,end#), (start,end,dont_authenticate), (start,end,username,password), (start,end,username,password,dont_authenticate)
y = [];
z = [];
p = "YW1hbnNoYXJtYTp0ZW1wUGFzc3dvcmQ";
authorize = 1;
if length(varargin) == 1
    authorize = 0;
elseif length(varargin) == 2
    p = matlab.net.base64encode(strcat(string(varargin(1)),":",string(varargin{2})));
elseif length(varargin) == 3
    p = matlab.net.base64encode(strcat(string(varargin(1)),":",string(varargin{2})));
    authorize = 0;
end
options = weboptions;
options.Timeout = 10000;
if authorize
options.HeaderFields = matlab.net.http.field.AuthorizationField("Authorization", strcat("Basic ",p));
end
apiHit = [];

% if endAcc == 0
%     fileID = fopen(startAcc);
%     scanned = textscan(fileID,'%s');
%     fclose(fileID);
%     scannedArray = (string(scanned{:,:}));
%     i = scannedArray;
%     disp(i)
% else i = startAcc:endAcc';
% end


% if (endAcc - startAcc < 1000)
%     lastTemp = startAcc;
%     temp = endAcc;
% else 
% lastTemp = startAcc;
% temp = startAcc + 1000;
% end
lastTemp = startAcc;
temp = startAcc + 1000;

setBreak = 0;
loopNum = 0;
try 
while true
    if temp >= endAcc
        temp = endAcc;
        setBreak = 1;
    end
    i = lastTemp:temp;
    tempHit = jsondecode(char(webread(gemmaQueryBuilder(i),options)));
    tempHit = tempHit.data;
    lastTemp = temp+1;
    temp = temp+1000;
    if ~loopNum
        apiHit = tempHit;
    else apiHit = [apiHit;tempHit];
    end
    loopNum = loopNum + 1; 
    if setBreak
        break
    end
end
struct = apiHit;
% struct = jsondecode(apiHit);
structArray = struct;
save('nextGemmaAPI','structArray')
if size(structArray,1) > 1 writetable(struct2table(structArray), 'nextGemmaAPI.txt'), else disp("Not saving gemma call to a text file since size of the call is smaller than 2!"), end
disp( "Gemma API Call complete ||")
y = structArray;
z="";
for i = 1:size(y,1)
    z(i,1) = string(y(i).shortName);
end
catch ME
    if string(ME.identifier) == "MATLAB:webservices:HTTP401StatusCodeError"
        warning(sprintf('Credentials not accepted at the Gemma end. \nEnter your Gemma username and password. To quit the gemma call enter USERNAME: quit'))
        uname = input('Enter gemma username: ','s');
        if string(uname) ~= "quit"
        pass = input('Enter gemma password: ','s');
        disp("retrying...")
        [y,z] = getGemmaInfo(startAcc, endAcc, uname, pass);
        else disp("Gemma call was cancelled, thus an empty Gemma List will be used from hence forth")
        end
    else rethrow(ME)
    end
end

end
function y = gemmaQueryBuilder(q)
query = "";
for i = 1:length(q)
    query = strcat(string(q(i)),'%2C',query);
end
y = strcat('https://gemma.msl.ubc.ca/rest/v2/datasets/',query,'?offset=0&limit=0&sort=%2Bid');
end
% function y = combineGemmaJSONchars(j1,j2)
% y= strcat( j1(1:end-2), ',', j2(10:end));
% end

