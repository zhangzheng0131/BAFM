%---------------------------------------------------
%   subproblem g
%   inputs:
%       sf : large correlation filter. refer to paper for more details
%       mu : penalty factor
%       Lf : lagrange multiplier

%   output:
%       df : small filter in the frequency domain
%---------------------------------------------------

function [df] = argmin_d(sf, mu, Lf, Mx, Mf,lambda)

d =  ifftvec((mu*sf + Lf)/(mu + (lambda/sqrt(prod(Mx)))), Mx , Mf) ; %
% inpaper
% d = ifftvec(sf+(1/mu)*Lf,Mx,Mf);% original code
df = fftvec(d, Mf, Mx);

end