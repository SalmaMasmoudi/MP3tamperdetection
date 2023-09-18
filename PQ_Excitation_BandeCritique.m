function [Ppnoise, E2] = PQ_Excitation_BandeCritique (FFTx)

global N_PEAQ Fe Nc fc

persistent W2 Ppthres

% W2 = réponse en fréquence de l'oreille externe et de l'oreille moyenne en
% linéaire
if (isempty (W2))
    axe_freq = linspace (0, Fe/2, N_PEAQ/2+1)';
    axe_freq_kHz = axe_freq / 1000;
    
    WdB = -2.184 * axe_freq_kHz.^(-0.8) + 6.5 * exp(-0.6 * (axe_freq_kHz - 3.3).^2) ...
        - 0.001 * axe_freq_kHz.^(3.6);
    
    W2 = 10.^(WdB / 10);
end

% Ppthres = bruit interne
if ( isempty(Ppthres) )
    PpthresdB = 1.456 * (fc / 1000).^(-0.8);
    Ppthres = 10.^(PpthresdB /10);
end


% Sorties FFT pondérées de l'oreille externe
% ------------------------------------------
Fsp = zeros(N_PEAQ/2+1, 2);
Fsp(:, 1) = W2 .* FFTx(1:N_PEAQ/2+1, 1);
Fsp(:, 2) = W2 .* FFTx(1:N_PEAQ/2+1, 2);

% Signal d'erreur
% ---------------
% Fspnoise = zeros(N_PEAQ/2+1, 1);
% for (k = 0:N_PEAQ/2)
%     Fspnoise(k+1) = (Fsp(k+1, 1) - 2 * sqrt (Fsp(k+1, 1) * Fsp(k+1, 2)) ...
%                + Fsp(k+1, 2));
% end
Fspnoise = ( sqrt(Fsp(:, 1)) - sqrt(Fsp(:, 2)) ).^2;


% Regroupement en bande critique
% ------------------------------
Pp(:, 1)    = PQ_Regroupement_BandeCritique ( Fsp(:, 1) );
Pp(:, 2)    = PQ_Regroupement_BandeCritique ( Fsp(:, 2) );
Ppnoise     = PQ_Regroupement_BandeCritique ( Fspnoise );

% Ajout de brut interne => "Pitch patterns"
% -----------------------------------------
Pp(:, 1) = Pp(:, 1) + Ppthres;
Pp(:, 2) = Pp(:, 2) + Ppthres;

% Etalement des bandes critiques => "Unsmeared excitation patterns"
% -----------------------------------------------------------------
E2(:, 1) = PQ_Etalement_BandeCritique ( Pp(:, 1) );
E2(:, 2) = PQ_Etalement_BandeCritique ( Pp(:, 2) );
