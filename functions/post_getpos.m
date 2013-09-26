function varargout = post_getpos(opt,pre,ns)
% [egv_t_cum,pre_t_cum] = POST_GETPOS(opt,pre,ns)
%
% This function returns vectors with the time the EGV and preceding
% vehicles reach each node (with respect to the starting point).

egv_t_cum = zeros(ns.N+1,1);
for i=1:ns.N+1
    egv_t_cum(i) = sum(opt.t(1:i));
end
varargout{1} = egv_t_cum;

if strcmp(pre.exist,'y')
    pre_t_cum = zeros(ns.N+1,1);
    pre_t_cum(pre.firstnode:end) = cumsum(pre.t(pre.firstnode:end));
    varargout{2} = pre_t_cum;
end