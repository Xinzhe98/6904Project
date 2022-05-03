%%
% Parameter definition
f = 1e9;  % Carrier frequency
c = physconst('LightSpeed');
D = c/(2*f);  % Distance between adjacent array element is half of wavelength
M = 100;  % Sampling magnification
fs = M*f;  % Sampling frequency
t = 0:1/fs:1e-8 - 1/fs;  % Each symbol is sent in 1e-8 seconds
N = length(t);
w = -1:2/N:1-2/N;  % Normalized frequency
SNR = 3;  % AWGN SNR
Nelm = 8;  % ULA attenna number
Lc = 100;  % The length of binary code, twice of symbol number in QPSK
deg = -45:1:45;
degt = (pi/180)*deg;  % Transmitter beamforming angle
degr = (pi/180)*deg;  % Receiver beamforming angle
%%
% Design of FIR filter
Nf   = 200;       % FIR filter order
Fp  = 1e8;        % 20 kHz passband-edge frequency
Fs  = fs;         % 96 kHz sampling frequency
Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-4;  
LPF = firceqrip(Nf,Fp/(Fs/2),[Rp Rst],'passedge'); % eqnum = vec of coeffs
% fvtool(eqnum,'Fs',Fs,'Color','White') % Visualize filter
%%
% Generate symbols from random data
[symbols, code] = QPSK_Gen(Lc);
Demod = zeros(length(degt),length(degr),Lc); % Define the demodulated symbols
%%
% Modulation, delay and sum, transmission, recoveing, demodulation and visualization
figure;
for iter = 1:length(symbols)  % Iteration for each symbol
    sig = symbols(iter,1)*cos(2*pi*f*t) - symbols(iter,2)*sin(2*pi*f*t);
    ps = sum(sig.^2)/length(sig);  % Signal power
    pn = ps*10^(-SNR/10);     % AWGN power
    
    sig_trans = zeros(Nelm,length(sig)); % Define singal from each transmitter
    for i = 1:Nelm
        sig_trans(i,:) = sig;
    end
    sig_trans = PhaseShiftTransmitter(sig_trans,Nelm,degt,fs,D,c); % Beamfoming for transmitter
    
    sig_ch = zeros(length(deg),Nelm,length(sig)); % Define singals in channel
    for i = 1:length(degt)
        sig_temp = squeeze(sig_trans(i,:,:));
        for j = 1:Nelm
            sig_temp(j,:) = sig_temp(j,:) + sqrt(pn)*randn(size(sig)); % Add AWGN
        end
        sig_ch(i,:,:) = sig_temp;
    end
    
    [posTx,posRx,dis_Tx_Rx] = TxRxPos(c/f,Nelm,Nelm,0,0,100); % Calculate relative distance
    deltan_ch = zeros(length(Nelm));
    for i = 1:Nelm
        deltat_ch = dis_Tx_Rx(i,i)/c;          % Calculate the phase difference for each path
        deltan_ch(i) = round(deltat_ch*fs);    % Convert the phase difference to point number difference
    end

    sig_arv = zeros(length(deg),Nelm,length(sig)); % Define arriving signals
    for i = 1:length(degt)
        sig_temp = squeeze(sig_ch(i,:,:));
        for j = 1:Nelm
            sig_temp(j,:) = circshift(sig_temp(j,:),deltan_ch(j)); % Express phase difference with cyclic shift
        end
        sig_arv(i,:,:) = sig_temp;
    end
    
    sig_rec = PhaseShiftReceiver(sig_arv,Nelm,degr,fs,D,c); % Beamfoming for receiver
    
    Ic = circshift(cos(2*pi*f*t),deltan_ch(1));
    Qc = circshift(sin(2*pi*f*t),deltan_ch(1));
    for i = 1:length(degt) % Demodulation
        for j = 1:length(degr)
            sig_temp = squeeze(sig_rec(i,j,:))';
            AI = sig_temp .* Ic;
            AI = conv(AI,LPF) * 2;
            AI = AI(Nf/2:end - Nf/2)/Nelm;
            AQ = sig_temp .* Qc;
            AQ = conv(AQ,LPF) * -2;
            AQ = AQ(Nf/2:end - Nf/2)/Nelm;
            
            if AI > 0
                Demod(i,j,2*iter-1) = 0;
            else
                Demod(i,j,2*iter-1) = 1;
            end
            if AQ > 0
                Demod(i,j,2*iter) = 0;
            else
                Demod(i,j,2*iter) = 1;
            end

            if i == 46 && j == 46
                scatter(mean(AI),mean(AQ));
                hold on
            end

        end
    end
end
BER = BERcal(Demod,code);
% heatmap(deg,deg,BER)
