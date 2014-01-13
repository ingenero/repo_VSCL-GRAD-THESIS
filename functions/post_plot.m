function [axis_handle,i_traffic] = post_plot(view,terrain,opt,param,figstart)
% POST_PLOT(view,terrain,opt,param)
% 
% This function plots the results of the DP in a way specified by the user
% via the input format.
%
%=========================================================================
% ------------------------------- INPUTS ---------------------------------
%   view = structure containing plot options
%     ~.y = list of titles to plot (via subplots)
%     ~.x = independent variable to plot results against
% 
%   terrain = structure containing information about the terrain
%     ~.dist = vector containing distance of path
%     ~.alti = vector containing altitude of path
% 
%   opt = structure which contains vectors representing the solution to
%         the optimal solution from a given initial condition
%     ~.v     = velocity of the egv
%     ~.T     = in-wheel motor torques of the egv
%     ~.SOC   = state of charge of the battery
%     ~.t_cum = cumulative time taken to reach current node
% 
%   param = structure which contains efficiencies, physical measurements,
%           limits of the EGV, and conversion factors
% ------------------------------------------------------------------------
%
% ------------------------------ OUTPUTS ---------------------------------
%   axis_handle = cell with the handles of all subplots created
% 
%   i_traffic   = index of the subplot which contains the time data
%     ~(1) = index of velocity plot hande
%     ~(2) = index of time plot hande
% ------------------------------------------------------------------------
%=========================================================================

%set default color order
set(0,'DefaultAxesColorOrder',[0 0 1;0 1 1;1 0 0])

%determine number of figures to create
input = view.results.y;
numOfInputs = length(input);
numOfFigs = str2double(input{numOfInputs}(1));

%check to make sure inputs are kosher
for i=1:numOfInputs
    switch view.results.y{i}
        case 'no_warning'
            return
        case 'none'
            disp('Post-processing complete. No data was plotted.')
            return
        otherwise
            possibleplots = {'SOC','velocity','torques','distance',...
                'time','terrain'};
            cellsize  = length(input{i});
            rawname   = input{i}(3:cellsize);
            cmparray  = strcmp(rawname,possibleplots);
            cmpresult = ismember(1,cmparray);
            if cmpresult==0
                error('Improper selection of y-axis in plots.')
            end
    end
end
switch view.results.x
    case 'time'
        xData = opt.t_cum;
        xName = 'Time (s)';
    case 'distance'
        xData = terrain.dist;
        xName = 'Distance (m)';
    otherwise
        error('Improper selection of x-axis in plots.');
end

%sort inputs into different figures
for fignum = figstart:(figstart-1)+numOfFigs
    %clear variables and create a new figure
    clear cmparray cellsize rawname; figure(fignum)
    
    %get data to plot in current figure
    cmparray = strncmp(input,num2str(fignum-figstart+1),1);
    currinput = input(cmparray);
    numofaxes = length(currinput);
    
    %plot data in subplots
    for i=1:numofaxes
        %get the name of the data to plot (without fig identifier)
        cellsize = length(currinput{i});
        rawname  = currinput{i}(3:cellsize);
        
        %create subplot space
        axis_handle{i} = subplot(numofaxes,1,i); %#ok
        
        %get the data to plot
        switch rawname
            case 'SOC'
                yData = opt.SOC;
                yName = 'SOC';
            case 'velocity'
                yData = opt.v;
                yName = 'Velocity (km/h)';
                i_traffic(1) = i;
            case 'torques'
                yData(:,1) = opt.T.front;
                yData(:,2) = opt.T.rear;
                yName = 'Torque (N-m)';
            case 'distance'
                %integrate to get position of the vehicle
                yData = cumtrapz(opt.t_cum,opt.v*param.conv.kmh2mps);
                yName = 'Position (m)';
            case 'time'
                yData = opt.t_cum;
                yName = 'Time (s)';
                i_traffic(2) = i;
            case 'terrain'
                yData = terrain.alti;
                yName = 'Altitude (m)';
            otherwise
                error('Something went wrong creating subplot.')
        end
        
        %plot data
        if strcmp(rawname,'terrain')% || strcmp(rawname,'SOC')
            bar(xData,yData,'FaceColor',[0.7 0.7 1],'EdgeColor','b')
            ylim([175 325])
            hold on
        end
        plot(xData,yData,'LineWidth',2)
        ylabel(yName); xlabel(xName);
        
        datasz = size(yData);
        if datasz(2)>1
            legend('front','rear','Location','SE')
        end
    end
    linkaxes([axis_handle{1:end}],'x')
end
