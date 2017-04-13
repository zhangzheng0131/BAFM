function [sf] = argmin_s(df, mu, Lf, MMx, Nf, ZX, ZZ)



  ZZ = ZZ + mu*ones(size(ZZ));
  ZX = ZX + (mu*df) - Lf;
  sf = ZX./ZZ;
  
%% try BACF equation

[T,K] = size(ZZ);



end