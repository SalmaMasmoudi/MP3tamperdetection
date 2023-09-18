function [E, Ef] = PQ_EtalementTemporel (E2, Ef)

global Nc fc Fe N_adv
persistent  a b

if isempty(a)
    Fss = Fe / N_adv;
    t100 = 0.030;
    tmin = 0.008;
    
    t = tmin + (100 ./ fc) * (t100 - tmin);
    a = exp (-1 ./ (Fss * t));
    b = (1 - a);
end

% Caractéristiques d'excitation
% -----------------------------
Ef = a.* Ef + b.* E2;

E = max(Ef, E2);