X = DrawCharacter;

ind1 = 0;
ind2 = 0;
for i=1:length(X),
    if X(3,i) == 1,
        ind1 = i;
        break;
    end
end

for i = sort(1:length(X), 'descend'),
    if X(3,i) == 1,
        ind2 = i+1;
        break;
    end
end

ind2 = ind2 - ind1;

P = X(1:3,ind1:length(X));
P = P(1:3,1:ind2);
xDeltaM = [];
for i = 1:length(P)-1,
    xDeltaM(i) = (P(1,i+1) - P(1,i));
end
norm = max(abs(xDeltaM));
xDeltaM = xDeltaM/norm;
yDeltaM = [];
for i = 1:length(P)-1,
    yDeltaM(i) = (P(2,i+1) - P(2,i));
end
norm = max(abs(yDeltaM));
yDeltaM = yDeltaM/norm;
plot(1:length(P)-1, [xDeltaM; yDeltaM]);
axis([1 length(P)-1 -1 1]);
