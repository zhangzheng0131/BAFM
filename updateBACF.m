function [model,param] = updateBACF(img,pos,target_sz,currentScaleFactor,model,param)

model = optimizeFilters( img, pos, currentScaleFactor, param,model, 0 );

model.last_pos=pos;
model.last_target_sz = target_sz;

model.currentScaleFactor = currentScaleFactor;

if param.nScales >0
       %% update
 [ param,model ] = scaleUpdate( img,pos,param,model,false );
    
end
end