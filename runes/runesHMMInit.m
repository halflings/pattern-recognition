function [ hmms ] = runesHMMInit(nStates, features)
% Initializing discrete-valued HMMs

numHMM = length(features);
symbols = keys(features);
for h=1:numHMM
    key = cell2mat(symbols(h));
    fdb = features(key);

    obsData = [];
    numObs = length(fdb);
    lData = zeros(1, numObs);
    for obs_i=1:numObs
        observations = cell2mat(fdb(obs_i));
        lData(obs_i) = size(observations, 2);
        obsData = [obsData observations];
    end

    for s=1:nStates
        pD(s) = GaussD('Mean',[7 7],'StDev',[2 2]);
    end

    trainedHMM = MakeLeftRightHMM(nStates, pD, obsData, lData)
    hmms(h) = trainedHMM;
end

end

