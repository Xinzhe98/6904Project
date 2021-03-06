clc;clear;
f = 1e11;  %载波频率
c = physconst('LightSpeed');
D = c/(2*f); %1/2载波波长
M = 100; %采样频率倍率
fs = M*f; %采样频率
t = 0:1/fs:4e-8 - 1/fs;
N = length(t);
w = -1:2/N:1-2/N;  %归一化频率点
fam = 1e8;  %调幅波频率
SNR = 10;    %AWGN SNR
Nelm = 8;   %ULA天线单元数量
deg = -45:1:45;
degt = (pi/180)*deg;  %Transmitter beamforming angle
degr = (pi/180)*deg;  %Receiver beamforming angle
%%
sig = (1+0.5*cos(2*pi*fam*t)).*cos(2*pi*f*t);   %传输的调幅信号
plot(sig)
ps = sum(sig.^2)/length(sig);
pn = ps*10^(-SNR/10);       %AWGN功率
%%
%传输信号生成
sig_trans = zeros(Nelm,length(sig));
for i = 1:Nelm
    sig_trans(i,:) = sig;
end
sig_trans = PhaseShiftTransmitter(sig_trans,Nelm,degt,fs,D,c);
%%
%AWGN 信道噪声添加
sig_ch = [];
for i = 1:length(degt)
    sig_temp = squeeze(sig_trans(i,:,:));
    for j = 1:Nelm
        sig_temp(j,:) = sig_temp(j,:) + sqrt(pn)*randn(size(sig));
    end
    sig_ch(i,:,:) = sig_temp;
end
% plot(sig_ch(1,1,:))
% plot(sig_ch(2,1,:))
% plot(sig_ch(3,1,:))

%%
%信道传输相位差添加
figure
[posTx,posRx,dis_Tx_Rx] = TxRxPos(c/f,Nelm,Nelm,30,30,100);
deltan_ch = [];
for i = 1:Nelm
    deltat_ch = dis_Tx_Rx(i,i)/c;                   %计算不同距离对应的相位差，用deltan表示
    deltan_ch = [deltan_ch round(deltat_ch*fs)];    %deltan为采样点的位移
end
ref_sig = Nelm * circshift(sig,deltan_ch(1));
sig_arv = [];
for i = 1:length(degt)
    sig_temp = squeeze(sig_ch(i,:,:));
    for j = 1:Nelm
        sig_temp(j,:) = circshift(sig_temp(j,:),deltan_ch(j));  %相位差用循环位移表示
    end
    sig_arv(i,:,:) = sig_temp;
end
%%
%Receiver beamforming
sig_rec = PhaseShiftReceiver(sig_arv,Nelm,degr,fs,D,c);
rSNR = [];
rps = sum(ref_sig.^2)/length(ref_sig);
for i = 1:length(degt)
    for j = 1:length(degr)
        noise = squeeze(sig_rec(i,j,:)) - ref_sig';
        rpn = sum(noise.^2)/length(noise);
        rSNR(i,j) = 10*log10(rps/rpn);
    end
end
% rSNR(i,j)=int, i=Txdeg, j=Rxdeg   

% figure
% for i = 1:8
%     subplot(8,1,i)
%     plot(t,squeeze(sig_ch(1,i,:)));
% end
% 
% %

% for i = 1:length(degt)
%     figure
%     for j = 1:length(degr)
%         subplot(length(degr),1,j)
%         plot(t,squeeze(sig_rec(i,j,:)))
%         title(['Reconstructed Signal Trans theta = ',num2str(degt(i)*180/pi),'Receive theta = ',num2str(degr(j)*180/pi)]);
%         subtitle(['SNR = ',num2str(rSNR(i,j))]);
%     end
% end
figure
heatmap(deg,deg,rSNR,XLabel='Tx beamforming angle',YLabel='Rx beamforming angle')



