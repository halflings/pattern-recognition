function [ features ] = generateFeatures(raw, resolution)
features = containers.Map();
r_keys = keys(raw);

for k_i=1:size(raw)
    key = cell2mat(r_keys(k_i))

    fdbs = {};
    rdbs = raw(key);

    for i=1:length(rdbs)
        rawData = cell2mat(rdbs(i));
        extractedFeatures = featureExtractor(rawData, resolution);
        fdbs(length(fdbs)+1) = {extractedFeatures};
    end
    
    features(key) = fdbs;
end

end

