function [ hmms ] = runesHMMInit(nemissions, nstates, nhmms)
% Initializing discrete-valued HMMs

if nargin < 3
    nhmms = 5;
end

for i=1:nhmms
    p0 = ones(1, nstates) / nstates;
    A = ones(nstates, nstates + 1) / (nstates + 1);
    B = ones(nstates, nemissions) / nemissions;
    mc = MarkovChain(p0, A);
    pD = DiscreteD(B);
    
    hmms(i) = HMM(mc,pD);
end

end

