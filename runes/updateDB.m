function rawDB = updateDB(rawDB, symbol, times)

% Initialization, if it hasn't been done before
if (isKey(rawDB, symbol) == 0)
    rawDB(symbol) = {};
end

rdbs = rawDB(symbol);

for i=1:times
    i
    raw = DrawCharacter();

    N = length(rdbs);
    rdbs(N+1) = {raw};
end

rawDB(symbol) = rdbs;