classdef class_gantt_chart
    % for plotting gantt chart like figure
    %   Usage:
    %       gantt_obj = class_gantt_chart('input',array,'Fs',freq);
    %       output = process(gantt_obj);
    %
    %   Arguments:
    %       'input': array containing info for plot
    %                   (e.g. num of gantt x length)
    %
    %   Options:
    %       'Fs': what's the frequency of the data [default: 1]
    %
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %
    %     This program is free software: you can redistribute it and/or modify
    %     it under the terms of the GNU General Public License as published by
    %     the Free Software Foundation, either version 3 of the License, or
    %     (at your option) any later version.
    %
    %     This program is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    %
    %     You should have received a copy of the GNU General Public License
    %     along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    properties
        % input (required)
        array;
        
        % other options
        Fs;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_gantt_chart(varargin)
            % input array
            obj.array = get_varargin(varargin,'input',randn(5,2));
            
            % other parameters for plotting
            obj.Fs = get_varargin(varargin,'Fs',1);
        end
    end
    
    methods
        function output = process(obj)
            % for checking purposes
            fprintf('Plotting Gantt Chart...\n');
            
            % Set parameters and variables for plotting
            num_y = size(obj.array,1);
            num_x = size(obj.array,2);
            if num_x ~= 2
                warning('Input array must contain 2 columns specifying lags and taps.\n');
            end
            oneUnit2ms = 1/obj.Fs*1000; % converting Fs to ms
            bar_h = 0.6; % fixed number
            delta_h = bar_h / 2;
            convert_arr = obj.array * oneUnit2ms; % arr converted into ms
            ecolor = 'k';
            
            % plotting
            fig = figure('Color','w');
            set(fig, 'Position', [200,200,1000,700]);
            set(0,'defaultAxesFontName', 'Arial');
            set(0,'defaultTextFontName', 'Arial');
            set(0,'defaultAxesFontSize', 12);
            set(0,'defaultTextFontSize', 12);
            
            for yi = 1:num_y+1
                % define colors
                if yi == num_y+1
                    fcolor = 'r';
                else
                    fcolor = [.5 .5 .5];
                end
                % define positions
                if yi ~= num_y+1 % for given data
                    x(yi) = 0-convert_arr(yi,1)-convert_arr(yi,2);
                    y = num_y+2-yi-delta_h;
                    width(yi) = convert_arr(yi,2);
                    height = bar_h;
                    pos = [x(yi), y, width(yi), height];
                    % make ytick labels
                    ylabelname{yi} = ['Trial ',num2str(yi)];
                else % mean
                    x_mean = mean(x);
                    y_mean = num_y+2-yi-delta_h;
                    width_mean = mean(width);
                    height_mean = bar_h;
                    pos = [x_mean, y_mean, width_mean, height_mean];
                    % make ytick labels
                    ylabelname{yi} = 'Mean';
                end
                % plot bars
                rectangle('Position',pos,...
                    'FaceColor',fcolor,...
                    'EdgeColor',ecolor);
                hold on;
            end
            
            % get xlim and adjust a bit
            xl = xlim;
            xlim([xl(1)-50 0]);
            ylim([0.5 num_y+1+.5]);
            
            % ticklabels
            ylabelname = flip(ylabelname);
            yticklabels(ylabelname);
            
            % labels
            xlabel('ms');
            
            % some other things to make the plot look nicer
            ax1 = gca;
            ax1.YAxisLocation = 'origin';
            set(ax1, 'linewidth', 2);
            set(ax1, 'box', 'off');
            set(ax1,'TickDir','out');
            
            % saving the AMICA processed EEG
            output = fig;
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

