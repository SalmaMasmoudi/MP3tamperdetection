function [MOVI, Filtre] = PQ_Evaluation_Trame (xn_ref, xn_test, Filtre)
% PEAQ - Process one frame with the FFT model
% P. Kabal $Revision: 1.1 $  $Date: 2003/12/07 13:32:58 $

global N_PEAQ
global visualisations


    
% Mod�le auditif
% --------------

%%%% Passage dans le domaine fr�quentiel
FFTx(:, 1) = PQ_FFT (xn_ref);
FFTx(:, 2) = PQ_FFT (xn_test);


%%%% Regroupement en bande critique et Etalement dans le domaine
%%%% fr�quentiel
[Ppnoise, E2] = PQ_Excitation_BandeCritique (FFTx);

%%%% Etalement dans le domain temporel => "Patterns d'excitation"
[E(:, 1), Filtre.TDS.Ef(:, 1)] = PQ_EtalementTemporel (E2(:, 1), Filtre.TDS.Ef(:, 1));
[E(:, 2), Filtre.TDS.Ef(:, 2)] = PQ_EtalementTemporel (E2(:, 2), Filtre.TDS.Ef(:, 2));

% Pr�traitement des patterns
% --------------------------

%%%% Adaptation des niveaux et des patterns => "Patterns adapt�es spectrallement"
[El, Filtre.Adap] = PQ_Adaptation (E, Filtre.Adap);

%%%% Patterns de modulation
[Mod, ERavg, Filtre.Env] = PQ_Modulation (E2, Filtre.Env);

%%%% Intensit� acoustiques
MOVI.Loud.NRef  = PQ_IntensiteAcoustique ( E(:, 1) );
MOVI.Loud.NTest = PQ_IntensiteAcoustique ( E(:, 2) );

% Calcul des variables de sorties du mod�le
% -----------------------------------------

%%%% Diff�rence de modulation => "ModDiffB"
MOVI.MDiff = PQ_MOV_ModDiffB (Mod, ERavg);

%%%% Intensit� accoustique du bruit => "NoiseLoundB"
MOVI.NLoud.NL = PQ_MOV_NoiseLoudB (Mod, El);

%%%% Largeur de bande => "BandwidthB"
MOVI.BW = PQ_MOV_BandwidthB (FFTx);

%%%% Rapport Bruit � masque => "NMRB"
MOVI.NMR = PQ_MOV_NMRB (Ppnoise, E(:, 1));

%%%% Probabilit� de d�tection
MOVI.PD = PQ_MOV_ProbabiliteDetection (E);

%%% Structure harmonique de l'erreur => "EHSB"
MOVI.EHS.EHS = PQ_MOV_EHSB (xn_ref, xn_test, FFTx);

