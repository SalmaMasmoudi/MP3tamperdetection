function [El, Filtre] = PQ_Adaptation (E, Filtre)
% Level and pattern adaptation

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:35:08 $
global N_PEAQ N_adv Fe Nc fc

persistent a b M1 M2

if ( isempty(a) )
    Fss = Fe / N_adv;
    t100 = 0.050;
    tmin = 0.008;
        t = tmin + (100 ./ fc) * (t100 - tmin);
        a = exp (-1 ./ (Fss * t));
        b = (1 - a);
        
    M1 = 3;
    M2 = 4;
end


 % Actualisation du filtrage
 % -------------------------
    Filtre.P(:, 1) = a.* Filtre.P(:, 1) + b.* E(:, 1);
    Filtre.P(:, 2) = a.* Filtre.P(:, 2) + b.* E(:, 2);
    
% Adaptation du niveau
% --------------------
LevCorrNum = sum( sqrt(Filtre.P(:, 2) .* Filtre.P(:, 1)) );
LevCorrDenom = sum( Filtre.P(:, 2) );
LevCorr = (LevCorrNum / LevCorrDenom)^2;
if (LevCorr > 1)
    El(:, 1) = E(:, 1) / LevCorr;
    El(:, 2) = E(:, 2);
else
    El(:, 1) = E(:, 1);
    El(:, 2) = E(:, 2) * LevCorr;
end


% Facteur de correction des caracteristiques
% ------------------------------------------
Filtre.Rn = a .* Filtre.Rn + El(:, 2) .* El(:, 1);
Filtre.Rd = a .* Filtre.Rd + El(:, 1) .* El(:, 1);

R = zeros (Nc, 2);
for (m = 0:Nc-1)
    if (Filtre.Rd(m+1) <= 0 | Filtre.Rn(m+1) <= 0)
        error ('>>> PQadap: Rd or Rn is zero');
    end
    if (Filtre.Rn(m+1) >= Filtre.Rd(m+1))
        R(m+1, 1) = 1;
        R(m+1, 2) = Filtre.Rd(m+1) / Filtre.Rn(m+1);
    else
        R(m+1, 1) = Filtre.Rn(m+1) / Filtre.Rd(m+1);
        R(m+1, 2) = 1;
    end
end

% Average the correction factors over M channels and smooth with time
% Create spectrally adapted patterns
for (m = 0:Nc-1)
    iL = max (m - M1, 0);
    iU = min (m + M2, Nc-1);
    s1 = 0;
    s2 = 0;
    for (i = iL:iU)
        s1 = s1 + R(i+1, 1);
        s2 = s2 + R(i+1, 2);
    end
    Filtre.PC(m+1, 1) = a(m+1) * Filtre.PC(m+1, 1) + b(m+1) * s1 / (iU-iL+1);
    Filtre.PC(m+1, 2) = a(m+1) * Filtre.PC(m+1, 2) + b(m+1) * s2 / (iU-iL+1);

    % Final correction factor => spectrally adapted patterns
    El(m+1, 1) = El(m+1, 1) * Filtre.PC(m+1, 1);
    El(m+1, 2) = El(m+1, 2) * Filtre.PC(m+1, 2);
end

