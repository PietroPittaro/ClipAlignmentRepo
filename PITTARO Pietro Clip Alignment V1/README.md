# Progetto Clip-Aligment 

Progetto del Corso di Elaborazione dell'Audio Digitale del Politecnico di Torino
		 Anno Accademico 2017/208

Studente: PITTARO Pietro matr. 198000   

## Codice

Il programma è contenuto nel file principale
	CLIP_ALIGNMENT_ATEST.m
e nelle due funzioni contenute nei files:
	RicSilenzioZero.m
	VerAllin.m

che eseguono rispettivamente la ricerca dell'inizio del "silenzio" e il calcolo del disallineamento dei due Frames ricevuti in input
NOTA: La ricerca del "silenzio" in questa prima versione si limita a verificare il livello ad disotto di una certa soglia per un certo 
tempo per individuarne l'inizio. E' stata mantenuto come durata del silenzio il valore di disallineamento già calcolato dalla 
crosscorrelazione. E' stato, a titolo indicativo, inserito una funzione di filtraggio del Frame su cui cercare il silenzio ipotizzando che
il segnale introdotto dal device possa avere una caratteristica particolare e che possa essere eliminata da un filtro opportuno.

Le prove effettuate con questo codice sono state realizzate con files audio estratti da un audiovideo realizzato da me su PC e un audio corrispondente registrato da un cellulare.
Le registrazioni fatte (che erano di qualche decina di secondi) sono state poi allineate e modificate per inserire nella traccia audio del cellulare 2 silenzi (ampiezza zero) di durata 4 sec e alternativamente di un ritardo iniziale per poter verificare il corretto funzionamento dell'algoritmo per la gestione del ritardo iniziale e l'individuazione ed eliminazione dei due ritardi e del drift totale.
Con gli audio della reale lezione forniti come esempio si è verificato il corretto funzionamento dell'algoritmo di scansione e riconoscimento del disallineamento pur non potendo individuare con l'attuale algoritmo il corretto inizio dell'inizio silenzio.

    % Tracce utilizzate per test di sviluppo:
% Introdotto 2 silenzi (ampiezza=0) di 4 sec in tutti i files

% Caso 1  - traccia Audio Micr con aggiunta di 3 sec iniziali di valore costante
    % Load Audio da Video
    [AudioV, fsAV] = audioread('SyncIniAudioV312s-T.wav');
    % Load Audio da "Mic"(cellulare)
    [AudioM, fsAM] = audioread('SyncIniAudioM323s3T-t.wav');

% Caso 2  - traccia Audio Video con aggiunta di 3 sec iniziali di valore costante
        % Load Audio da Video
      [AudioV, fsAV] = audioread('SyncIniAudioV315s3T-T.wav');
        % Load Audio da "Mic"(cellulare)
      [AudioM, fsAM] = audioread('SyncIniAudioM320sTT-T.wav');



## Configurazione
Nella parte iniziale del programma sono definiti i valori di inizializzazione dei parametri
di controllo della funzionalità:

    % Definizione nome file Audio da Video
    nomeFileV = 'xxxx';
    % Definizione nome file Audio da "Mic"(cellulare)
    nomeFileM = 'xxxx';
        
    % Definizione nome file di Output
    FileNameOut = 'xxxx';


% Massimo disallineamento iniziale ammesso in sec
W_Ini = 
% Finestra Blocco avanzamento analisi allineamento in sec
W_Ava = 
% Finestra verifica sincronizzazione in sec
W_Ver = 
% Avanzamento Finestra Ricerca silenzio (spezzone estraneo) in sec
W_Ric =
% Finestra Verifica deriva totale in sec (indietro a partire da fine file
% meno  W_Ver per distanziarmi dal bordo)
W_Der =

% Soglia "Perfetto" allineamento xCorr in conteggi
SogliaPal =
% Soglia Deriva minima (al fondo della traccia) da correggere in conteggi
SogliaDer = 

## Risultati dei test

CASO 1 e CASO 2
Il programma si è dimostrato  funzionante con l'attuale algoritmo di individuazione dell'inizio silenzio con i miei files che hanno disturbo di ampiezza=0. In questo caso si è verificato che viene gestito correttamente il:
- Individuazione del disallineamento iniziale
- Individuazione ed eliminazione dei pezzi estranei
- Gestione dell'eventuale Drift totale a fine traccia.

I 2 files di output generati dal programma di allineamento sono stati confrontati con la traccia audio del video e sono risultati perfettamente sovrapposti nell'ascolto congiunto 

Nel caso invece dell'audio della reale lezione il programma ha individuato il disallineamento iniziale a:

265.998 sec - traccia audio del Video inizia 265.998 sec dopo quella del cellulare

Poi il programma evidenzia un disallineamento (deriva) di circa 2 msec ogni 2' che il più delle volte viene corretta dal programma (è vista in questo caso come un introduzione di pezzo estraneo nella traccia del cellulare e visto che la soglia di "perfetto allineamento" che è impostata a 1 msec).
Quando l'algoritmo di individuazione del silenzio (che in questo caso non è assolutamente adeguato)  trova una condizione corretta di inizio silenzio questo viene eliminato altrimenti verrà fatto nei blocchi successivi.
L'algoritmo di verifica dell'allineamento evidenzia l'introduzione di un audio estraneo di lunghezza 1,19 secondi nel blocco n.10 tra 1326 sec e 1446 sec. ma non ne trova ovviamente l'esatta posizione.

Nel file Report Test Clip Alignment.doc sono presenti i report dell'elaborazione dei 3 casi

