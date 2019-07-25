function a = parsecharstics(x);
% used to clean urls, 
                 if strlength(x)>1
                     x = eraseBetween(x, "<",">");
                      x = strsplit(x,"<>")';
                      if contains(x,":")
                      x = (extractBetween(x,':',strlength(x)));
                      a = strtrim(x(strlength(x)>0));
                    else 
                        x= eraseBetween(x, "<",">",'Boundaries','inclusive');
                        a = x(strlength(x)>2);
                      end
                 else a=x;
                 end
  %                 x = eraseBetween(x,"<>",":",'Boundaries','inclusive');
%                   a = eraseBetween(x,"<",">",'Boundaries','inclusive');
%                    x = strsplit(x)';
%                    x = unique(x);
%                    x = x(strlength(x)>0);
%                    a =x;
end
