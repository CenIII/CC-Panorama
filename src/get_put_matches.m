function [cord1, cord2] = get_put_matches(img1, img2, feats1, feats_loc1, feats2, feats_loc2, disp)

% 3. Disctance computing: dist2.m 
distM=dist2(feats1,feats2);
[m,n]=size(distM);

% 4. Putative matching
% hori
for i = 1:m
    tmp = distM(i,:);
    [first_min,ind1] = min(tmp);
    [second_min,~] = min(tmp(tmp~=min(tmp)));
    if(first_min<second_min*0.8) %invalid matching
        distM(i,:) = 10000;
        distM(i,ind1) = first_min;
    else
        distM(i,:) = 10000;
    end
        
end
% verti
for j = 1:n
    tmp = distM(:,j);
    [first_min,ind1] = min(tmp);
    [second_min,~] = min(tmp(tmp~=min(tmp)));
    if(first_min<second_min*0.8) %invalid matching
        distM(:,j) = 10000;
        distM(ind1,j) = first_min;
    else
        distM(:,j) = 10000;
    end
    
end
% cord converting. threshold or constant number.
[ft_ind1, ft_ind2] = find(distM~=10000);
cord1 = flip(feats_loc1(ft_ind1,:),2);
cord2 = flip(feats_loc2(ft_ind2,:),2);

if disp     
    % display here
    % cat two images horizontally
    img_cat = horzcat(img1,img2);
    % cat coordinates for display
    cord1_c = cord1;
    cord2_c = [cord2(:,1)+size(img1,2),cord2(:,2)];
    cord_c = vertcat(cord1_c,cord2_c);
    % plot images and arrows
    drawArrow = @(x,y) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0 ,'color','b');
    figure, imagesc(img_cat), axis image, colormap(gray), hold on
    plot(cord_c(:,1),cord_c(:,2),'ys'), title('putative matchings');
    for i=1:size(cord1_c,1)
        drawArrow([cord1_c(i,1),cord2_c(i,1)],[cord1_c(i,2),cord2_c(i,2)]);
    end
end

end

