function res = PhaseShiftReceiver(sig,Nelm,deg,fs,D,c)
%Delay-and-Sum beamforming receiver
    sig_size = size(sig);
    res = zeros(length(deg),sig_size(1),sig_size(3));
    for i = 1:length(deg)
        deltat = D*sin(deg(i))/c;
        deltan = round(deltat*fs);
        for j = 1:sig_size(1)
            for r = 1:Nelm
                res(i,j,:) = res(i,j,:) + circshift(sig(j,r,:),-(r-1)*deltan);
            end
        end
    end
end
