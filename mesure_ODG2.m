
function ODG = mesure_ODG2(signal_ref, signal_test)

global Fe N_PEAQ N_adv
global Nc fc fl fu dz


% Système d'avaluation PEAQ
% Cléo BARAS
% Version : 14 Février 2005
% A partir du code source de P. Kabal $Revision: 1.2 $  $Date: 2004/02/05 04:25:24 $

Fe = 44100;
N_PEAQ = 2048;
N_adv = N_PEAQ/2;
[Nc, fc, fl, fu, dz] = PQ_Parametres_BandeCritique;


verbose = 0;


fprintf(' *** Mesure de l''ODG ***\n');
fprintf('   Trame : ');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  fid1 = fopen( signal_ref, 'r', 'b'); %Setting Up File For Reading in Big Endian Format
%      xn = uint8( fread(fid1));
%  %xn=fread(fid1,'float');
% % %%%%%%%-----lecture de signal original-----%%%%%%%%%%%%%%%%%%%%
%  fid2 = fopen( signal_test, 'r', 'b'); %Setting Up File For Reading in Big Endian Format
%     yn = uint8( fread(fid2));
% yn=fread(fid2,'float');
% Nombre de frames totales
% ------------------------
% xn = wavread(signal_ref);
% xn = xn*32768;
% yn = wavread(signal_test);
% yn = yn*32768;

xn = mp3read(signal_ref);
xn = xn*32768;
yn = mp3read(signal_test);
yn = yn*32768;

Nbre_ech_total = min( length(xn), length(yn) );

Np = fix( Nbre_ech_total / (N_PEAQ/2) ) -1;

% Initialisaition de la structure des MOV
% ---------------------------------------
MOVC.MDiff.Mt1B = zeros (Np, 1);
MOVC.MDiff.Mt2B = zeros (Np, 1);
MOVC.MDiff.Wt   = zeros (Np, 1);
MOVC.NLoud.NL   = zeros (Np, 1);
MOVC.Loud.NRef  = zeros (Np, 1);
MOVC.Loud.NTest = zeros (Np, 1);
MOVC.BW.BWRef  = zeros (Np, 1);
MOVC.BW.BWTest = zeros (Np, 1);
MOVC.NMR.NMRavg = zeros (Np, 1);
MOVC.NMR.NMRmax = zeros (Np, 1);
MOVC.PD.Pc = zeros (Np, 1);
MOVC.PD.Qc = zeros (Np, 1);
MOVC.EHS.EHS = zeros (Np, 1);


% Initialisation des filtres mémoires
% -----------------------------------
[Nc, fc, fl, fu, dz] = PQ_Parametres_BandeCritique;
Filtre.TDS.Ef(1:Nc, 1:2) = 0;
Filtre.Adap.P(1:Nc, 1:2) = 0;
Filtre.Adap.Rn(1:Nc, 1) = 0;
Filtre.Adap.Rd(1:Nc, 1) = 0;
Filtre.Adap.PC(1:Nc, 1:2) = 0;
Filtre.Env.Ese(1:Nc, 1:2) = 0;
Filtre.Env.DE(1:Nc, 1:2) = 0;
Filtre.Env.Eavg(1:Nc, 1:2) = 0;

% Initialisation de la lecture des fichiers
% -----------------------------------------

xn_ref = zeros(N_PEAQ, 1);
xn_test = zeros(N_PEAQ, 1);
xn_ref(1:N_adv) = xn(1:N_adv);
xn_test(1:N_adv) = yn(1:N_adv);

no_fen = 0;

while (no_fen < Np)

    no_fen = no_fen + 1;

    ind_deb = (no_fen-1)*N_adv + N_adv + 1;
    ind_fin = ind_deb + N_adv - 1;
    xn_ref(N_adv + (1:N_adv)) = xn(ind_deb:ind_fin);
    xn_test(N_adv + (1:N_adv)) = yn(ind_deb:ind_fin);


    % Process a frame
    [MOV_trame, Filtre] = PQ_Evaluation_Trame (xn_ref, xn_test, Filtre);

    if (no_fen >= 1)
        % Sauvegarde des caractéristiques de la trame

        % Modulation differences
        MOVC.MDiff.Mt1B(no_fen) = MOV_trame.MDiff.Mt1B;
        MOVC.MDiff.Mt2B(no_fen) = MOV_trame.MDiff.Mt2B;
        MOVC.MDiff.Wt(no_fen)   = MOV_trame.MDiff.Wt;

        % Noise loudness
        MOVC.NLoud.NL(no_fen) = MOV_trame.NLoud.NL;

        % Total loudness
        MOVC.Loud.NRef(no_fen)  = MOV_trame.Loud.NRef;
        MOVC.Loud.NTest(no_fen) = MOV_trame.Loud.NTest;

        % Bandwidth
        MOVC.BW.BWRef(no_fen) = MOV_trame.BW.BWRef;
        MOVC.BW.BWTest(no_fen) = MOV_trame.BW.BWTest;

        % Noise-to-mask ratio
        MOVC.NMR.NMRavg(no_fen) = MOV_trame.NMR.NMRavg;
        MOVC.NMR.NMRmax(no_fen) = MOV_trame.NMR.NMRmax;

        % Error harmonic structure
        MOVC.EHS.EHS(no_fen) = MOV_trame.EHS.EHS;


        % Probability of detection (collapse frequency bands)
        MOVC.PD.Pc(no_fen) = 1 - prod( 1 - MOV_trame.PD.p);
        MOVC.PD.Qc(no_fen) = sum( MOV_trame.PD.q );


        % Print the MOV precursors
        if verbose == 1
            fprintf ('Frame: %d\n', no_fen-1);
            fprintf ('  Ntot   : %g %g\n', MOVC.Loud.NRef(no_fen), MOVC.Loud.NTest(no_fen));
            fprintf ('  ModDiff: %g %g %g\n', MOVC.MDiff.Mt1B(no_fen), MOVC.MDiff.Mt2B(no_fen), MOVC.MDiff.Wt(no_fen));
            fprintf ('  NL     : %g\n', MOVC.NLoud.NL(no_fen));
            fprintf ('  BW     : %g %g\n', MOVC.BW.BWRef(no_fen), MOVC.BW.BWTest(no_fen));
            fprintf ('  NMR    : %g %g\n', MOVC.NMR.NMRavg(no_fen), MOVC.NMR.NMRmax(no_fen));
            fprintf ('  PD     : %g %g\n', MOVC.PD.Pc(no_fen), MOVC.PD.Qc(no_fen));
            fprintf ('  EHS    : %g\n', 1000 * MOVC.EHS.EHS(no_fen));
        else
            if rem(no_fen, 10) == 0
                fprintf('%d ', no_fen);
                if rem(no_fen, 100) == 0
                    fprintf('\n           ');
                end
            end
        end
    end

    xn_ref(1:N_adv) = xn_ref(N_adv+1:N_PEAQ);
    xn_test(1:N_adv) = xn_test(N_adv+1:N_PEAQ);

end


fprintf('\n');
%%%% Moyennage temporel des sorties du modèle
MOVB = PQ_Moyennage_MOVC (MOVC);

% Neural net
ODG = PQ_ReseauNeurone (MOVB);

% Summary printout
fprintf ('   - Variables de sorties du modèle :\n');
fprintf ('       BandwidthRefB:  %g\n', MOVB(1));
fprintf ('       BandwidthTestB: %g\n', MOVB(2));
fprintf ('       Total NMRB:     %g\n', MOVB(3));
fprintf ('       WinModDiff1B:   %g\n', MOVB(4));
fprintf ('       ADBB:           %g\n', MOVB(5));
fprintf ('       EHSB:           %g\n', MOVB(6));
fprintf ('       AvgModDiff1B:   %g\n', MOVB(7));
fprintf ('       AvgModDiff2B:   %g\n', MOVB(8));
fprintf ('       RmsNoiseLoudB:  %g\n', MOVB(9));
fprintf ('       MFPDB:          %g\n', MOVB(10));
fprintf ('       RelDistFramesB: %g\n', MOVB(11));

fprintf ('   - Objective Difference Grade: %.3f\n', ODG);


fprintf('\n');
