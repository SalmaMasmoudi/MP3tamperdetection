function NL = PQ_MOV_NoiseLoudB (Mod, El)
% Noise Loudness

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:34:47 $
global Nc fc

persistent Ethres

if (isempty (Ethres))
    EthresdB = 1.456 * (fc / 1000).^(-0.8);
    Ethres = 10.^(EthresdB / 10);
end

% Parameters
alpha0 = 1.5;
TF0 = 0.15;
S0 = 0.5;
NLmin = 0;
e = 0.23;


% sref  = TF0 * Mod(:, 1) + S0;
% stest = TF0 * Mod(:, 2) + S0;
% beta = exp (-alpha0 * (El(:, 2) - El(:, 1)) ./ El(:, 1));
% a = max (stest .* El(:, 2) - sref .* El(:, 1), 0);
% b = Ethres + sref .* El(:, 1) .* beta;
% s = sum( (Ethres ./ stest).^e .* ((1 + a ./ b).^e - 1) );

s = 0;
for (m = 0:Nc-1)
    sref  = TF0 * Mod(m+1, 1) + S0;
    stest = TF0 * Mod(m+1, 2) + S0;
    beta = exp (-alpha0 * (El(m+1, 2) - El(m+1, 1)) / El(m+1, 1));
    a = max (stest * El(m+1, 2) - sref * El(m+1, 1), 0);
    b = Ethres(m+1) + sref * El(m+1, 1) * beta;
    s = s + (Ethres(m+1) / stest)^e * ((1 + a / b)^e - 1);
end

NL = (24 / Nc) * s;
if (NL < NLmin)
    NL = 0;
end
