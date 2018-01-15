% EAD Projet 2018 - Clip Allignment
% PITTARO Pietro
clear all; close all; clc;

% %Preset per test di sviluppo (files corti )
% % Massimo disallineamento iniziale ammesso in sec
% W_Ini = 12.5; % 12 sec
% % Finestra Blocco avanzamento analisi allineamento in sec
% W_Ava = 26; % 13; % 1 sec
% % Finestra verifica sincronizzazione in sec
% W_Ver = 10; % 10 sec
% % Avanzamento Finestra Ricerca silenzio (spezzone estraneo)in sec
% W_Ric = 1; % 1 sec
% % Finestra Verifica deriva totale in sec (indietro a partire da fine file
% meno  W_Ver per distanziarmi dal bordo)
% W_Der = 10; % 10 sec

%Preset per test caso studio
% Massimo disallineamento iniziale ammesso in sec
W_Ini = 300;
% Finestra Blocco avanzamento analisi allineamento in sec
W_Ava = 120; % 
% Finestra verifica sincronizzazione in sec
W_Ver = 10; % 20 sec
% Avanzamento Finestra Ricerca silenzio (spezzone estraneo) in sec
W_Ric = 1; % 1 sec
% % Finestra Verifica deriva totale in sec (indietro a partire da fine file
% meno  W_Ver per distanziarmi dal bordo)
W_Der = 20; % 20 sec

% Soglia "Perfetto" allineamento xCorr
SogliaPal = 44;   % (1/100 sec.)
% Soglia Deriva minima da correggere in conteggi
SogliaDer = 10;  %   % Limite volutamente basso per test

    % Tracce utilizzate per test di sviluppo:
% Introdotto 2 silenzi (ampiezza=0) di 4 sec in tutti i files

% Caso 1  - traccia Audio Micr con aggiunta di 3 sec iniziali di valore costante
    % Definizione nome file di Audio da Video
%     nomeFileV = 'SyncIniAudioV312s-T.wav';
    % Definizione nome file di Audio da "Mic"(cellulare)
%     nomeFileM = 'SyncIniAudioM323s3T-t.wav';

% Caso 2  - traccia Audio Video con aggiunta di 3 sec iniziali di valore costante
        % Definizione nome file di Audio da Video
%        nomeFileV = 'SyncIniAudioV315s3T-T.wav';
        % Definizione nome file di Audio da "Mic"(cellulare)
%        nomeFileM = 'SyncIniAudioM320sTT-T.wav';
 
% Caso 3 - trace date dal Professore
    % Definizione nome file di Audio da Video
    nomeFileV = 'AudioV_Lez.wav';
    % Definizione nome file di Audio da "Mic"(cellulare)
    nomeFileM = 'AudioM_Lez.wav';
      
    [AudioV, fsAV] = audioread(nomeFileV);
    [AudioM, fsAM] = audioread(nomeFileM);
    
    % Definizione nome file di Output
    FileNameOut = 'SyncAudioOUT.wav';

% Eventuale sottocampionamento se tempi elaborazione troppo elevati

if fsAV ~=  fsAM 
    fprintf ('File with sampling time different not accepted')
    exit()
end    

% Massimo disallineamento iniziale ammesso in campioni
W_Ini_Samples = W_Ini*fsAV;
% Finestra avanzamento analisi allineamento in campioni
W_Ava_Samples = W_Ava*fsAV;
% Finestra verifica sincronizzazione in campioni
W_Ver_Samples = W_Ver*fsAV;
% Finestra iniziale ricerca silenzio (spezzone estraneo) in campioni
W_Ric_Samples = W_Ric*fsAV; % 1 sec
% Finestra iniziale ricerca silenzio (spezzone estraneo) in campioni
W_Der_Samples = W_Der*fsAV; 


% Lunghezze Tracce audio
LenAudioV = length(AudioV); 
LenAudioM = length(AudioM);

% Stampa Legenda

fprintf ('Program for Audio Clip Alignment \nInputFile audio-Video: \t%s \tLen= %d (%f sec) \nInputFile audio micro: \t%s \tLen= %d (%f sec)\nOutputFile: %s \tLen= %d (%f sec)\n\n', nomeFileV ,LenAudioV,LenAudioV/fsAV, nomeFileM,LenAudioM, LenAudioM/fsAM,FileNameOut,LenAudioV,LenAudioV/fsAV);
fprintf ('FS= %d Hz\tInitial Sync window= %.2f sec\tWindow Block= %.2f sec\tWindow analysis= %.2f sec\tThreshold= %d count\n',fsAV,W_Ini,W_Ava,W_Ver,SogliaPal);

IniAudioV = AudioV(1:W_Ini_Samples);
IniAudioM = AudioM(1:W_Ini_Samples);

corr = xcorr (IniAudioV,IniAudioM,W_Ini_Samples);
[corrCoeff lag] = xcorr (IniAudioV,IniAudioM,W_Ini_Samples,'coeff');


% Grafico della correlazione   
figure;
hold on;
plot (linspace(-W_Ini,W_Ini,length(corr)),corr);
plot (linspace(-W_Ini,W_Ini,length(corrCoeff)),corrCoeff);
legend('xCorr V vs M','xCorr coeff');
ylabel('xCorr Amplitude');
xlabel('Time(sec)');
grid on;
hold off;

% Trovo il valore di correlazione massimo per entrambi VvsM norm e non
[VmaxVvsM, IdxVvsM]            = max(corr);
[VmaxVvsMCoeff, IdxVvsMCoeff]  = max(corrCoeff);

% Calcolo dell' Offset per entrambi VvsM norm e non
OffsetVvsM      = abs (W_Ini_Samples - IdxVvsM + 1);
OffsetVvsMCoeff = abs (W_Ini_Samples - IdxVvsMCoeff + 1);

% Controllo se il valore può essere considerato corretto (empirico .. da verificare)
% No ! non è sempre corretto..! verificato con prove successive

MeanVal        = sqrt(mean(corr.^2));
MeanValCoeff   = sqrt(mean(corrCoeff.^2));
MeanValQ       = mean(sqrt(corr.^2));
MeanValCoeffQ  = mean(sqrt(corrCoeff.^2));

MeanValAbs        = mean(abs(corr));
MeanValCoeffAbs   = mean(abs(corrCoeff));

RatioCorr = MeanVal / VmaxVvsM;
RatioCorrCoeff = MeanValCoeff / VmaxVvsMCoeff;
if RatioCorrCoeff > 0.045 
    fprintf (' WARNING MESSAGE: MAY BE NOT A VALID MATCH FOUND \n');
end

% Imposto i puntatori per scorrimento congruente delle due tracce

if IdxVvsM > W_Ini_Samples
    % il Video inizia prima del Microfono
    IdxStartV = OffsetVvsM;
    IdxStartM = 1;
else
    % il Microfono inizia prima del Video
    IdxStartV = 1;
    IdxStartM = OffsetVvsM;
end

fprintf ('Initial misalignment = %d (%f sec)\n',IdxStartM-IdxStartV,(IdxStartM-IdxStartV)/fsAV);

 
% Azzero traccia da costruire
AudioSync = zeros(LenAudioV,1);
%   Oppure
AudioSync = AudioV;

% Se Audio Video inizia prima o Audio Microfono finisce prima 
% posso decidere se lasciare l'audio del video o se "azzerare" la parte 
% senza il corrispondente audio da Microfono.
% Da un punto di vista realizzativo si tratta di scegliere se inzializzare 
% con 0 oppure se fare una copia dell'audio del Video
% la traccia di output oppure lasciare quella registrata nella traccia video. 


IdxOut = IdxStartV;     % indice di scorrimento scrittura file output
IdxDV  = IdxStartV;     % indice di scorrimento file AudioV
IdxDM  = IdxStartM;     % indice di scorrimento file AudioM 

% Contatore dei Blocchi
BlockNum = 0;
% Per gestione dimensioni Blocchi non molto più grandi di finestra  
MemDisFineBlocco = 0;
% TMP debug file corti

% IdxDV = IdxDV + 10*fsAV;
% IdxDM = IdxDM + 10*fsAM;
    
while ( (IdxDV + W_Ava_Samples) < LenAudioV && (IdxDM + W_Ava_Samples) < LenAudioM)
    
   FrameV = AudioV(IdxDV + W_Ava_Samples - W_Ver_Samples: IdxDV + W_Ava_Samples-1);
   FrameM = AudioM(IdxDM + W_Ava_Samples - W_Ver_Samples: IdxDM + W_Ava_Samples-1);
    
   BlockNum = BlockNum +1;
   
%    % Plot sezione di confronto   
%     figure;
%     hold on;
%     plot (FrameV);
%     plot (FrameM);
%     legend('Frames di confronto');
%     ylabel('Wave Amplitude');
%     xlabel('Samples');
%     grid on;
%     hold off;
      
    % Azzero contatore inizio eventuale silenzio nel Frame mic attuale
    IniSilenzio = 0;

   % Verifico allineamento della finestra di analisi al fondo del Frame
   % Calcolo dell' Offset 
   
   OffsetD = VerAllin (FrameV,FrameM);
    
   fprintf ('Video Block N=%3d\tOffset=%6d (%5.4fsec)\tfrom\t%8d (%5.4fsec)\tto\t%8d (%5.4fsec)\n',BlockNum,OffsetD,OffsetD/fsAV,IdxDV+W_Ava_Samples-W_Ver_Samples,(IdxDV+W_Ava_Samples-W_Ver_Samples)/fsAV,IdxDV+W_Ava_Samples-1,(IdxDV+W_Ava_Samples-1)/fsAV);
   fprintf ('Micro Block N=%3d\tOffset=%6d (%5.4fsec)\tfrom\t%8d (%5.4fsec)\tto\t%8d (%5.4fsec)\n',BlockNum,OffsetD,OffsetD/fsAV,IdxDM+W_Ava_Samples-W_Ver_Samples,(IdxDM+W_Ava_Samples-W_Ver_Samples)/fsAV,IdxDM+W_Ava_Samples-1,(IdxDM+W_Ava_Samples-1)/fsAV);
 
   
   % Controllo se allineamento mantenuto 
   % IPOTESI traccia Microfono sempre più grande di quella Video
   % perchè inserimenti dei "silenzio" solo da microfono
   % OffsetD < Soglia perfetto allineamento => Continua verifica 
   % IPOTESI di durata del silenzio per Blocco sempre inferiore a finestra di analisi
      
   % Se traccia audio del Video "in avanti" => Condizione non ammessa per
   % ora solo segnalazione poi dovrebbe essere errore perchè
   % IPOTESI: solo traccia del microfono può avere inserimenti di "silenzio"
   
   if OffsetD > SogliaPal 
        fprintf ('ERROR MESSAGE: Microphone delayed %d (%.4f sec) refered to the Video track \n ');
		% Se gestito si può definire una soglia di tolleranza maggiore 
		%         exit();
   end
   
   if abs(OffsetD) > SogliaPal
       % Frame con disallineamento
       % Salvo Offset calcolato per il Frame corrente       
  
       % Verifico offset tornando indietro di una finestra di analisi
       FrameV = AudioV(IdxDV + W_Ava_Samples - 2*W_Ver_Samples: IdxDV + W_Ava_Samples - W_Ver_Samples -1);
       FrameM = AudioM(IdxDM + W_Ava_Samples - 2*W_Ver_Samples: IdxDM + W_Ava_Samples - W_Ver_Samples -1);
       OffsetD2 = VerAllin (FrameV,FrameM);
       fprintf ('Block N=%d \twith misalignment - Offset = %d and %d \n',BlockNum, OffsetD, OffsetD2);  
    
       if (abs(OffsetD2 - OffsetD) > SogliaPal)  &&  (MemDisFineBlocco == 0)   
           % Se non avevo già trovato "silenzio" nella finestra di confronto del blocco precedente
           % allora in questo caso "silenzio" presente nei due ultimi Frame
           % di questo blocco ( Potrebbe essere solo nell'ultimo o in entrambi)
           % Se avevo già trovato disallineamento nella finestra di confronto 
           % del blocco precedente allora salto il confronto dei due valori di disallineamento e considero valido
           % il disallineamento dell'ultimo frame del blocco 
                      
           MemDisFineBlocco = 1;    % Blocco con disallineamento al fondo
           if abs(OffsetD) < SogliaPal
               % penultimo Frame allineato quindi ritardo solo nell'ultimo
               % sposto la finestra del Blocco di un Frame indietro e riparto col ciclo 
               % Avrò il silenzio all'inizio del successivo blocco
               OffsetD = 0;
               RiduciFrameW_Ver = 1;    % blocco da ridurre di 1 finestra di verifica
    
           else
               % Silenzio presente in entrambi => semplifico la gestione avendo ipotizzato un solo silenzio per blocco
               % sposto allora solo la finestra del Blocco di 2 Frames indietro e riparto col ciclo 
               OffsetD = 0;
               RiduciFrameW_Ver = 2.5;    % blocco da ridurre di 2,5 finestre di verifica

           end
           
       else
           % Il "silenzio" non è negli ultimi due frame
           % Per agevolare la ricerca dell'inizio del silenzio allargo la
           % finestra del blocco nella parte iniziale prendendo parte del blocco precedente
           % che sicuramente è allineato (tranne che primo Blocco dove non
           % posso avere parti precedenti
           MemDisFineBlocco = 0;    % Azzero flag di blocco con disallineamento al fondo
               
           if BlockNum > 1
               BloccoV = AudioV(IdxDV - (abs(OffsetD)): IdxDV + W_Ava_Samples -1);
               BloccoM = AudioM(IdxDM - (abs(OffsetD)): IdxDM + W_Ava_Samples -1);
           else
               BloccoV = AudioV(IdxDV : IdxDV + W_Ava_Samples -1);
               BloccoM = AudioM(IdxDM : IdxDM + W_Ava_Samples -1);
             end
           
           % [IniSilenzio TempoSilenzio] = RicSilenzio(BloccoV,BloccoM,abs(OffsetD),W_Ric_Samples);
                % [IniSilenzio TempoSilenzio] = RicSilenzioZero(BloccoV,BloccoM,abs(OffsetD),W_Ric_Samples);
                % IPOTESI "silenzio" = segnale al di sotto di una certa
                % soglia (es. 0.01) in modo continuativo per metà della finestra individuata 
                % 0.01 => 391413 conteggi = 8.87 sec
                % 0.001 => 396902           = 9 sec    OK corretto
                
           [IniSilenzio TrovatoSilenzio] = RicSilenzioZero(BloccoV,BloccoM,abs(OffsetD/2),0.001);
           
           if TrovatoSilenzio == 0
                IniSilenzio = 0;
                fprintf ('ERROR MESSAGE: NOISE NOT IDENTIFIED \n');
        %         exit();
           else
               % Ricalcolo inizio silenzio rispetto al Frame non maggiorato
                IniSilenzio = IniSilenzio - abs(OffsetD);
                if IniSilenzio > 1
                    fprintf ('NOISE FOUND in the Frame n. %d at %f sec and length %f sec \n', BlockNum, IniSilenzio/fsAV, abs(OffsetD)/fsAV );
                else
                    % inizio trovato nell'extra parte iniziale ma
                    % condizione non possibile. ricondotto a Noise non identificato
                    IniSilenzio = 0;
                    fprintf ('ERROR MESSAGE: NOISE NOT IDENTIFIED \n');
        %         exit();
                end
           end
           
       end
   else
       % Offset inferiore alla soglia minima: lo assegno = 0  
       OffsetD = 0;
   end
   
   % Scrittura traccia output
   
   if IniSilenzio == 0
       IniSilenzio = 1;
   end
   
   fprintf ('Write file OUTPUT from %8d to %8d with AudioMic from %8d to %8d AND from %8d to %8d \n',IdxOut,IdxOut+W_Ava_Samples-1,IdxDM,(IdxDM+IniSilenzio-1),(IdxDM+IniSilenzio+abs(OffsetD)),(IdxDM+abs(OffsetD)+W_Ava_Samples-2));

   BloccoOut = [AudioM(IdxDM:IdxDM+IniSilenzio-1);AudioM(IdxDM+IniSilenzio+abs(OffsetD)-1:IdxDM+abs(OffsetD)+W_Ava_Samples-2)];
    
   AudioSync(IdxOut:IdxOut+W_Ava_Samples-1) = BloccoOut;
   
   if MemDisFineBlocco > 0
       % se disallineamento al fondo del Blocco modifico i puntatori per
       % inglobarlo nel blocco successivo
       IdxDV  = IdxDV  - RiduciFrameW_Ver * W_Ver_Samples; 
       IdxDM  = IdxDM  - RiduciFrameW_Ver * W_Ver_Samples; 
       IdxOut = IdxOut - RiduciFrameW_Ver * W_Ver_Samples; 
       RiduciFrameW_Ver = 0;
   end
   
   IdxOut = IdxOut + W_Ava_Samples;         
   IdxDV  = IdxDV  + W_Ava_Samples; 
   IdxDM  = IdxDM  + W_Ava_Samples + abs(OffsetD); 
   
%    fprintf ('IxsDV and IdxDM %d \t %d \n',IdxDV,IdxDM);
   
end
   
% Fine ciclo - devo gestire il residuo delle due tracce
BlockNum = BlockNum +1;
	
ResiduoV = LenAudioV-IdxDV;
ResiduoM = LenAudioM-IdxDM;

% Accorgimento per caso di Audio mic di lunghezza inferiore
IdxLast = min(ResiduoV,ResiduoM);   

fprintf ('Video Block (residue) n =%3d  to the END=%6d (%5.4fsec)\tfrom %8d (%5.4fsec)\tto %8d (%5.4fsec)\n',BlockNum,ResiduoV,ResiduoV/fsAV,IdxDV,IdxDV/fsAV,LenAudioV,LenAudioV/fsAV);
fprintf ('Micro Block (residue) n =%3d  to the END=%6d (%5.4fsec)\tfrom %8d (%5.4fsec)\tto %8d (%5.4fsec)\n',BlockNum,ResiduoM,ResiduoM/fsAV,IdxDM,IdxDM/fsAV,LenAudioM,LenAudioM/fsAV);

BloccoOut = AudioM(IdxDM:IdxDM+IdxLast-1);  
fprintf ('Write file OUTPUT last Block from\t%8d to\t%8d with AudioMic from\t%8d to\t%8d LEN= %8d \n',IdxOut,IdxOut+IdxLast-1,IdxDM,IdxDM+IdxLast-1,length(BloccoOut));

AudioSync(IdxOut:IdxOut+IdxLast-1) = BloccoOut;
   
% Verifica e correzione deriva
% IPOTESI che il file audio microfono sia più lungo(di contenuto) di quello audio e
% quindi traccia audio del video e traccia audio ricostruita siano
% corrispondenti fino al fondo della traccia

%  
% % AudioV e AudioSyn stessa dimensione
FrameV = AudioV(LenAudioV - W_Der_Samples - W_Ver_Samples: LenAudioV - W_Ver_Samples -1);
FrameM = AudioSync(LenAudioV - W_Der_Samples - W_Ver_Samples: LenAudioV - W_Ver_Samples -1);
OffsetD = VerAllin (FrameV,FrameM);
fprintf ('Total Drift = %d \n', OffsetD);  

    
% Se drift totale maggiore della soglia impostata eseguo aggiustamento
if abs(OffsetD) > SogliaDer
   pasCor = round(LenAudioV / abs (OffsetD));
   IdxC = 1;
   if OffsetD < 0
       % Traccia audio del video "indietro" => elimino campioni
       % dalla traccia audio microfono. Posso poi completare la dimensione della 
       % traccia con i campioni successivi della traccia mic
       while ( pasCor * IdxC < LenAudioV )
           AudioSync(pasCor*IdxC:end-1) = AudioSync(pasCor*IdxC+1:end);
           IdxC = IdxC + 1;
       end
       if (IdxDM+IdxLast+IdxC < LenAudioM) 
            AudioSync(end-IdxC+1:end) = AudioM (IdxDM+IdxLast:IdxDM+IdxLast+IdxC-1);
       end
       % Tralascio la codifica della copia parziale   

   else
       % Traccia audio del microfono "indietro" => "inserisco"
       % campioni nella traccia audio microfono
       while ( pasCor * IdxC < LenAudioV )
           AudioSync(pasCor*IdxC+1:end) = AudioSync(pasCor*IdxC:end-1);
           IdxC = IdxC + 1;
       end

   end
end




audiowrite(FileNameOut,AudioSync,fsAV); 

