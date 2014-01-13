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

%CHECK TO SEE IF THE EGV GETS STUCK AT THE NEXT LIGHT
if k==i_start
    opt = post_getopt(opt,tbl,vect,egv,param,ns);
    v_avg = mean(opt.v(i_start:i_end));
    
    for i=1:length(light.vs{iL})
        v_vect = light.vs{iL}{i};
        for ii=1:length(v_vect)-1
            if ii==1
                spd_hi = egv.v.max+1;
                spd_lo = v_vect(ii);
            elseif rem(ii,2)==0
                spd_hi = v_vect(ii);
                spd_lo = v_vect(ii+1);
            else
                spd_hi = v_vect(ii-1);
                spd_lo = v_vect(ii);
            end

            if v_avg>spd_lo && v_avg<spd_hi
%                 disp('GREEN LIGHT!')
                return
            end
        end
    end
    
%     disp('RED LIGHT!')
    for i=1:length(light.vs{iL})
        v_vect = light.vs{iL}{i};
        for ii=1:length(v_vect)-1
            if ii==1
                spd_hi = egv.v.max+1;
                spd_lo = v_vect(ii);
            elseif rem(ii,2)==0
                spd_hi = v_vect(ii);
                spd_lo = v_vect(ii+1);
            else
                spd_hi = v_vect(ii-1);
                spd_lo = v_vect(ii);
            end

            if spd_hi<egv.v.max+1 && spd_lo>egv.v.min-1
                ns.speedLimit = [spd_hi spd_lo];
                ns.k = i_end;
                return
            elseif spd_hi<egv.v.max+1 && spd_hi>egv.v.min
                ns.speedLimit(1) = spd_hi;
                ns.k = i_end;
                return
            elseif spd_lo>egv.v.min-1 && spd_lo<egv.v.max
                ns.speedLimit(2) = spd_lo;
                ns.k = i_end;
                return
            else
                continue
            end
        end
    end
    error('Making the light is not possible.')
end






