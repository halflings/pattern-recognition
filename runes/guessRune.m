function [ symbolNum ] = guessRune(hmms)
    symbolNum = -1;
    rawData = DrawCharacterWithParticles(100);
    % If something was drawn
    if (sum(rawData(3,:) == 1) ~= 0)
        extractedFeatures = featureExtractor(rawData);
        probs = logprob(hmms, extractedFeatures)
        [~, symbolNum] = max(probs, [], 2);
    end


    %k = {'aam', 'morte', 'tera', 'vita', 'yok'};
    %cell2mat(k(symbolNum))
end