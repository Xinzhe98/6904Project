function [symbol, code] = QPSK_Gen(L)
code = round(rand(1,L));
symbol = zeros(L/2,2);
for i = 1:L/2
    I = 2*(xor(code(2*i-1),1) - 1/2);
    Q = 2*(xor(code(2*i),1) - 1/2);
    symbol(i,:) = [I,Q];
end
end