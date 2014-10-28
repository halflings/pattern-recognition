function [ confusionMatrix ] = testClassification(hmms, features, trainingRatio)


r_keys = keys(features);
confusionMatrix = zeros(length(features), length(features));
for k_i=1:length(features)
    key = cell2mat(r_keys(k_i))
    observations = features(key);
    numTraining = floor(length(observations) * trainingRatio); % NOT USED YET
    for obs_i=numTraining+1:length(observations)
        data = cell2mat(observations(obs_i));
        probs = logprob(hmms, data);
        [~, argmax_prob] = max(probs, [], 2);
        confusionMatrix(k_i, argmax_prob) = confusionMatrix(k_i, argmax_prob) + 1;
    end
    confusionMatrix(k_i, :) = confusionMatrix(k_i, :)  / sum(confusionMatrix(k_i, :));
end


end

