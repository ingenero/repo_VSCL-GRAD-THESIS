function [pre] = init_precedingvehicle(pre,egv,terrain,param,ns)
% pre = INIT_PRECEDINGVECHICLE(pre,egv,terrain,param,ns)
% 
% This function interprets the preceding vehicle info and outputs vectors
% for comparison with the EGV data from the DP algorithm

%extract distance between nodes from terrain info
dx = terrain.dist(2)-terrain.dist(1);

%make sure the inputs are allowable
if length(pre.v_in)~=length(pre.x_in)
    error('The inputs for the preceding vehicle must have the same length.')
elseif pre.x_in(1)<=0
    error('The preceding vehicle must start in front of the EGV.')
end

%find the index where the input velocities occur in the trajectory
NumSpec = length(pre.v_in); %number of inputs specified
ind = nan(NumSpec,1); %pre-allocate index vector
for i=1:NumSpec
    if pre.x_in(i) > egv.x.xN
        %If the preceding vehicle has input set to occur after the end of
        %the simulation, interpolate the value to what it would have been
        %at the ending point.
        pre.v_in(i) = interp1(pre.x_in,pre.v_in,egv.x.xN);
        pre.x_in(i) = egv.x.xN;
        %find index and assume this is the last node
        ind(i) = find(terrain.dist >= pre.x_in(i),1,'first');
        break
    else
        %find index
        ind(i) = find(terrain.dist >= pre.x_in(i),1,'first');
    end
end

%set velocity at each index
pre.v = nan(ns.N+1,1); %pre-allocate velocity vector
for i=ind(1):ns.N+1
    if terrain.dist(i) <= pre.x_in(NumSpec)
        %interpolate velocity between specified points (i.e. constant and
        %continuous acceleration between differing velocities)
        pre.v(i,1) = interp1(pre.x_in,pre.v_in,terrain.dist(i));
    else
        %set all trailing nodes to have the same velocity as the last
        %specified point
        pre.v(i,1) = pre.v_in(NumSpec);
    end
end

%calculate behavior between specified starting location and the next 
%nearest node
nearest_node.dist = (ind(1)-1)*dx-pre.x_in(1); %[m]
nearest_node.vavg = mean([pre.v_in(1) pre.v(ind(1))])*param.conv.kmh2mps; %[m/s]
nearest_node.time = nearest_node.dist/nearest_node.vavg; %[s]

%set time preceding vehicle takes in between each index
pre.t = nan(ns.N+1,1); %pre-allocate time vector
for i=ind(1):ns.N+1
    if i==ind(1)
        pre.t(i,1) = nearest_node.time;
    else
        v_avg = mean(pre.v(i-1:i))*param.conv.kmh2mps;
        pre.t(i,1) = dx/v_avg;
    end
end

pre.firstnode = ind(1);
