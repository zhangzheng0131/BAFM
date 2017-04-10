function [pos,target_sz,param] = trackBACF(img,model,param)

pos = model.last_pos;
b_filt_sz = model.b_filt_sz;
x = getPatch(img,pos,param.window_sz, param.window_sz);


cropIm = prepareData(x, param.features);
cropIm = calculateFeatures(cropIm, param.features,param.cos_window);


% cropIm = (double(cropIm) / 255) - 0.5;  %normalize to range -0.5 .. 0.5
%     out = powerNormalise(double(out));
% cropIm = param.cos_window .* cropIm;  %apply cosine window

% 
param.display={};
param.display{1}=x;

% param.display{2}=cropIm(:,:,3);
MMx = prod(b_filt_sz);
Nchannel = size(cropIm,3);

cropIm = reshape(cropIm,[MMx Nchannel]);%get_ini_perturbation(data, 8);


[rsp, posRsp] = get_rsp((double(cropIm)), model.df, model.s_filt_sz, model.b_filt_sz); %gcf
param.display_rsp={};
param.display_rsp{1}=fftshift(rsp);
pos = pos + param.features.cell_size * posRsp;

%% for debug
% rspTmp = rsp(posRsp(1)-floor(s_filt_sz(1)/2):posRsp(1)+floor(s_filt_sz(1)/2), ...
% posRsp(2)-floor(s_filt_sz(2)/2):posRsp(2)+floor(s_filt_sz(2)/2));
% 
% imTmp = cropIm(posRsp(1)-floor(s_filt_sz(1)/2):posRsp(1)+floor(s_filt_sz(1)/2), ...
%             posRsp(2)-floor(s_filt_sz(2)/2):posRsp(2)+floor(s_filt_sz(2)/2));

% [row, col] = find(rsp == max(rsp(:)), 1);
% pos = pos  + (posRsp- floor(b_filt_sz/2)).*param.features.cell_size;

% if resize_image
%     dis= sqrt(sum((pos*resize_scale - ground_truth(frame,:)*resize_scale).^2));
% else
%     dis= sqrt(sum((pos - ground_truth(frame,:)).^2));
% end;
target_sz = model.last_target_sz;



end