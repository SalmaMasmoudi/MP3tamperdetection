function MDiff = PQ_MOV_ModDiffB (Mod, ERavg)
% Modulation difference related MOV precursors (Basic version)

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:34:46 $

global Nc fc

persistent Ethres Ete

if (isempty (Ethres))
    e = 0.3;
    EthresdB = 1.456 * (fc / 1000).^(-0.8);
    Ethres = 10.^(EthresdB / 10);
    Ete = Ethres.^e;
end

% Parameters
negWt2B = 0.1;
offset1B = 1.0;
offset2B = 0.01;
levWt = 100;

s1B = 0;
s2B = 0;
Wt = 0;
for (m = 0:Nc-1)
    if (Mod(m+1, 1) > Mod(m+1, 2))
        num1B = Mod(m+1, 1) - Mod(m+1, 2);
        num2B = negWt2B * num1B;
    else
        num1B = Mod(m+1, 2) - Mod(m+1, 1);
        num2B = num1B;
    end
    MD1B = num1B / (offset1B + Mod(m+1, 1));
    MD2B = num2B / (offset2B + Mod(m+1, 1));
    s1B = s1B + MD1B;
    s2B = s2B + MD2B;
    Wt = Wt + ERavg(m+1) / (ERavg(m+1) + levWt * Ete(m+1));
end

MDiff.Mt1B = (100 / Nc) * s1B;
MDiff.Mt2B = (100 / Nc) * s2B;
MDiff.Wt = Wt;
