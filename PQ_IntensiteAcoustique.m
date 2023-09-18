function Ntot = PQ_IntensiteAcoustique ( E )
% Calculate the loudness

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:35:09 $
global Nc fc

e = 0.23;

persistent s Et Ets 

if isempty( s )
    c = 1.07664;
    E0 = 1e4;
    EtdB = 3.64 * (fc / 1000).^(-0.8);
    Et = 10.^(EtdB / 10);
    
    sdB = -2 - 2.05 * atan(fc / 4000) - 0.75 * atan((fc / 1600).^2);
    s = 10.^(sdB / 10);
    
    Ets = c * (Et ./ (s * E0)).^e;
end


Nm = Ets.* ((1 - s +  s.* E./ Et).^e - 1);
sN = sum( max(Nm, 0) );
Ntot = (24 / Nc) * sN;
