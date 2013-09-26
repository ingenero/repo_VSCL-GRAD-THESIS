function [ns] = dp_lightconstraint(light,terrain,opt,tbl,vect,egv,param,ns)
% [] = DP_LIGHTCONSTRAINT()
% 
% This function forces the egv to travel through the light when it is green
% 
%=========================================================================
% ------------------------------- INPUTS ---------------------------------
%   light = structure with information about the timing and positions of
%           the traffic light
%     ~.pos    = [m] location of the traffic light(s)
%     ~.intype = method of specifying signal timing
%     ~.signal = [s] cell with vectors specifying each traffic light timing 
% 
%   terrain = structure containing information about the terrain
%     ~.dist = vector containing distance of path
% 
%   ns  = structure which contains lengths of important vectors
%     ~.k  = current node
%     ~.N  = total number of nodes
%     ~.iL = node closest to the current ending light
% ------------------------------------------------------------------------
%
% ------------------------------ OUTPUTS ---------------------------------
%  
% ------------------------------------------------------------------------
%=========================================================================

%extract useful parameters from structures
v2struct(ns);
v2struct(param.conv);

%FIND LOCATIONS OF LIGHTS CURRENTLY AROUND THE EGV
%ending light
i_end = find(terrain.dist>=light.pos(iL),1,'first');
%starting light
if iL>1
    %if currently between two lights, choose the first one
    i_start = find(terrain.dist>=light.pos(iL-1),1,'first');
else
    %if between one light and the origin, choose the origin
    i_start = 1;
end

%CHECK TO SEE IF THE EGV GETS STUCK AT THE NEST LIGHT
if k==i_start
    opt = post_getopt(opt,tbl,vect,egv,param,ns);
    v_avg = mean(opt.v(i_start:i_end));
    
    for i=1:length(light.vs)
        for ii=1:length(light.vs{i})
            for iii=1:length(light.vs{i}{ii})-1
                if v_avg>light.vs{i}{ii}(iii) && v_avg<light.vs{i}{ii}(iii+1)
                    disp('light ok')
                    break
                end
            end
        end
    end
    
%     disp('light NOT ok')
%     ns.k = i_end;
%     ns.speedLimit = [];
end






