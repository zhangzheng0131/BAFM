function [sf] = argmin_s(df, mu, Lf, MMx, Nf, ZX, ZZ,model)
%% g in the paper

% 
%   ZZ = ZZ + mu*ones(size(ZZ));
%   ZX = ZX + (mu*df) - Lf;
%   sf = ZX./ZZ;
%   
%% try BACF equation

[T,K] = size(ZZ);
xf=model.X;
yf = model.yf;
gf = zeros(size(ZZ));

for i=1:T
    gf(i,:) = (xf(i,:)'*xf(i,:) + T*mu*eye(K))\(ZX(i,:)' - T*Lf(i,:)' + T*mu*df(i,:)');
end

sf= conj(gf);

% %% try final equation in paper
% 
% [T,K] = size(ZZ);
% xf=model.X;
% 
% gf = zeros(size(ZZ));
% yf = model.yf;
% 
% for i=1:T
%     sx = xf(i,:)*xf(i,:)';
%     sl = xf(i,:)*Lf(i,:)';
%     sh = xf(i,:)*df(i,:)';
%     b= sx+T*mu;
%     gf(i,:) = (T*yf(i)*xf(i,:) - Lf(i,:) + mu*df(i,:))'/mu...
%         - xf(i,:)'*(T*yf(i)*sx - sl + mu*sh) / (mu*b);
% end
% sf= conj(gf);
end