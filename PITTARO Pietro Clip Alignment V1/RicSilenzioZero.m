function  [IniSilenzio Durata] = RicSilenzioZero(BloccoV,BloccoM,W_Comp_Samples,Soglia)

	IdxB = 1;
	IdxW = 0;
	IniSilenzio = 0;
    Durata = 0;
    
    % IPOTESI di Filtro per eliminare "silenzio" introdotto
    % Esempio non abilitato di filtro a media mobile
%     FinestraFiltro = 100;  % 1/441 sec
%     FiltroMM = ones(1, FinestraFiltro)/FinestraFiltro;
%     BloccoMF = filter(FiltroMM, 1, BloccoM);
    
    BloccoMF = BloccoM;
    
%     % Grafico del blocco con silenzio   
%     figure;
%     hold on;
%     plot (BloccoM);
%     plot (BloccoMF);
%         legend('Blocco & Filtro');
%     ylabel(' Amplitude');
%     xlabel('campioni');
%     grid on;
%     hold off;
    
	while (IdxB ) < length(BloccoMF)
	
        if abs (BloccoMF(IdxB)) < Soglia
            IdxW = IdxW+1;
        else
            IniSilenzio = IdxB+1;
            IdxW = 0;
        end
            
        if (IdxW > W_Comp_Samples)
            Durata = 1;             % Usato come Flag ricerca OK
            break;
        end
   
        IdxB = IdxB + 1;
        
      
    end
    
  
   
