function [model,param] = updateBACF(img,pos,target_sz,currentScaleFactor,model,param)

tsz = round(target_sz);
avg_dim = sum(tsz)/2;
% size from which we extract features
% bg_area = round(params.target_sz + avg_dim);
bg_area = round(repmat(sqrt(prod(tsz * param.search_area_scale)), 1, 2));
fg_area = round(tsz - avg_dim * param.inner_padding);
% % saturate to image size
% if(bg_area(2)>size(img,2)), bg_area(2)=size(img,2)-1; end
% if(bg_area(1)>size(img,1)), bg_area(1)=size(img,1)-1; end
% make sure the differences are a multiple of 2 (makes things easier later in color histograms)
model.bg_area = bg_area - mod(bg_area - tsz, 2);
model.fg_area = fg_area + mod(model.bg_area - fg_area, 2);

model.last_pos=pos;
model.last_target_sz = target_sz;

model.currentScaleFactor = currentScaleFactor;
%model.currentScaleFactor = 0.5024;
%currentScaleFactor= 0.5024;
model = optimizeFilters( img, pos, currentScaleFactor, param,model, 0 );



if param.nScales >0
       %% update
 [ param,model ] = scaleUpdate( img,pos,param,model,false );
    
end
end