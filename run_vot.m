function run_vot
%RUN_VOT 此处显示有关此函数的摘要
%   此处显示详细说明

% NSAMF tracker
% coded by Li, Yang, 2015


cleanup = onCleanup(@() exit() ); % Always call exit command at the end to terminate Matlab!
RandStream.setGlobalStream(RandStream('mt19937ar', 'Seed', sum(clock))); % Set random seed to a different value every time as required by the VOT rules.


[handle, image, region] = vot('rectangle'); % Obtain communication object

firstImg = imread(image); % Read first image from file
% TODO: Initialize the tracker with first image and the given initialization region

target_sz = region([4,3]);
pos = region([2,1]) + floor(target_sz/2);
[model, param] = initBACF(firstImg, pos, target_sz);

while true

    [handle, image] = handle.frame(handle); % Get the next frame

    if isempty(image) % Are we done?
        break;
    end;

    img = imread(image); % Read the image from file
    % TODO: Perform a tracking step with the image, obtain new region
   
    if param.resize_image
        img = imresize(img,1/param.resize_scale);
    end

    [pos,target_sz,currentScale,param] = trackBACF(img,model,param);
    
    [model,param] = updateBACF(img,pos,target_sz,currentScale,model,param);
    
    
    region = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
    
    region = region *param.resize_scale;
    
    handle = handle.report(handle, region); % Report position for the given frame

end;

handle.quit(handle); % Output the results and clear the resources





end


