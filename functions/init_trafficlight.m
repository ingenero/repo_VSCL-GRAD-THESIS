function [light] = init_trafficlight(light,param)
% light = INIT_TRAFFICLIGHT()
% 
% This function interprets the traffic light info and outputs information
% to be used as constraints on the egv's trajectory
% 
%=========================================================================
% ------------------------------- INPUTS ---------------------------------
%   light = structure with information about the timing and positions of
%           the traffic light
%     ~.pos    = [m] location of the traffic light(s)
%     ~.intype = method of specifying signal timing
% ------------------------------------------------------------------------
%
% ------------------------------ OUTPUTS ---------------------------------
%   light = structure with information about the timing and positions of
%           the traffic light
%     ~.signal = [s] cell with vectors specifying each traffic light timing 
% ------------------------------------------------------------------------
%=========================================================================

%extract useful conversion factors from structure
v2struct(param.conv)

NumOfLights = length(light.pos); %find the number of lights
NumOfStates = 10; %set number of traffic signal states
pattern = [40 100 150 200 240];

%set traffic signal vector for each position according to use input
for i=1:NumOfLights
    if strcmp(light.intype{i},'auto')
        %set signal vector according to repeating red/green pattern
        signal = nan(1,NumOfLights); %pre-allocate signal vector
        signal(1) = light.green; %green light comes first
        for ii=2:NumOfStates
            if rem(ii,2)==0
                %if index is even, add red light length
                signal(ii) = signal(ii-1)+light.red;
            else
                %if index is odd, add green light length
                signal(ii) = signal(ii-1)+light.green;
            end
        end
    elseif strcmp(light.intype{i},'manual')
        %set signal vector according to custom red/green pattern
        signal = pattern; %pre-allocate signal vector
        while length(signal)< NumOfStates
            %repeat pattern until vector is of specified length
            curr_len = length(signal); %length of vector at current iter.
            spots_left = NumOfStates-curr_len; %spots open to fill vector
            if spots_left<=length(pattern)
                signal = [signal, signal(end)+pattern(1:spots_left)];%#ok
            else
                signal = [signal, signal(end)+pattern];%#ok
            end
        end
    else
        error('Improper traffic light input type specified.')
    end
    
    %store signal vectors in traffic light structure
    light.signal{i} = signal';
end

%calculate the timing windows for the egv to hit green lights
for i=1:NumOfLights
    v_avg = cell(NumOfStates+1,1);
    if i-1==0
        %set the starting time
        t_start = 0;
        %find the ending time
        i_end = find(light.signal{i}>t_start,10,'first');
        t_end = light.signal{i}(i_end);
        %find distance between lights
        dx = light.pos(i);
        %find average velocity bounds
        v_avg{1} = dx./(t_end-t_start)/kmh2mps;
    else
        for ii=1:NumOfStates+1
            %find the starting time
            if ii==1
                t_start = 0;
            else
                t_start = light.signal{i-1}(ii-1);
            end
            %find the ending time
            i_end = find(light.signal{i}>t_start,10,'first');
            t_end = light.signal{i}(i_end);

            %find distance between lights
            dx = light.pos(i)-light.pos(i-1);

            %find average velocity bounds
            v_avg{ii} = dx./(t_end-t_start)/kmh2mps;
        end
    end
    light.vs{i} = v_avg;
end
