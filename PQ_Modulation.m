function [Mod, ERavg, Filtre] = PQ_Modulation (E2, Filtre)
% Modulation pattern processing

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:35:09 $
global Nc Fe N_PEAQ fc

persistent a b Fss

if (isempty (a))
    Fss = Fe / (N_PEAQ/2);
    t100 = 0.050;
    t0 = 0.008;
    t = t0 + (100 ./ fc) * (t100 - t0);
    a = exp (-1 ./ (Fss * t));
    b  = (1 - a);
end

% Allocate memory
Mod = zeros (Nc, 2);

e = 0.3;
for (i = 1:2)
    Ee = E2(:, i).^e;
    Filtre.DE(:, i) = a .* Filtre.DE(:, i) + Fss *b .* abs (Ee - Filtre.Ese(:, i));
    Filtre.Eavg(:, i) = a .* Filtre.Eavg(:, i) + b.* Ee;
    Filtre.Ese(:, i) = Ee;
    Mod(:, i) = Filtre.DE(:, i) ./ (1 + Filtre.Eavg(:, i)/0.3);
end

ERavg = Filtre.Eavg(:, 1);
