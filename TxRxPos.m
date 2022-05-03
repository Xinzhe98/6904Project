function [posTx,posRx,dis_Tx_Rx] = TxRxPos(lambda,numTx,numRx,thetaTx,thetaRx,offset_x)

posTx = zeros(numTx,2);
posRx = zeros(numRx,2);
TxstartY = (numTx/2-1)*lambda/2+lambda/4;
TxendY = -TxstartY;
RxstartY = (numRx/2-1)*lambda/2+lambda/4;
RxendY = -RxstartY;

posTx(:,2) = linspace(TxstartY,TxendY,numTx);% pos = (x,y
posRx(:,2) = linspace(RxstartY,RxendY,numRx);
beforeRotateTX = posTx;
beforeRotateRx = posRx;

for i = 1:numTx
   posTx(i,1) = beforeRotateTX(i,1)*cos(thetaTx)+beforeRotateTX(i,2)*sin(thetaTx);
   posTx(i,2) = -beforeRotateTX(i,1)*sin(thetaTx)+beforeRotateTX(i,2)*cos(thetaTx);
end
for i = 1:numRx
   posRx(i,1) = beforeRotateRx(i,1)*cos(thetaRx)+beforeRotateRx(i,2)*sin(thetaRx);
   posRx(i,2) = -beforeRotateRx(i,1)*sin(thetaRx)+ beforeRotateRx(i,2)*cos(thetaRx);
end
posRx(:,1) = posRx(:,1)+offset_x;
  
% scatter(posTx(:,1),posTx(:,2))
% hold on;
% scatter(posRx(:,1),posRx(:,2))
% axis equal;

% distance on x directionbetween each pair of Tx & Rx elements
disX_Tx_Rx = zeros(numTx,numRx);
% distance on y directionbetween each pair of Tx & Rx elements
disY_Tx_Rx = zeros(numTx,numRx);
for i = 1:numTx
   for j = 1:numRx
       disX_Tx_Rx(i,j) = abs(posRx(j,1)-posTx(i,1));
       disY_Tx_Rx(i,j) = abs(posRx(j,2)-posTx(i,2));
   end
end
% absolute distance of each pair of Tx & Rx elements
dis_Tx_Rx = sqrt(disY_Tx_Rx.^2+disX_Tx_Rx.^2);
end
