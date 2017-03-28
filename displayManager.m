function param = displayManager(img,rect,model,param)

if param.visualization

    if isfield(param,'im_h'),  %create image
        set(param.im_h, 'CData', img)
    else  %just update it, 'Parent',axes_h
        param.im_h = imshow(img, 'Border','tight', 'InitialMag',200);
    end
        
    if isfield(param,'rect_h'),  %create it for the first time,'Parent',axes_h
        set(param.rect_h, 'Visible', 'on', 'Position', rect);
    else
        param.rect_h = rectangle('Position',rect, 'EdgeColor','g','LineWidth',2);
    end
            
    
    if isfield(param,'display'),  %create it for the first time,'Parent',axes_h
       
        if isfield(param,'model_im_hs'),  %create image
            n = numel(param.model_im_hs);
            for i=1:n
                set(param.model_im_hs{i}, 'CData', param.display{i})
            end
        else  %just update it, 'Parent',axes_h
            n = numel(param.display);
            param.model_im_hs={};
            for i=1:n
                figure
                param.model_im_hs{i} = imshow(param.display{i}, 'Border','tight', 'InitialMag',200);
            end
            
        end
    end
    
    if isfield(param,'dispaly'),  %create it for the first time,'Parent',axes_h
        set(param.rect_h, 'Visible', 'on', 'Position', rect);

        param.rect_h = rectangle('Position',rect, 'EdgeColor','g','LineWidth',2);
    end
    
        
    drawnow
end

end