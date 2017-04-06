function r = cropping(x,mn,crop)
    
delta = floor((crop - mn)/2);

tmp = circshift(x,delta);

r=tmp( 1:crop(1), 1:crop(2));

end
