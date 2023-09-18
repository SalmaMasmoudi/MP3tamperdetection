function NMR = PQ_MOV_NMRB (Ppnoise, E)
% Noise-to-mask ratio - Basic version
% NMR(1) average NMR
% NMR(2) max NMR


global Nc fc fl fu dz
persistent gm

if (isempty (gm))
    gm = zeros(Nc, 1);
    for (m = 0:Nc-1)
        if (m <= 12 / dz)
            mdB = 3;
        else
            mdB = 0.25 * m * dz;
        end
        gm(m+1) = 10^(-mdB / 10);
    end
end

NMRm = Ppnoise ./ (gm .* E);
NMR.NMRmax = max( NMRm );

s = sum( NMRm );

NMR.NMRavg = s / Nc;
