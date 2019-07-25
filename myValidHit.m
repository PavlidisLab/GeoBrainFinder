function v = myValidHit(array, goodLookfor,badLookfor, margin)
% checks if "badLookfor" is near "mrgin" char away from terms nearby 
g = mystrfind(array,goodLookfor);
b = mystrfind(array,badLookfor);
v =0;
for i = 1:length(g)
  if min( abs( b - g(i,1))) > margin
      v = 1;
      break
  end
end
if length(b) == 0 v=1;, end
if length(g) == 0 v=0;, end
end
    

