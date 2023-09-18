function MOV = PQ_Moyennage_MOVC (MOVC)
% Time average MOV precursors

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:34:46 $
global N_PEAQ Fe N_adv

Fss = Fe / N_adv;
tdel = 0.5;
tex = 0.050;

% BandwidthRefB, BandwidthTestB
[MOV(1), MOV(2)] = PQ_avgBW (MOVC.BW);

% Total NMRB, RelDistFramesB
[MOV(3), MOV(11)] = PQ_avgNMRB (MOVC.NMR);

% WinModDiff1B, AvgModDiff1B, AvgModDiff2B
Ndel = ceil (tdel * Fss);
[MOV(4), MOV(7), MOV(8)] = PQ_avgModDiffB (Ndel, MOVC.MDiff);

% RmsNoiseLoudB
N50ms = ceil (tex * Fss);
Nloud = PQloudTest (MOVC.Loud);
Ndel = max (Nloud + N50ms, Ndel);
MOV(9) = PQ_avgNLoudB (Ndel, MOVC.NLoud);

% ADBB, MFPDB
[MOV(5), MOV(10)] = PQ_avgPD (MOVC.PD);

% EHSB
MOV(6) = PQ_avgEHS (MOVC.EHS);

%-----------------------------------------
function EHSB = PQ_avgEHS (EHS)

Np = length (EHS.EHS);
s = sum( PQ_LinPosAvg (EHS.EHS) );
EHSB = 1000 * s;

    
%-----------------------------------------
function [ADBB, MFPDB] = PQ_avgPD (PD)

c0 = 0.9;
    c1 = 1;

N = length (PD.Pc);
Phc = 0;
Pcmax = 0;
Qsum = 0;
nd = 0;
for (i = 0:N-1)
    Phc = c0 * Phc + (1 - c0) * PD.Pc(i+1);
    Pcmax = max (Pcmax * c1, Phc);

    if (PD.Pc(i+1) > 0.5)
        nd = nd + 1;
        Qsum = Qsum + PD.Qc(i+1);
    end
end

if (nd == 0)
    ADBB = 0;
elseif (Qsum > 0)
    ADBB = log10 (Qsum / nd);
else
    ADBB = -0.5;
end

MFPDB = Pcmax;

%-----------------------------------------
function [TotalNMRB, RelDistFramesB] = PQ_avgNMRB (NMR)

Thr = 10^(1.5 / 10);

TotalNMRB = 10 * log10 (PQ_LinAvg (NMR.NMRavg));
RelDistFramesB =  PQ_FractThr (Thr, NMR.NMRmax);

%-----------------------------------------
function [BandwidthRefB, BandwidthTestB] = PQ_avgBW (BW)

BandwidthRefB  = PQ_LinPosAvg (BW.BWRef);
BandwidthTestB = PQ_LinPosAvg (BW.BWTest);

%-----------------------------------------
function [WinModDiff1B, AvgModDiff1B, AvgModDiff2B] = PQ_avgModDiffB (Ndel, MDiff)

global N_PEAQ Fe N_adv

Fss = Fe / N_adv;
tavg = 0.1;
Np = length(MDiff.Mt1B);

% Sliding window average - delayed average
L = floor (tavg * Fss);     % 100 ms sliding window length
WinModDiff1B = PQ_WinAvg (L, MDiff.Mt1B(Ndel+1:Np-1+1));

% Weighted linear average - delayed average
AvgModDiff1B = PQ_WtAvg (MDiff.Mt1B(Ndel+1:Np-1+1), MDiff.Wt(Ndel+1:Np-1+1));

% Weighted linear average - delayed average
AvgModDiff2B = PQ_WtAvg (MDiff.Mt2B(Ndel+1:Np-1+1), MDiff.Wt(Ndel+1:Np-1+1));

%-----------------------------------------
function RmsNoiseLoudB = PQ_avgNLoudB (Ndel, NLoud)
Np = length (NLoud.NL);
% RMS average - delayed average and loudness threshold
RmsNoiseLoudB = PQ_RMSAvg (NLoud.NL(Ndel+1:Np-1+1));

%-----------------------------------
% Average values values, omitting values which are negative
function s = PQ_LinPosAvg (x)

N = length(x);

Nv = 0;
s = 0;
for (i = 0:N-1)
    if (x(i+1) >= 0)
        s = s + x(i+1);
        Nv = Nv + 1;
    end
end

if (Nv > 0)
    s = s / Nv;
end

%----------
% Fraction of values above a threshold
function Fd = PQ_FractThr (Thr, x)

N = length (x);

Nv = 0;
for (i = 0:N-1)
    if (x(i+1) > Thr)
        Nv = Nv + 1;
    end
end

if (N > 0)
    Fd = Nv / N;
else
    Fd = 0;
end

%-----------
% Sliding window (L samples) average
function s = PQ_WinAvg (L, x)

N = length (x);

s = 0;
for (i = L-1:N-1)
    t = 0;
    for (m = 0:L-1)
        t = t + sqrt (x(i-m+1));
    end
    s = s + (t / L)^4;
end

if (N >= L)
    s = sqrt (s / (N - L + 1));
end

%----------
% Weighted average
function s = PQ_WtAvg (x, W)

N = length (x);

s = 0;
sW = 0;
for (i = 0:N-1)
    s = s + W(i+1) * x(i+1);
    sW = sW + W(i+1);
end

if (N > 0)
    s = s / sW;
end

%----------
% Linear average
function LinAvg = PQ_LinAvg (x)

N = length (x);
s = 0;
for (i = 0:N-1)
    s = s + x(i+1);
end

LinAvg = s / N;

%----------
% Square root of average of squared values
function RMSAvg = PQ_RMSAvg (x)

N = length (x);
s = 0;
for (i = 0:N-1)
    s = s + x(i+1)^2;
end

if (N > 0)
    RMSAvg = sqrt(s / N);
else
    RMSAvg = 0;
end

%-----------
function Ndel = PQloudTest (Loud)
% Loudness threshold

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:34:46 $

Np = length (Loud.NRef);
Thr = 0.1;

% Loudness threshold

    Ndel = min (Np, PQ_LThresh (Thr, Loud.NRef, Loud.NTest) );

%-----------
function it = PQ_LThresh (Thr, NRef, NTest)
% Loudness check: Look for the first time, the loudness exceeds a threshold
% for both the test and reference signals.

Np = length (NRef);

it = Np;
for (i = 0:Np-1)
    if (NRef(i+1) > Thr & NTest(i+1) > Thr)
        it = i;
        break;
    end
end
