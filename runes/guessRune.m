function [ symbolNum ] = guessRune(hmms)
    rawData = DrawCharacter();
    extractedFeatures = featureExtractor(rawData);
    probs = logprob(hmms, extractedFeatures);
    [~, symbolNum] = max(probs, [], 2);

    %k = {'aam', 'morte', 'tera', 'vita', 'yok'};
    %cell2mat(k(symbolNum))
end