% This script saves the dp data
%% Print current settings
clc; close all
clear settings
%electric ground vehicle
settings.egv = [num2str(egv.v.min) '-' num2str(egv.v.max) 'km/h'];
settings.start = [num2str(egv.v.v0) 'km/h'];
%preceding vehicle
if strcmp(pre.exist,'n')
    settings.pre = 'none';
else
    settings.vel_pre = [num2str(pre.v_in) 'km/h'];
    settings.x0_pre = [num2str(pre.x_in) 'm'];
end
%traffic light
if strcmp(light.exist,'n')
    settings.light = 'none';
else
    settings.x_light = [num2str(light.pos) 'm'];
    settings.t_light = [num2str(light.green) '/' num2str(light.red) 's'];
end

disp(settings)

%% Save
% NAMING CONVENTION: 'dp_[vel]pre_[#]light'
n{1} = '25-35'; %egv range
n{2} = '28'; %preceding veh
n{3} = '1'; %number of lights
n{4} = '40-40'; %light timing (green-red)

filename = ['dp' n{1} '_' n{2} 'pre_' n{3} 'light' n{4} '.mat'];
folder = 'G:\School\VSCL\repo_VSCL-GRAD-THESIS\data\';

save([folder filename])
