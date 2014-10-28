TRAINING_FACTOR = 0.5;
NUM_STATES = 5;

features = generateFeatures(raw);
hmms = runesHMMInit(features, NUM_STATES, TRAINING_FACTOR);
confusionMatrix = testClassification(hmms, features, TRAINING_FACTOR)
imshow(confusionMatrix, 'InitialMagnification', 10000)
colormap('autumn')