function [ hmms ] = runesHMMInit(features, nStates, trainingRatio)
% Initializing discrete-valued HMMs

numHMM = length(features);
symbols = keys(features);
for h=1:numHMM
    key = cell2mat(symbols(h));
    fdb = features(key);

    obsData = [];
    numObs = length(fdb);
    numTrainingObs = floor(numObs * trainingRatio);
    lData = zeros(1, numTrainingObs);
    for obs_i=1:numTrainingObs
        observations = cell2mat(fdb(obs_i));
        lData(obs_i) = size(observations, 2);
        obsData = [obsData observations];
    end

    for s=1:nStates
        pD(s) = GaussD('Mean',[0.5 0.5],'StDev',[0.01 0.01]);
    end

    trainedHMM = MakeLeftRightHMM(nStates, pD, obsData, lData)
    hmms(h) = trainedHMM;
end

end

