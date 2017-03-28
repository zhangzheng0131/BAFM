function [pos,target_sz,param] = trackBACF(img,model,param)

pos = model.last_pos;
b_filt_sz = model.b_filt_sz;
cropIm = getPatch(img,pos,b_filt_sz, b_filt_sz);
cropIm = (double(cropIm) / 255) - 0.5;  %normalize to range -0.5 .. 0.5
%     out = powerNormalise(double(out));
cropIm = param.cos_window .* cropIm;  %apply cosine window

[rsp, posRsp] = get_rsp((double(cropIm)), model.df, model.s_filt_sz, model.b_filt_sz); %gcf

%% for debug
% rspTmp = rsp(posRsp(1)-floor(s_filt_sz(1)/2):posRsp(1)+floor(s_filt_sz(1)/2), ...
% posRsp(2)-floor(s_filt_sz(2)/2):posRsp(2)+floor(s_filt_sz(2)/2));
% 
% imTmp = cropIm(posRsp(1)-floor(s_filt_sz(1)/2):posRsp(1)+floor(s_filt_sz(1)/2), ...
%             posRsp(2)-floor(s_filt_sz(2)/2):posRsp(2)+floor(s_filt_sz(2)/2));

[row, col] = find(rsp == max(rsp(:)), 1);
pos = pos - floor(b_filt_sz/2) + [row, col];

% if resize_image
%     dis= sqrt(sum((pos*resize_scale - ground_truth(frame,:)*resize_scale).^2));
% else
%     dis= sqrt(sum((pos - ground_truth(frame,:)).^2));
% end;
target_sz = model.last_target_sz;



end