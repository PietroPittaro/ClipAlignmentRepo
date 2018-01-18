function  [IniSilenzio Durata] = RicSilenzio(BloccoV,BloccoM,W_Comp_Samples,ShiftW)

	IdxB = 1;
	IdxW = 1;
	VetDiff = [];
    VetSomma = [];
	while (IdxB + W_Comp_Samples -1) < length(BloccoV)
	
%         		Diff = mean((abs(BloccoV(IdxB:IdxB + W_Ric_Samples -1)) - abs(BloccoM(IdxB:IdxB + W_Ric_Samples -1))));
		BloccoVabs = abs(BloccoV(IdxB:IdxB + W_Comp_Samples -1));
        BloccoMabs = abs(BloccoM(IdxB:IdxB + W_Comp_Samples -1));
        DiffVMabs = abs(BloccoVabs - BloccoMabs);
        
    xTime = linspace(0,length (BloccoVabs)/44100,length(BloccoVabs));
    figure;
    hold on;
    plot (xTime,BloccoVabs);
    plot (xTime,BloccoMabs);
    plot (xTime,DiffVMabs);
    legend('Blocchi');
    ylabel('Segnale Amplitude');
    xlabel('Time(sec)');
    grid on;
 
        Somma = sum(abs((BloccoV(IdxB:IdxB + W_Comp_Samples -1)) - (BloccoM(IdxB:IdxB + W_Comp_Samples -1))));   
        Diff = mean(abs(abs(BloccoV(IdxB:IdxB + W_Comp_Samples -1)) - abs(BloccoM(IdxB:IdxB + W_Comp_Samples -1))));
		VetDiff = [VetDiff;Diff];
        VetSomma = [VetSomma;Somma];
        fprintf ('VetDiff e Somma %d = %f %f \n',IdxW,Diff , Somma);
        IdxB = IdxB + ShiftW;
        IdxW = IdxW + 1;
      
    end
    
   
	   
    % Grafico delle differenze del Blocco con ampiezza finestra  Ricerca 
%     xTime = linspace((0-length(BloccoV)/44100),length (BloccoV)/44100,length(corrD));
    figure;
    hold on;
    plot (VetDiff);
    legend('Media Finestra Differenza');
    ylabel('Valore');
    xlabel('Finestra n');
    grid on;
    hold off;
    
        % Grafico del Blocco  
    xTime = linspace(0,length (BloccoV)/44100,length(BloccoV));
    figure;
    hold on;
    plot (xTime,BloccoV);
    plot (xTime,BloccoM);
    
    legend('Blocchi');
    ylabel('Segnale Amplitude');
    xlabel('Time(sec)');
    grid on;
    
    IniSilenzio = 1;
    Durata = 2;
