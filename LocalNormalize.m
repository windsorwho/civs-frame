function [cosinPart sinePart]=LocalNormalize(cosinPart,sinePart,h,halfSizex,halfSizey,thresholdFactor)
% function to mimic the mexc_localNormalize by Zhangzhang Si.
% suppose for the input image, pixels within h pixels distance from the
% boundar are all 0.
% h is the half of filter size
% sine and cosine parts are actually aboslute value of <I,B>

% if(isempty(sinePart))
%     disp('sinPart is empty, will continue')
% end

sx = size(cosinPart{1},1);
sy = size(cosinPart{1},2);

% compute sum of sum1 over all orientations
S1All = zeros([sx,sy]);
if isempty(sinePart)
    for iOri = 1:length(cosinPart)
        S1All = S1All + cosinPart{iOri}.^2;
    end
else
    for iOri = 1:length(cosinPart)
        S1All =S1All+  0.5.*(cosinPart{iOri}.^2+sinePart{iOri}.^2);
    end
end
S1All = S1All/length(cosinPart);


%integralImage
intS1 = integralImage(S1All);  % for matlab 2013


%local average
meanMap = zeros(sx,sy);
for x = h+1+halfSizex: sx-h-halfSizex
    for y = h+1+halfSizey : sy-h-halfSizey
        
        % [sR sC eR eC] = deal(x-halfSizex, y-halfSizey, x+halfSizex, y+halfSizey);
        % meanMap(x,y) = intS1(eR+1,eC+1) - intS1(eR+1,sC) - intS1(sR,eC+1) + intS1(sR,sC);
        
        meanMap(x,y) = intS1(x+halfSizex+1,y+halfSizey+1) + intS1(x-halfSizex,y-halfSizey)...
                  -intS1(x-halfSizex,y+halfSizey+1) - intS1(x+halfSizex+1,y-halfSizey);
              
    end
end
meanMap = meanMap/(2*halfSizex+1)/(2*halfSizey+1);
meanMap = sqrt(meanMap);


% propagate local average to boundary
meanMap = meanMap(h+1+halfSizex:sx-h-halfSizex,h+1+halfSizey:sy-h-halfSizey);
meanMap = padarray(meanMap,[h+halfSizex,h+halfSizey],'replicate','both');


% perform normalization
maxAverage = max(meanMap(:));
meanMap = max(meanMap,maxAverage*thresholdFactor);
invMeanMap = 1./meanMap;

if isempty(sinePart)
    for iOri = 1:length(cosinPart)
        cosinPart{iOri}=cosinPart{iOri}.*invMeanMap;
    end
else
    for iOri = 1:length(sinePart)
       sinePart{iOri} = sinePart{iOri}.*invMeanMap;
       cosinPart{iOri} =cosinPart{iOri}.*invMeanMap;
    end
end
