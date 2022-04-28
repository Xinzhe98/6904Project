function res = PhaseShiftTransmitter(sig,Nelm,deg,fs,D,c)
%Delay-and-Sum beamforming transmitter
    temp = zeros(size(sig));
    res = [];
    for i = 1:length(deg)
        deltat = D*sin(deg(i))/c;
        deltan = round(deltat*fs);
        for j = 1:Nelm
            temp(j,:) = circshift(sig(j,:),-(j-1)*deltan);
        end
        res(i,:,:) = temp;
    end
end
