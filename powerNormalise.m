function x = powerNormalise(x)
 x = double(x);
    xmeanx = x-mean(x(:));
      if std(xmeanx(:))>0
    x      = xmeanx / (std(xmeanx(:)));
      end;
end