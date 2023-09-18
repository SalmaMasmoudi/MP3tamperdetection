
function Pe = PQ_Regroupement_BandeCritique (Fsp)
% Group a DFT energy vector into critical bands
% FFT_X2 - DSP
% Eb - Excitation vector (fractional critical bands)

% P. Kabal $Revision: 1.2 $  $Date: 2004/02/05 04:25:46 $
global N_PEAQ Fe Nc Nc fc fl fu dz

persistent kl ku Ul Uu

Emin = 1e-12;

if (isempty (kl) )
    
    % Set up the DFT bin to critical band mapping
    Fres = Fe / N_PEAQ;
    kl = zeros(Nc, 1);      ku = zeros(Nc, 1);
    Ul = zeros(Nc, 1);      Uu = zeros(Nc, 1);
    
    
    for (i = 0:Nc-1)
        fli = fl(i+1);
        fui = fu(i+1);
        for (k = 0:N_PEAQ/2)
            if ((k+0.5)*Fres > fli)
                kl(i+1) = k;        % First bin in band i
                Ul(i+1) = (min(fui, (k+0.5)*Fres) - max(fli, (k-0.5)*Fres)) / Fres;
                break;
            end
        end
        for (k = N_PEAQ/2:-1:0)
            if ((k-0.5)*Fres < fui)
                ku(i+1) = k;        % Last bin in band i
                if (kl(i+1) == ku(i+1))
                    Uu(i+1) = 0;       % Single bin in band
                else
                    Uu(i+1) = (min(fui, (k+0.5)*Fres) - max(fli, (k-0.5)*Fres)) / Fres;
                end
                break;
            end
        end
    end

end

% Allocate storage
Ea = zeros (Nc, 1);
Pe = zeros (Nc, 1);

% Compute the excitation in each band
for (i = 0:Nc-1)
    Ea = Ul(i+1) * Fsp(kl(i+1)+1);       % First bin
    for (k = (kl(i+1)+1):(ku(i+1)-1))
        Ea = Ea + Fsp(k+1);              % Middle bins
    end
    Ea = Ea + Uu(i+1) * Fsp(ku(i+1)+1);  % Last bin
    Pe(i+1) = max(Ea, Emin);
end


