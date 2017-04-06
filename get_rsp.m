function [rsp pos] = get_rsp( cropIm, df, s_filt_size, b_filt_size)
%% why calculate again?
d = ifftvec(df, b_filt_size, s_filt_size);
df = fftvec(d, s_filt_size, b_filt_size);
sz=b_filt_size;
%%
rsp = fftvec(cropIm, b_filt_size).*df;
rsp = sum(rsp,2);
rsp = reshape(rsp, b_filt_size);
rsp = reshape(ifftvec(rsp(:), b_filt_size), b_filt_size);
% rsp = circshift(rsp, fix(b_filt_size/2));
% [x, y] = find(rsp == max(rsp(:)),1);
% pos = [x y];
% pos =  pos- floor(b_filt_size/2);%.*param.features.cell_size;

[vert_delta, horiz_delta] = find(rsp ==max(rsp(:)), 1);
if vert_delta > sz(1) / 2,  %wrap around to negative half-space of vertical axis
    vert_delta = vert_delta - sz(1);
end
if horiz_delta > sz(2) / 2,  %same for horizontal axis
    horiz_delta = horiz_delta - sz(2);
end
%%since we aligment the true sample in y[1,1]
pos = [vert_delta-1, horiz_delta-1];
end
