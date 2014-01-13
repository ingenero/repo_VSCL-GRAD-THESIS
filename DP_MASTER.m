% DP_MASTER
%
% This is the master file for an energy optimization program that 
% calculates the optimal trajectory of an electric ground vehicle.
% A dynamic programming algorithm is used.
%
% To run the program, enter the desired inputs (below) and hit 'run'.

runcode = 1;
if runcode
    clear all; close all; clc; runcode = 1;
end

%% User Input
%--ELECTRIC GROUND VEHICLE (egv)
egv.v.min  = 25;    %[km/h] minimum allowable velocity
egv.v.max  = 35;    %[km/h] maximum allowable velocity
egv.v.step = 1;     %[km/h] difference between discrete velocities
egv.v.v0   = 28;    %[km/h] starting velocity
egv.v.vN   ='free'; %[km/h] ending velocity ('free' if unspecified)
egv.x.step = 30;    %[m]    distance between discrete nodes
egv.x.xN   ='last'; %[m]    ending point of EGV ('last' for full road)

%--PRECEDING VEHICLE (pre)
pre.exist = 'n'; %is there a preceding vehicle? (y/n)
pre.v_in  = 28; %[km/h] velocity profile
pre.x_in  = 50; %[m] position where velocity takes place

%--TRAFFIC LIGHT (light)
light.exist  = 'n'; %are there any stop lights? (y/n)
% light.pos    = [800 1600]; %[m] position of each traffic light
% light.intype = {'auto','auto'};
light.pos    = 1200; %[m] position of each traffic light
light.intype = {'auto'};
light.green  = 40; %[s] duration of green (for 'auto' type)
light.red    = 40; %[s] duration of red (for 'auto' type)

%--PLOT/VEIWING OPTIONS
view.progress     = 'waitbar';
view.results.y    = {'1_time','1_velocity','1_terrain'};
% view.results.y    = {'1_SOC','1_velocity','1_torques','1_time','1_terrain'};
view.results.x    = 'distance';
view.results.figs = 1; %set the number of figures to create

%--FILES TO IMPORT
%name of folder where the data and other .m files are located
filenames.folder  = 'inputdata/';
%data file containing information about the terrain
filenames.terrain = 'terrainInfo.mat';
%sound to play when the program is complete
filenames.sound   = 'sound_finally.mp3';
%data from previous runs
filenames.sample1 = 'DP_data_25-33_ini26-fin26.mat';
filenames.sample2 = 'results_preceding/DP_data_pre29_x0-10.mat';
filenames.sample3 = 'results_constant/DP_data_const28.mat';

%=========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%% NOTES on INPUTS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=========================================================================
% ---------------------------- LIGHT -------------------------------------
% ~.INTYPE: option for choosing the method of specifying the traffic signal
%   'auto'   = specify repeating pattern
%   'manual' = specify red/green time manually (see 'init_trafficlight.m')
% ------------------------------------------------------------------------
% 
% ---------------------------- VIEW --------------------------------------
% ~.PROGRESS: option for viewing progress (select ONE)
%   'none'      = view no indication of the progress
%   'simple'    = view text notifications of the starting and ending points
%   'cw'        = view progress in command window (percentage as text)
%   'waitbar'   = view progress in popup window with animated status bar
%   'animation' = view progress via custom animation
% 
% ~.RESULTS.Y: option for plotting results (can select multiple-must be a cell {})
% NOTE: Must include identifier specifying in which
%       figure the data will be plotted. Axes will be arranged vertically
%       in order of their appearance. (case sensitive)
%       e.g. {'1_SOC','1_velocity','1_terrain','2_torques','2_terrain'}
%       will plot state of charge, velocity and terrain in figure 1 and 
%       torques and terrain in figure 2 (stacked vertically).
%   'none'       = creates no plots
%   'no_warning' = creates no plots and does NOT notify the user
%   'SOC'        = plots state of charge
%   'velocity'   = plots the velocity profile
%   'torques'    = plots T1 and T2
%   'distance'   = plots distance travelled by the EGV
%   'terrain'    = plots the road altitude
% 
% ~.RESULTS.X: option for choosing indep. variable in plots (select ONE)
%   'time'     = plot results against time
%   'distance' = plot results against lateral distance
% ------------------------------------------------------------------------
%=========================================================================


%% Paramter Initialization
if runcode
%add functions folder to the current path
addpath('functions')

%--LENGTHS USED IN DP
%set number of discrete states
ns.Nq = 30;

%--IMPORT TERRAIN INFO
%extract terrain info from the 'init_terrain' function
[terrain,egv,ns] = init_terrain(filenames,egv,ns);

%--PHYSICAL PARAMETERS
%extract initialized variables from 'init_param' function
[param,vect,matr,tbl,opt,state,statevect,slope,constraint] ...
    = init_param(egv,ns);
%store the number of possible speeds
ns.NumOfSpds = length(vect.v);

%--TRAFFIC BEHAVIOR
%calculate the behavior of the preceding vehicle from the input parameters
%for comparison with the egv
if strcmp(pre.exist,'y')
    pre = init_precedingvehicle(pre,egv,terrain,param,ns);
end
%set timing and position of the traffic lights for constraint of the egv
if strcmp(light.exist,'y')
    light = init_trafficlight(light,param);
end


%% Dynamic Programming
%Start at the last node and calculate the SOE for each possible
%combination of current and next speeds.
ns.k = ns.N;
%set states before starting
iteration_num = 1;
ns.speedLimit = [egv.v.max+1 egv.v.min];
ns.iL = length(light.pos); %number of lights
h_wb = waitbar(0,'Calculating Optimal Trajectory...');

while ns.k >= 1
    %calculate slope of the stage at the current iteration
    [slope] = dp_slope(ns.k,terrain,slope,egv);
    
    %populate table with possible trajectories
    [matr,tbl] = dp_findoptspeeds(...
        egv,pre,light,slope,state,statevect,vect,matr,tbl,constraint,param,ns);
    
    %proceed to the previous position in the path
    ns.k = ns.k-1;
    iteration_num = iteration_num+1;
    
    %view current progress
    percent_done = (ns.N-ns.k)/ns.N*100;
    waitbar(percent_done/100,h_wb,...
        ['Calculating Optimal Trajectory... (' num2str(percent_done) '%)']);
    
    %traffic light constraint
    if strcmp(light.exist,'y')
        [ns] = dp_lightconstraint(light,terrain,opt,tbl,vect,egv,param,ns);
    end
end
end


%% Post Processing
% close all; delete(h_wb)

opt = post_getopt(opt,tbl,vect,egv,param,ns);
if strcmp(pre.exist,'y')
    [opt.t_cum,pre.t_cum] = post_getpos(opt,pre,ns);
else
    [opt.t_cum] = post_getpos(opt,pre,ns);
end
[h_axes,i_time] = post_plot(view,terrain,opt,param,1);

%plot preceding vehicle trajectory and traffic light timing
post_plottraffic(pre,light,terrain,opt,h_axes,i_time)


%% End Notification
[sound.data,sound.freq] = audioread([filenames.folder filenames.sound]);
sound.wvlngth = length(sound.data);
sound.time = linspace(0, sound.wvlngth/sound.freq, sound.wvlngth);

%increase volume and play sound
sound.amp = sound.data*.1;
sound.obj =  audioplayer(sound.amp,sound.freq);
play(sound.obj)

%plot sound waveform (optional)
shouldiplot = 0;
if shouldiplot
    figure; plot(sound.time,sound.data,'b'); %#ok 
    title('Sound Effect Waveform');
end
