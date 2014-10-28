function featureSet = featureExtractor(charData, resolution)

Xred = [];
% Remove cols where third row has 0
% Currently BUGGY for some reason
for i = 1:length(charData),
    if charData(3,i) == 1,
    Xred(:,length(Xred)+1) = charData(1:3,i);
    end
end
Xred = [Xred(1:3,1) Xred(1:3, 4:length(Xred))];

% Normalise position to O = (0.5, 0.5)
averageX = sum(Xred(1,:)) / length(Xred);
averageY = sum(Xred(2,:)) / length(Xred);
dX = 0.5 - averageX;
dY = 0.5 - averageY;
Xred(1,:) = Xred(1,:) + dX;
Xred(2,:) = Xred(2,:) + dY;
xDeltaM = Xred(1,:);
yDeltaM = Xred(2,:);
%
minst = min([xDeltaM yDeltaM]);
xDeltaM = xDeltaM - minst;
%minst = min(yDeltaM);
yDeltaM = yDeltaM - minst;
norm = max(abs([xDeltaM yDeltaM]));
xDeltaM = xDeltaM/norm;
yDeltaM = yDeltaM/norm;
featureSet = [xDeltaM; yDeltaM]';
featureSet = sortrows(featureSet)';


featureSet = round(featureSet*resolution);

%plot(1:length(featureSet), featureSet);
%axis([0 length(featureSet) 0 resolution]);
