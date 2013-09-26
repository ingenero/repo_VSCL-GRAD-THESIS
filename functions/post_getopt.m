function opt = post_getopt(opt,tbl,vect,egv,param,ns)
% opt = POST_GETOPT(opt,tbl,vect,egv,param,ns)
%
% This function populates the optimal vectors
%
%=========================================================================
% ------------------------------- INPUTS ---------------------------------
%   opt   = structure which contains vectors representing the solution to
%           the optimal solution from a given initial condition
% 
%   tbl   = structure which contains tables used to store the states
%           calculated during the DP algorithm
% 
%   vect  = structure which constians vectors of all possible values of a 
%           given parameter
% 
%   egv = structure which contains user input information about the
%         constraints on the EGV
% 
%   param = structure which contains efficiencies, physical measurements,
%           limits of the EGV, and conversion factors
% 
%   ns  = structure which contains lengths of important vectors
% ------------------------------------------------------------------------
%
% ------------------------------ OUTPUTS ---------------------------------
%   opt   = structure which contains vectors representing the solution to
%           the optimal solution from a given initial condition
%     ~.v   = optimal velocity
%     ~.T   = optimal torque distribution
%     ~.P   = optimal power consumption
%     ~.E   = optimal energy useage
%     ~.SOC = optimal state of charge of the battery
%     ~.t   = optimal time taken betweens states
% ------------------------------------------------------------------------
%=========================================================================

i_start = ns.k+1;
E_tot = zeros(ns.N,1);
%set boundary conditions
opt.v(1)            = egv.v.v0;
opt.t(1)            = 0;
opt.T.front(ns.N+1) = 0;
opt.T.rear(ns.N+1)  = 0;

%find location of total minimum energies
for k=i_start:ns.N
    if k==i_start
        %find first index
        [E_tot(k,1),ind_opt] = min(tbl.E(:,k));
    else
        E_tot(k,1) = tbl.E(ind_opt,k);
    end
    %populate optimal vectors based off index
    opt.v(k+1,1)       = tbl.v(ind_opt,k);
    opt.t(k+1,1)       = tbl.t(ind_opt,k);
    opt.T.front(k+1,1) = tbl.T.front(ind_opt,k);
    opt.T.rear(k+1,1)  = tbl.T.rear(ind_opt,k);
    %find next index
    ind_opt = find(opt.v(k+1) == vect.v);
end

%calculate energy at each stage
for k=i_start:ns.N
    if k==ns.N
        opt.E(k,1) = E_tot(k)-param.E_final;
    else
        opt.E(k,1) = E_tot(k)-E_tot(k+1);
    end
end

%calculate the state of charge vector
for k=i_start:ns.N+1
    if k==i_start
        opt.SOC(k,1) = param.lim.SOE.ini;
    else
        opt.SOC(k,1) = opt.SOC(k-1,1) - opt.E(k-1,1)/...
            (param.E_max*param.V_bat*param.conv.h2s);
    end
end
