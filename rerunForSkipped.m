for i = 1:length(Output)
if contains(string(Output{i,2}),"re-run later")
Output(i,2) = run(i,A)
end
end 
