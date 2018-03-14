function [ num_childs ] = num_on_this_branch(rlt, i, j)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
rlt(i,j)=0;
rlt(j,i)=0;

n = sum(rlt(j,:));
if(n==0)
    num_childs=0;
    return;
end

idx_1 = find(rlt(j,:)==1);
tmp=0;
for k=1:n
   tmp = tmp + num_on_this_branch(rlt, j, idx_1(k));
end

num_childs = tmp + n;

end

