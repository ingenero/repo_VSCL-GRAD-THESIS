function [] = post_plottraffic(pre,light,terrain,opt,axis_handle,i_traffic)
% POST_PLOTTRAFFIC()
% 
% This function adds the traffic behavior to the plot of the output
% 
%=========================================================================
% ------------------------------- INPUTS ---------------------------------
%   pre = structure which contains information about the preceding vehicle
%         calculated at each node for comparison with the egv
%     ~.v = [km/h] vector with the velocity at each node
%     ~.t = [s] vector containing the time it takes the preceding vehicle 
%           to travel between the previous and current node
%     ~.firsnode = index where the preceding vehicle is first defined
% 
%   light = structure with information about the timing and positions of
%           the traffic light
%   ~.signal = [s] cell with vectors specifying each traffic light timing
% 
%   terrain = structure containing information about the terrain
%     ~.dist = vector containing distance of path
% 
%   opt = structure which contains vectors representing the solution to
%         the optimal solution from a given initial condition
%     ~.t_cum = cumulative time taken to reach current node
% 
%   axis_handle = cell with the handles of all subplots created
% 
%   i_traffic   = index of the subplot which contains the time data
%     ~(1) = index of velocity plot hande
%     ~(2) = index of time plot hande
% ------------------------------------------------------------------------
%
% ------------------------------ OUTPUTS ---------------------------------
%   Figure 1 (already exists)
% ------------------------------------------------------------------------
%=========================================================================

figure(1);
%--VELOCITY PLOT
if ~(i_traffic==0)
    %choose subplot to add traffic data to
    ax_v = axis_handle{i_traffic(1)};
    axes(ax_v); hold(ax_v,'on');
    
    if strcmp(pre.exist,'y')
        %plot preceding vehicle velocity distribution
        plot(terrain.dist,pre.v,'r','LineWidth',2)
        %create legend
        legend('EGV','Pre Veh.','Location','SE')
    end
end

%--TIME PLOT
if length(i_traffic)==2
    %choose subplot to add traffic data to
    ax_t = axis_handle{i_traffic(2)};
    axes(ax_t); hold(ax_t,'on');
    ylimits = get(ax_t,'ylim');
    
    if strcmp(pre.exist,'y')
        %find intersections
        x1 = terrain.dist;
        y1 = opt.t_cum;
        x2 = terrain.dist;
        y2 = pre.t_cum;
        [x0,y0] = intersections(x1,y1,x2,y2,1);
        %get rid of intersection at the beginning
        if x0(1)==0
            x0(1) = []; y0(1) = [];
        end

        %plot preceding vehicle with intersections
        h_pre = plot(terrain.dist,pre.t_cum,'r','LineWidth',2); %#ok
        h_coll = plot(x0,y0,'ok');
    end
    
    if strcmp(light.exist,'y')
        %plot stop lights
        for i=1:length(light.signal)
            for ii=1:2:length(light.signal{i})
                line([light.pos(i) light.pos(i)],...
                    [light.signal{i}(ii) light.signal{i}(ii+1)],...
                    'Color','k','LineStyle','-','LineWidth',3)
            end
        end

        %create legend
        if ~exist('h_pre','var')
            legend('EGV','Light Timing','Location','SE')
        elseif logical(h_coll)
            legend('EGV','Pre Veh.','Collisions','Light Timing',...
                'Location','SE')
        else
            legend('EGV','Pre Veh.','Light Timing',...
                'Location','SE')
        end

        %restore y-limits
        set(ax_t,'ylim',ylimits)
    end
end
