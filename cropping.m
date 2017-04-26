function r = cropping(x,mn,crop)
    
delta = fix((crop - mn)/2);

tmp = circshift(x,delta);

r=tmp( 1:crop(1), 1:crop(2),:);

end
