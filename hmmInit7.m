q = [0.75; 0.25];
A = [0.99 0.01; 0.03 0.97];
b1 = GaussD('Mean',[0,10],'StDev',[0.5,0.5]);
b2 = GaussD('Mean',[10,0],'StDev',[0.5,0.5]);
B = [b1;b2];
mc = MarkovChain(q,A);
h = HMM(mc, B);
