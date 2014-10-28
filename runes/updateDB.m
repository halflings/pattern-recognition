function [rawDB, featureDB] = updateDB(rawDB, featureDB, symbol, times)

RESOLUTION = 26;

% Initialization, if it hasn't been done before
if (isKey(rawDB, symbol) == 0)
    rawDB(symbol) = {};
end
if (isKey(featureDB, symbol) == 0)
    featureDB(symbol) = {};
end

rdbs = rawDB(symbol);
fdbs = featureDB(symbol);

for i=1:times
    i
    raw = DrawCharacter();
    features = featureExtractor(raw, RESOLUTION);

    N = length(rdbs);
    rdbs(N+1) = {raw};
    fdbs(N+1) = {features};
end

rawDB(symbol) = rdbs;
featureDB(symbol) = fdbs;