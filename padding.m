function r = padding(x,mn,pad)

delta = floor((pad - mn)/2);

r=padarray(x,delta); 

if size(r,1) < pad(1)
    r = [r;zeros(1,size(r,2))];
end

if size(r,2) < pad(2)
    r = [r, zeros(size(r,1),1)];
end
end