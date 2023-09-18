function PD = PQ_MOV_ProbabiliteDetection (E)
% Probability of detection

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:34:47 $

global Nc

% Allocate storage
PD.p = zeros (Nc, 1);
PD.q = zeros (Nc, 1);

persistent c g d1 d2 bP bM

if (isempty (c))
    c = [-0.198719; 0.0550197; -0.00102438; 5.05622e-6; 9.01033e-11];
    d1 = 5.95072;
    d2 = 6.39468;
    g = 1.71332;
    bP = 4;
    bM = 6;
end

EdBR = 10 * log10 (E(:, 1));
EdBT = 10 * log10 (E(:, 2));
edB = EdBR - EdBT;

for (m = 0:Nc-1)
    if (edB(m+1) > 0)
        L = 0.3 * EdBR(m+1) + 0.7 * EdBT(m+1);
        b = bP;
    else
        L = EdBT(m+1);
        b = bM;
    end
    if (L > 0)
        s = d1 * (d2 / L)^g ...
            + c(1) + L * (c(2) + L * (c(3) + L * (c(4) + L * c(5))));
    else
        s = 1e30;
    end
    PD.p(m+1) = 1 - 0.5^((edB(m+1) / s)^b);        % Detection probability
    PD.q(m+1) = abs (fix(edB(m+1))) / s;           % Steps above threshold
end 
