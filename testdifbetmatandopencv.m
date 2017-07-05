load('data.txt');
img(:,:,1)=firstImg(:,:,3);
img(:,:,2)=firstImg(:,:,2);
img(:,:,3)=firstImg(:,:,1);
index=1;
for i= 1:480
    for j=1:600
        for n=1:3
            dd(index)=img(i,j,n);
            index= index+1;
        end
    end
end
norm(double(dd')-data)