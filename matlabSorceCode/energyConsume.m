function[Etx,Erx]=energyConsume(d,k)
% https://doi.org/10.1016/j.jksuci.2017.04.002
% Etx   = k*Eelec + k*Efs*d^2    for d<d0
%       = k*Eelec + k*Emp*d^4   for d>=d0
% Erx   = k*Eelec

% Eelec10=50 nJ/bit
% Efs=10 pJ/bit/m2
% EDA=5 nJ/bit/message
% Emp=0.0013 pJ/bit/4
% d0=square root(Efs/Emp)
% packet size = 8 bytes = 8 * 8 bits = 64 bits
%%%%%%%%%%%%%%%%%%%%%%%%%Energy Model(all values in Joules)%%%%%%%%%%%%%%%%
%Eo=1;   %initial Energy
Eelec=50e-9;
Efs=10e-12;
Emp=0.0013e-12;
%EDA=5e-9;
d0=sqrt(Efs/Emp);
k=k*8; %packet size in bits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if d<d0
    Etx = k*Eelec + k*Efs*(d^2);
else
    Etx = k*Eelec + k*Emp*(d^4);
end
Erx = k*Eelec;
end
