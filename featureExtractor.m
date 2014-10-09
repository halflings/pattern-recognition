X = DrawCharacter;

Xred = [];
for i = 1:length(X),
    if X(3,i) == 1,
        Xred(:,length(Xred)+1) = X(1:2,i);
    end
end

averageX = sum(Xred(1,:)) / length(Xred);
averageY = sum(Xred(2,:)) / length(Xred);

dX = 0.5 - averageX;
dY = 0.5 - averageY;

Xred(1,:) = Xred(1,:) + dX;
Xred(2,:) = Xred(2,:) + dY;

xDeltaM = Xred(1,:);
yDeltaM = Xred(2,:);

averageX = sum(xDeltaM) / length(xDeltaM);
averageY = sum(yDeltaM) / length(yDeltaM);
dX = 0.5 - averageX;
dY = 0.5 - averageY;

xDeltaM = xDeltaM + dX;
yDeltaM = yDeltaM + dY;

minst = min(xDeltaM);
norm = max(abs(xDeltaM));
xDeltaM = (xDeltaM - minst)/norm;

minst = min(yDeltaM);
norm = max(abs(yDeltaM));
yDeltaM = (yDeltaM - minst)/norm;

plot(1:length(xDeltaM), [xDeltaM;yDeltaM]);
axis([0 length(xDeltaM) 0 1]);
