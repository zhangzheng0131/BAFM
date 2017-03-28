% NSAMF tracker
% coded by Li, Yang, 2015


function [rects, time] = bacf(video_path, img_files, pos, target_sz,datasetParam)

addpath('./CFwLB');
% addpath('./tracker');
% addpath('./features');
% addpath('./display');


%get parameters
firstImg = imread([video_path img_files{1}]);
if size(firstImg,3)>1
firstImg = rgb2gray(firstImg);
end
[model, param] = initBACF(firstImg, pos, target_sz);
totalFames = numel(img_files);

rects = zeros(totalFames,4);
rects(1,:) = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];

if isempty(datasetParam)
    param = displayManager(firstImg,rects(1,:),model,param);
end

time = 0 ;
for frame=2:numel(img_files)
    img = imread([video_path img_files{frame}]);
%     if param.resize_image
%         img = imresize(img,0.5);
%     end
if size(img,3)>1
    img = rgb2gray(img);
end
    tic
    [pos,target_sz,param] = trackBACF(img,model,param);
    
    [model,param] = updateBACF(img,pos,target_sz,model,param);
    
    
    rect = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
    rects(frame,:) = rect;
    time = toc + time;
    
    if isempty(datasetParam)
        param = displayManager(img,rect,model,param);
    end
end
% if resize_image,
%     rect = rect *2;
% end


end