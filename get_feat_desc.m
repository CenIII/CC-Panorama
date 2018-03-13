function [feats, feats_locs] = get_feat_desc(im,display)

% 1. Feature extraction: harris.m 
[~,r,c]=harris(im,2,0.05,3,display);
feats_locs=[r,c];

% 2. Feature descriptor: find_sift.m 
sift_cords=[c,r,ones(length(r),1)*3];
feats = find_sift(im,sift_cords,1.5);

% return array of feats and locs
end

