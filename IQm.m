%%
%FIR低通滤波器设计
N   = 100;        % FIR filter order
Fp  = 20e3;       % 20 kHz passband-edge frequency
Fs  = 96e3;       % 96 kHz sampling frequency
Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-4;  
eqnum = firceqrip(N,Fp/(Fs/2),[Rp Rst],'passedge'); % eqnum = vec of coeffs
% fvtool(eqnum,'Fs',Fs,'Color','White') % Visualize filter

%%
%IQ调制框架
%System parameters
f1 = 15e3;
t = 0:1/Fs:100*(1/f1);
SNR = -10;
I = 1;
Q = 1;
In = I * cos(2*pi*f1*t);
Qn = Q * sin(2*pi*f1*t);
Sig = In - Qn;
%AWGN
ps = sum(Sig.^2)/length(Sig);
pn = ps*10^(-SNR/10); 
Sig = Sig + sqrt(pn)*randn(size(Sig));
%IQ Demodulation
SigI = Sig .* cos(2*pi*f1*t);
SigI = conv(SigI,eqnum) * 2;
SigI = SigI(N/2:end - N/2);
SigQ = Sig .* sin(2*pi*f1*t);
SigQ = conv(SigQ,eqnum) * (-2);
SigQ = SigQ(N/2:end - N/2);
output = sum(SigI)/length(SigI) + (sum(SigQ)/length(SigQ)) * 1j;
disp(output);
% EVM
s=1;
e=0;
evm = 20*log(sqrt(e^2)/sqrt(s^2));
