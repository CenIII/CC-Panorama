function [ T_out ] = get_T_for_all(Ts, row, rlt, Matt)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
n = sum(rlt(row,:));
if(n==0)
    T_out = Ts;
    return;
end

idx_1 = find(rlt(row,:)==1);

for k=1:n
    rlt_tmp = rlt;
    rlt_tmp(row,idx_1(k))=0;
    rlt_tmp(idx_1(k),row)=0;
    Ts{idx_1(k)} = Ts{row}*(Matt{idx_1(k),row}.T); % TODO: order?
    Ts = get_T_for_all(Ts, idx_1(k), rlt_tmp, Matt);
end

T_out = Ts;

end

