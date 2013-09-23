% DP_MASTER
%
% This is the master file for an energy optimization program that 
% calculates the optimal trajectory of an electric ground vehicle.
% A dynamic programming algorithm is used.
%
% To run the program, enter the desired inputs (below) and hit 'run'.

clear all; close all; clc

%% User Input
%--ELECTRIC GROUND VEHICLE (egv)
egv.v.min  = 25;    %[km/h] minimum allowable velocity
egv.v.max  = 33;    %[km/h] maximum allowable velocity
egv.v.step = 1;     %[km/h] difference between discrete velocities
egv.v.v0   = 28;    %[km/h] starting velocity
egv.v.vN   ='free'; %[km/h] ending velocity ('free' if unspecified)
egv.x.step = 30;    %[m]    distance between discrete nodes
egv.x.xN   ='last'; %[m]    ending point of EGV ('last' for full road)

%--PRECEDING VEHICLE (pre)
pre.exist = 'y';      %is there a preceding vehicle? (y/n)
pre.v_in  = [29  28 32]; %[km/h] velocity profile
pre.x_in  = [37 600 2450]; %[m]    position where velocity takes place

%--TRAFFIC LIGHT (light)
light.exist = 'y'; %are there any stop lights? (y/n)

%--PLOT/VEIWING OPTIONS
view.progress     = 'waitbar';
view.results.y    = {'1_SOC','1_velocity','1_torques','1_terrain'};
view.results.x    = 'distance';
view.results.figs = 2;
%========================================================================
% ~.PROGRESS: option for viewing progress (select ONE)
% 
% 'none'      = view no indication of the progress
% 'simple'    = view text notifications of the starting and ending points
% 'cw'        = view progress in command window (percentage as text)
% 'waitbar'   = view progress in popup window with animated status bar
% 'animation' = view progress via custom animation
% 
%------------------------------------------------------------------------
% ~.RESULTS.Y: option for plotting results 
%            (can select multiple - must be a cell {})
% 
% NOTE: Must include identifier specifying in which
%       figure the data will be plotted. Axes will be arranged vertically
%       in order of their appearance. (case sensitive)
%  e.g. {'1_SOC','1_velocity','1_terrain','2_torques','2_terrain'}
%       will plot state of charge, velocity and terrain in figure 1 and 
%       torques and terrain in figure 2 (stacked vertically).
% 
% 'none'       = creates no plots
% 'no_warning' = creates no plots and does NOT notify the user
% 'SOC'        = plots state of charge
% 'velocity'   = plots the velocity profile
% 'torques'    = plots T1 and T2
% 'distance'   = plots distance travelled by the EGV
% 'terrain'    = plots the road altitude
% 
%------------------------------------------------------------------------
% ~.RESULTS.X: option for choosing variable to plot results against 
%            (select ONE)
% 
% 'time'     = plot results against time
% 'distance' = plot results against lateral distance
%========================================================================

%--FILES TO IMPORT
%name of folder where the data and other .m files are located
filenames.folder  = 'inputdata/';
%data file containing information about the terrain
filenames.terrain = 'terrainInfo.mat';
%sound to play when the program is complete
filenames.sound   = 'sms_curium.wav';
%data from previous runs
filenames.sample1 = 'DP_data_25-33_ini26-fin26.mat';
filenames.sample2 = 'results_preceding/DP_data_pre29_x0-10.mat';
filenames.sample3 = 'results_constant/DP_data_const28.mat';


%% Paramter Initialization
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





















