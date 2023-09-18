
function [MOVC, Nbre_fen_prec] = PQ_InitialisationMOVC(MOVC_prec, Nbre_fen)

if isempty( MOVC_prec )
    Nbre_fen_prec = 0;
    
    MOVC.MDiff.Mt1B = zeros (Nbre_fen, 1);
    MOVC.MDiff.Mt2B = zeros (Nbre_fen, 1);
    MOVC.MDiff.Wt   = zeros (Nbre_fen, 1);
    
    MOVC.NLoud.NL   = zeros (Nbre_fen, 1);
    
    MOVC.Loud.NRef  = zeros (Nbre_fen, 1);
    MOVC.Loud.NTest = zeros (Nbre_fen, 1);
    
    MOVC.BW.BWRef  = zeros (Nbre_fen, 1);
    MOVC.BW.BWTest = zeros (Nbre_fen, 1);
    
    MOVC.NMR.NMRavg = zeros (Nbre_fen, 1);
    MOVC.NMR.NMRmax = zeros (Nbre_fen, 1);
    
    MOVC.PD.Pc = zeros (Nbre_fen, 1);
    MOVC.PD.Qc = zeros (Nbre_fen, 1);
    
    MOVC.EHS.EHS = zeros (Nbre_fen, 1);
else
    % Nombre de fenetre total
    Nbre_fen_prec = length(MOVC_prec.BW.BWRef);
    Nbre_fen_total = Nbre_fen_prec + Nbre_fen;
    
    % Initialisation
    MOVC.MDiff.Mt1B = zeros (Nbre_fen_total, 1);
    MOVC.MDiff.Mt2B = zeros (Nbre_fen_total, 1);
    MOVC.MDiff.Wt   = zeros (Nbre_fen_total, 1);
    
    MOVC.NLoud.NL   = zeros (Nbre_fen_total, 1);
    
    MOVC.Loud.NRef  = zeros (Nbre_fen_total, 1);
    MOVC.Loud.NTest = zeros (Nbre_fen_total, 1);
    
    MOVC.BW.BWRef  = zeros (Nbre_fen_total, 1);
    MOVC.BW.BWTest = zeros (Nbre_fen_total, 1);
    
    MOVC.NMR.NMRavg = zeros (Nbre_fen_total, 1);
    MOVC.NMR.NMRmax = zeros (Nbre_fen_total, 1);
    
    MOVC.PD.Pc = zeros (Nbre_fen_total, 1);
    MOVC.PD.Qc = zeros (Nbre_fen_total, 1);
    
    MOVC.EHS.EHS = zeros (Nbre_fen_total, 1);
    
    % Recopie
    MOVC.MDiff.Mt1B(1:Nbre_fen_prec) = MOVC_prec.MDiff.Mt1B;
    MOVC.MDiff.Mt2B(1:Nbre_fen_prec) = MOVC_prec.MDiff.Mt2B;
    MOVC.MDiff.Wt(1:Nbre_fen_prec)   = MOVC_prec.MDiff.Wt;
    
    MOVC.NLoud.NL(1:Nbre_fen_prec)   = MOVC_prec.NLoud.NL;
    
    MOVC.Loud.NRef(1:Nbre_fen_prec)  = MOVC_prec.Loud.NRef;
    MOVC.Loud.NTest(1:Nbre_fen_prec) = MOVC_prec.Loud.NTest;
    
    MOVC.BW.BWRef(1:Nbre_fen_prec)  = MOVC_prec.BW.BWRef;
    MOVC.BW.BWTest(1:Nbre_fen_prec) = MOVC_prec.BW.BWTest;
    
    MOVC.NMR.NMRavg(1:Nbre_fen_prec) = MOVC_prec.NMR.NMRavg;
    MOVC.NMR.NMRmax(1:Nbre_fen_prec) = MOVC_prec.NMR.NMRmax;
    
    MOVC.PD.Pc(1:Nbre_fen_prec) = MOVC_prec.PD.Pc;
    MOVC.PD.Qc(1:Nbre_fen_prec) = MOVC_prec.PD.Qc;
    
    MOVC.EHS.EHS(1:Nbre_fen_prec) = MOVC_prec.EHS.EHS;
end