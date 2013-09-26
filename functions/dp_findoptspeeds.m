function [matr,tbl] = dp_findoptspeeds(...
    egv,pre,light,slope,state,statevect,vect,matr,tbl,constraint,param,ns)
% [matr,tbl] = DP_FINDOPTSPEEDS(egv,pre,slope,state,statevect,vect,matr,tbl,param,ns)
% 
% This function loops through all the possible combinations of curent and
% next speeds and calculates the optimal path for the current step.
% 
%=========================================================================
% ------------------------------- INPUTS ---------------------------------
%   egv = structure which contains user input information about the
%         constraints on the EGV
% 
%   pre = structure which contains information about the preceding vehicle
%         calculated at each node for comparison with the egv
% 
%   light = structure with information about the timing and positions of
%           the traffic light
% 
%   slope = structure which contains information about the slope
% 
%   state = structure which contains the possible states at the current
%           iteration
% 
%   statevect = structure which contains minimum of state calculated at
%               each new speed
% 
%   vect  = structure which constians vectors of all possible values of a 
%           given parameter
% 
%   matr  = structure which contains matrices used to store energy values
%           calculated during each iteration of the DP algorithm
% 
%   tbl   = structure which contains tables used to store the states
%           calculated during the DP algorithm
% 
%   param = structure which contains efficiencies, physical measurements,
%           limits of the EGV, and conversion factors
% 
%   ns  = structure which contains lengths of important vectors
% ------------------------------------------------------------------------
%
% ------------------------------ OUTPUTS ---------------------------------
%   matr  = structure which contains matrices used to store energy values
%           calculated during each iteration of the DP algorithm
%
%   tbl   = structure which contains tables used to store the states
%           calculated during the DP algorithm
% ------------------------------------------------------------------------
%=========================================================================

%extract useful quantities
v2struct(ns); %important lengths
v2struct(param.conv); %conversion factors

%--LOOP THROUGH ALL CURRENT SPEEDS--%
for IndexCurrSpd = 1:NumOfSpds
    ns.currspd = IndexCurrSpd;
    %set the current speed (convert to m/s)
    if k==1
        state.v.curr = egv.v.v0*kmh2mps;
    else
        state.v.curr = vect.v(IndexCurrSpd)*kmh2mps;
    end
    %set the state vectors to all nans
    statevect = resetstruct(statevect,'nan');
    
    %--LOOPS THROUGH ALL NEXT SPEEDS--%
    for IndexNextSpd = 1:NumOfSpds
        ns.nextspd = IndexNextSpd;
        %SET THE NEXT SPEED
        switch egv.v.vN
            case 'free'
                state.v.next = vect.v(IndexNextSpd)*kmh2mps;
            otherwise
                if k==ns.N
                    state.v.next = egv.v.vN*kmh2mps;
                else
                    state.v.next = vect.v(IndexNextSpd)*kmh2mps;
                end
        end
        
        %DEFINE NEW STATE PARAMETERS
        %average speed between current and next speeds - used to
        %calculate the power consumption
        state.v.avg = (state.v.curr+state.v.next)/2;
        %time elapsed when travelling between current and next nodes
        state.dt    =  egv.x.step/state.v.avg;
        %acceleration from the current to next speed
        state.a     = (state.v.next-state.v.curr)/state.dt;
        
        %TRAFFIC CONSTRAINT
        %exclude value if egv travels faster than the preceding vehicle
        if strcmp(pre.exist,'y') && pre.t(k)>state.dt
            continue
        end
        %exclude value if outside traffic light constraints
        
        
        %FIND THE STATE WITH THE MINIMUM ENERGY
        [statevect,constraint] = ...
            dp_getenergymin(statevect,state,tbl,matr,vect,constraint,slope,param,ns);
    end %--END LOOP OF ALL NEXT SPEEDS--%
    
    %populate the tables
    [tbl,matr,ns] = dp_maketbl(statevect,vect,matr,tbl,egv,param,ns);
    
end %--END LOOP OF ALL CURRENT SPEEDS--%
