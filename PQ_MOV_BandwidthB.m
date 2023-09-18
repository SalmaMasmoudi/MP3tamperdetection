function BW = PQ_MOV_BandwidthB (FFTx)
% Bandwidth tests

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:34:46 $
global N_PEAQ Fe N_adv

persistent kx kl FR FT

if (isempty (kx))
    fx = 21586;
    kx = round (fx / Fe * N_PEAQ);    % 921
    fl = 8109;
    kl = round (fl / Fe * N_PEAQ);    % 346
    FRdB = 10;
    FR = 10^(FRdB / 10);
    FTdB = 5;
    FT = 10^(FTdB / 10);
end

Xth = FFTx(kx+1, 2);
for (k = kx+1:N_adv-1)
    Xth = max (Xth, FFTx(k+1, 2));
end

% BWRef and BWTest remain negative if the BW of the test signal
% does not exceed FR * Xth for kx-1 <= k <= kl+1
BW.BWRef = -1;
XthR = FR * Xth;
for (k = kx-1:-1:kl+1)
    if (FFTx(k+1, 1) >= XthR)
        BW.BWRef = k + 1;
        break;
    end
end

BW.BWTest = -1;
XthT = FT * Xth;
for (k = BW.BWRef-1:-1:0)
    if (FFTx(k+1, 2) >= XthT)
        BW.BWTest = k + 1;
        break;
    end
end
