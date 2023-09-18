function E2 = PQ_Etalement_BandeCritique ( Pp )
% Spread an excitation vector (pitch pattern) - FFT model
% Both E and Es are powers

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:32:58 $
global Nc fc fl fu dz

persistent Etilde2 
persistent aL aUC


if ( isempty (Etilde2) )
    Etilde2 = PQ_SpreadCB (ones(Nc, 1), ones(Nc, 1));
end

E2 = PQ_SpreadCB (Pp, Etilde2);

%-------------------------
function E3 = PQ_SpreadCB (Pp, Etilde);

global Nc fc fl fu dz

e = 0.4;


E2 = zeros (Nc, 1);

% Calculate energy dependent terms
aL = 10^(-2.7 * dz);
aUC = 10.^( (-2.4 - 23 ./ fc) * dz);
aUCE = aUC .* Pp.^(0.2 * dz);
gIL = (1 - aL.^( (1:Nc)') ) / (1 - aL);
gIU = (1 - aUCE.^(Nc-(0:Nc-1)')) ./ (1 - aUCE);
En = Pp ./ (gIL + gIU - 1);
aUCEe = aUCE.^e;
Ene = En.^e;

% Lower spreading
E2(Nc-1+1) = Ene(Nc-1+1);
aLe = aL^e;
for (m = Nc-2:-1:0)
    E2(m+1) = aLe * E2(m+1+1) + Ene(m+1);
end

% Upper spreading i > m
for (m = 0:Nc-2)
    r = Ene(m+1);
    a = aUCEe(m+1);
    for (i = m+1:Nc-1)
        r = r * a;
        E2(i+1) = E2(i+1) + r;
    end
end
E3 = E2.^(1/e) ./ Etilde;
