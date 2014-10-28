function [ hmms ] = runesHMMInit(nEmissions, nStates, features)
% Initializing discrete-valued HMMs

numHMM = length(features);
numHMM = 1 % just for debugging
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

    B = ones(nStates, nEmissions) / nEmissions;
    for s=1:nStates
        B(s,:)
        pD(s) = DiscreteD(B(s,:));
    end

    pD

    lData
    hmms(i) = MakeLeftRightHMM(nStates, pD, obsData, lData)
end

end

