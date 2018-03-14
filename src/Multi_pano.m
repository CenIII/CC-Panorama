% 1. get inliers matrix, make it symmetric.
display = 0;
num_im = 12;
% 0. Load images
fprintf('- Load images and extract features...\n');
im = cell(0);
img = cell(0);
feats = cell(0);
feats_locs = cell(0);
for i=1:num_im
    imageName = strcat(num2str(i),'.jpg');
    dataDir = fullfile('..','data/yellowstone4');
    im{i} = imread(fullfile(dataDir, imageName));
    img{i} = im2double(rgb2gray(im{i}));
    % 1. Feature extraction: harris.m
    % 2. Feature descriptor: find_sift.m
    [feats{i}, feats_locs{i}] = get_feat_desc(img{i},display);
end
fprintf('- Get inlier matrix...\n');
Matt = cell(num_im);
inls_mat = zeros(num_im,num_im);
for i=1:num_im
    for j=i+1:num_im
    % 4. Putative matching
    [cord1, cord2] = get_put_matches(img{i}, img{j}, feats{i}, feats_locs{i}, feats{j}, feats_locs{j},display);
    % 5. RANSAC
    [T, num_inls, avg_res] = get_transform(img{i}, img{j}, cord1, cord2, display);

    s.cord1 = cord1;
    s.cord2 = cord2;
    s.T = T;
    s.num_inls = num_inls;
    s.avg_res = avg_res;
    Matt{i,j} = s;
    s.T = inv(T);
    Matt{j,i} = s;

    inls_mat(i,j) = num_inls;
    inls_mat(j,i) = num_inls;
    end
end
% eliminate odds.
max_arr = max(inls_mat);
preserve_arr=[];
for i = 1:num_im
   if(max_arr(i) > mean(max_arr(max_arr~=max_arr(i)))/4)
       preserve_arr = [preserve_arr, i];
   end
end
im = im(preserve_arr);
num_im = length(preserve_arr);
Matt = Matt(:,preserve_arr);
Matt = Matt(preserve_arr,:);
inls_mat = inls_mat(:,preserve_arr);
inls_mat = inls_mat(preserve_arr,:);


% what we have now: Matt, inls_mat.
% 2. generate relation tree.
fprintf('- Select central image...\n');
% initialization
Relat = zeros(num_im,num_im);
inls_tmp = inls_mat;
[a,b] = find(inls_tmp==max(max(inls_tmp)));
inpool_idx = [a(1),b(1)];
inls_tmp(:,inpool_idx)=-1;
Relat(sub2ind(size(Relat),a,b)) = 1;
for i=3:num_im
    pool_mat = inls_tmp(inpool_idx,:);
    [a,b] = find(pool_mat==max(max(pool_mat)));
    max_idx = [inpool_idx(a(1)),b(1)];
    inpool_idx = [inpool_idx, b(1)];
    inls_tmp(:,b(1))=-1;
    Relat(max_idx(1),max_idx(2))=1;
    Relat(max_idx(2),max_idx(1))=1;
end

% 3. find central
    % a nxv matrix saving the number of pics at each branch
vn = max(sum(Relat,2));
branch_mat = zeros(num_im,vn);

rlt = Relat;
for i=1:num_im
   n = sum(rlt(i,:));
   idx_1 = find(rlt(i,:)==1);
   for j = 1:n
       branch_mat(i,j) = 1 + num_on_this_branch(rlt, i, idx_1(j));
   end
end
    % find central by calculating the variance.
br_mat_var = var(branch_mat,0,2);
[~, cent_num] = min(br_mat_var);
% 4. compute T's
fprintf('- Determine transform matrices for all...\n');
Ts = cell(0);
Ts{cent_num} = eye(3);
Ts = get_T_for_all(Ts, cent_num, Relat, Matt);

% 5. stitch. verify and abandon.
fprintf('- Stitching...\n');
im_out = get_stitchM(im, Ts, cent_num,1);
