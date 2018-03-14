function [ panorama ] = get_stitchM(im, Ts, cent_num, display)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
xLimits=[1,1];
yLimits=[1,1];
for i=1:length(im)
    if(i==cent_num)
        continue;
    end
    tform = projective2d(Ts{i});
    [xlim, ylim] = outputLimits(tform, [1 size(im{i},2)], [1 size(im{i},1)]);
    xLimits = [min([xLimits(1); xlim(:)]), max([size(im{i},2);xLimits(2); xlim(:)])];
    yLimits = [min([yLimits(1); ylim(:)]), max([size(im{i},1);yLimits(2); ylim(:)])];
end

canv_size = [round(yLimits(2) - yLimits(1)), round(xLimits(2) - xLimits(1))];

panoramaView = imref2d(canv_size, xLimits, yLimits);

result = cell(0);
panorama = imwarp(im{cent_num},affine2d(eye(3)),'OutputView', panoramaView);

for i=1:length(im)
    if(i==cent_num)
        continue;
    end
    % todo: check validation.
    result{i} = imwarp(im{i},projective2d(Ts{i}),'OutputView', panoramaView);
    overlap = (panorama > 0.0) & (result{i} > 0.0);  
%     error = sum((panorama(overlap)-result{i}(overlap)).^2)/length(overlap(:))
%     if(error>20)
%         continue;
%     end
    result_avg = result{i};
    panorama = panorama + result{i};
    panorama(overlap) = result_avg(overlap);
end

if display
    warning('off', 'Images:initSize:adjustingMag');
    figure
    imshow(panorama)
end

end

