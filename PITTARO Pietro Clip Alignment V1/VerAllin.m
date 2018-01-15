function  Offset = VerAllin(FrameV,FrameM)

   corrD = xcorr (FrameV,FrameM);
   % Verifico allineamento tra le due finestre (di uguale lunghezza)
   [VmaxD IdxD] = max(corrD);
   % Calcolo dell' Offset 
   Offset = (IdxD - length (FrameV) + 1);
   
%     % Grafico della correlazione   
%     xTime = linspace((0-length(FrameV)/44100),length (FrameV)/44100,length(corrD));
%     figure;
%     hold on;
%     plot (xTime,corrD);
%     legend('xCorr');
%     ylabel('xCorr Amplitude');
%     xlabel('Time(sec)');
%     grid on;
%     hold off;
