function data = calculateFeatures(rawdata, features,cos_window)
    data={};
    id = 1;

    if features.grey 
       x= rawdata.patch;
%        if ~equalSZ(x,features.sz)
%            x = imresize(x,features.sz);
%        end
       x= (double(x) / 255) - 0.5;
       x = bsxfun(@times, x, cos_window);
%        data{5} =x;
       data = x;
       id =id +1;
 
    end
    
    if features.colorProb 
        x = rawdata.colorProb;
        if ~equalSZ(x,features.sz)
           x = imresize(x,features.sz);
        end
        x= x - mean(x(:));
        x = bsxfun(@times, x, cos_window);
        data{1} =cat(3,data{1},x);
%  %x;      data{2}=cat(3,data{2},x);
         data{id} = x;
         id =id +1;
    end
    
    if features.greyProb 
        x = rawdata.greyProb;
        if ~equalSZ(x,features.sz)
           x = imresize(x,features.sz);
        end
        x= x - mean(x(:));
        x = bsxfun(@times, x, cos_window);
        data{1} =cat(3,data{1},x);
        data{2}=cat(3,data{2},x);
%         data{id} = x;
%         id =id +1;%x;
    end
    
    if features.colorName
        x= rawdata.patch;
        if ~equalSZ(x,features.sz)
           x = imresize(x,features.sz);
       end
       x = get_feature_map(x, 'cn', features.w2c);
      x = bsxfun(@times, x, cos_window);
      data{2} =cat(3,data{2},x);
%         data{id} = x; % %
%         id =id +1;
    end
        
    if features.greyHoG
        x = double(fhog(single(rawdata.gImg), features.cell_size, features.hog_orientations));
        x(:,:,end) = [];
        x = bsxfun(@times, x, cos_window);
%         data{1} =cat(3,data{1},x);
        data = x;
        id =id +1;
    end


    
    if features.colorProbHoG
        x = double(fhog(single(rawdata.colorProb) , features.cell_size, features.hog_orientations));
        x = bsxfun(@times, x, cos_window);
        data{1} =cat(3,data{1},x);
        data{id} = x;
        id =id +1;
    end
    
    if features.lbp
        if ~equalSZ(rawdata.grey,features.sz)
           x = imresize(rawdata.grey,features.sz);
        end
        x = LBPmap(x);  
        x = bsxfun(@times, x, cos_window);
        data{id} =cat(3,data{5},x);
        id =id +1;
    end

    

end


function r = equalSZ(x,sz)
    tmp = size(x);
    r = prod(tmp(1:2)==sz(1:2));
end