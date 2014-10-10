X = DrawCharacter;

Xred = [];
% Remove cols where third row has 0
% Currently BUGGY for some reason
for i = 1:length(X),
    if X(3,i) == 1,
        Xred(:,length(Xred)+1) = X(1:3,i);
    end
end
Xred = [Xred(1:3,1) Xred(1:3, 4:length(Xred))];
XCatch = Xred;

% Normalise position to O = (0.5, 0.5)
averageX = sum(Xred(1,:)) / length(Xred);
averageY = sum(Xred(2,:)) / length(Xred);

dX = 0.5 - averageX;
dY = 0.5 - averageY;

Xred(1,:) = Xred(1,:) + dX;
Xred(2,:) = Xred(2,:) + dY;

xDeltaM = Xred(1,:);
yDeltaM = Xred(2,:);

minst = min(xDeltaM);
xDeltaM = xDeltaM - minst;
norm = max(abs(xDeltaM));
xDeltaM = xDeltaM/norm;
minst = min(yDeltaM);
yDeltaM = yDeltaM - minst;
norm = max(abs(yDeltaM));
yDeltaM = yDeltaM/norm;

plot(1:length(xDeltaM), [xDeltaM;yDeltaM]);
axis([0 length(xDeltaM) 0 1]);
