% This script generates plots from the saved dp data
clear all; close all; clc
set(0,'DefaultFigureWindowStyle','docked')

folder = 'data/';
shouldiload = 1;

%import data
if shouldiload
    k = 0;
    files = dir(fullfile(cd, folder));
    data  = cell(length(files)-2,1);
    names = cell(length(files)-2,1);
    for i=3:length(files)
        k = k+1;
        names{k} = files(i).name;
        data{k}  = importdata([folder names{k}]);
    end
end

for i=1:length(data)
    figure(i);
    data{i}.view.results
    
    [h_axes,i_time] = post_plot(data{i}.view,data{i}.terrain,...
        data{i}.opt,data{i}.param,i);
    post_plottraffic(data{i}.pre,data{i}.light,data{i}.terrain,...
        data{i}.opt,h_axes,i_time)
    if isfield(data{i},'settings')
        if isfield(data{i}.settings,'pre') && isfield(data{i}.settings,'light')
            titlewords = [data{i}.settings.egv ' range, pre=' ...
                data{i}.settings.pre ', light=' data{i}.settings.light];
        elseif isfield(data{i}.settings,'pre')
            titlewords = [data{i}.settings.egv ' range, pre='...
                data{i}.settings.pre ', light=' data{i}.settings.x_light];
        elseif isfield(data{i}.settings,'light')
            titlewords = [data{i}.settings.egv ' range, pre='...
                data{i}.settings.vel_pre ', light=' data{i}.settings.light];
        else
            titlewords = [data{i}.settings.egv ' range, pre='...
                data{i}.settings.vel_pre ', light=' data{i}.settings.x_light];
        end
    else
        titlewords = [data{i}.egv.v.min '-' data{i}.egv.v.max 'km/h range'];
    end
    suptitle(titlewords)
end
