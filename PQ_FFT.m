function FFTx = PQDFTFrame (xn)
% Calculate the DFT of a frame of data (NF values), returning the
% squared-magnitude DFT vector (NF/2 + 1 values)

% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:32:57 $

global N_PEAQ Fe

persistent fenetre_hanning

% Création de la fenetre de Hanning
% + normalisation de l'amplitude
if (isempty (fenetre_hanning))
    Amax = 32768;
    f0 = 1019.5;
    Lp = 92;
    
    % Calcul du gain pour la fenetre de Hanning
    W = N_PEAQ - 1;
    f0N = f0/Fe;    %  fcN - Normalized sinusoid frequency (0-1)
    
    df = 1 / N_PEAQ;
    k = floor (f0N / df);
    dfN = min ((k+1) * df - f0N, f0N - k * df);
    
    dfW = dfN * W;
    gp = sin(pi * dfW) / (pi * dfW * (1 - dfW^2));
    
    GL = 10^(Lp / 20) / (gp * Amax/4 * W);

    axe_temps = (0:N_PEAQ - 1)';
    hw = 0.5 * (1 - cos(2 * pi * axe_temps / (N_PEAQ-1)));
    fenetre_hanning = GL * hw;
end

% Pondération par la fenetre de hanning
xw = fenetre_hanning .* xn;

% DFT (output is real followed by imaginary)
fft_xn = PQ_RFFT (xw, N_PEAQ, 1);

% DSP
FFTx = PQ_DSP (fft_xn, N_PEAQ);
