function [T, num_inls, avg_res] = get_transform(img1, img2, cord1, cord2, display)
    N = 40000;
    avg_res = 0;
    num_inls = 0;
    num=size(cord1,1);
    A = zeros(8,9);
    thrzero = [0 0 0];
    for i = 1:N
        if(num<4)
            num_inls=0;
            T = eye(3,3);
            avg_res=0;
            return;
        end
        index = randperm(num,4);
        xy = cord1(index,:);
        xy_t = cord2(index,:);
        for k = 1:4
            A((2*k-1):2*k,:) = [thrzero,xy(k,:),1,-xy_t(k,2)*[xy(k,:),1];
                                xy(k,:),1,thrzero,-xy_t(k,1)*[xy(k,:),1]];
        end
        [~,~,V] = svd(A);
        H = reshape(V(:,end),3,3);

        cord1_trans=[cord1,ones(size(cord1,1),1)]*H;
        cord1_trans=bsxfun(@rdivide, cord1_trans, cord1_trans(:,3));
        cord2_target=[cord2,ones(size(cord2,1),1)];
        dists = sqrt(sum((cord2_target-cord1_trans).^2,2));

        ind_b = find(dists<1);
        num_in = length(ind_b);
        
        if num_inls < num_in
            T = H;
            num_inls = num_in;
            ind_inls = ind_b;
            avg_res = mean(dists(ind_b));
        end
    end
    
    if display
        cord1_inls = cord1(ind_inls,:);
        cord2_inls = cord2(ind_inls,:);
        % cat two images horizontally
        img_cat = horzcat(img1,img2);
        % cat coordinates for display
        cord1_c = cord1_inls;
        cord2_c = [cord2_inls(:,1)+size(img1,2),cord2_inls(:,2)];
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

