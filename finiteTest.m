qFin = [1;0];
AFin = [0.7 0.25 0.05; 0.5 0.4 0.1];
b1Fin = GaussD('Mean',0,'StDev',1);
b2Fin = GaussD('Mean',3,'StDev',2);
BFin = [b1Fin;b2Fin];
mcFin = MarkovChain(qFin, AFin);
hFin = HMM(mcFin, BFin);
