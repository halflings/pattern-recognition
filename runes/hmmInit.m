function [hmms] = hmmInit(nfeatures)
% Initializing discrete-valued HMMs

for i=1:5
    mc = MarkovChain([], [0.9 0.1 0; 0 0.9 0.1]);

    pD(1) = DiscreteD([0.1 0.2 0.6]);
    pD(2) = DiscreteD([0.6 0.3 0.1]);
   
    hmms(i) = HMM(mc, pD);
end

end