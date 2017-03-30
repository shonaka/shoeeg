classdef class_plot
    % for plotting line plot with your intended properties
    %
    %   Usage:
    %       plot_obj = class_plot('X',data,'Y',data,'color',color,'linewidth',3);
    %       output = process(plot_obj);
    %
    %   Arguments:
    %       'X': data for x-axis (no need to put)
    %       'Y': data for y-axis (mandatory)
    %
    %   Options:
    %       'color': what color you want for the plot
    %                [default: 'k' = black]
    %       'linewidth': your desired linewidth [default: 3]
    %       'linestyle': line style [default: solid line = '-']
    
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
        Y;
        
        % other options
        X;
        color;
        linewidth;
        linestyle;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_plot(varargin)
            % input data
            obj.Y = get_varargin(varargin,'Y',randn(20,1));
            
            % other parameters for plotting
            obj.X = get_varargin(varargin,'X',1:length(obj.Y));
            obj.color = get_varargin(varargin,'color','k');
            obj.linewidth = get_varargin(varargin,'linewidth',3);
            obj.linestyle = get_varargin(varargin,'linestyle','-');
        end
    end
    
    methods
        function output = process(obj)            
            % plotting
            plot_obj = plot(obj.X,obj.Y,...
                'color',obj.color,...
                'linewidth',obj.linewidth,...
                'linestyle',obj.linestyle);
            
            % some other things to make the plot look nicer
            % this cannot be controlled by defaults
            ax1 = gca;
            set(ax1, 'box', 'off');
            set(ax1, 'TickDir', 'out');
            
            % saving the figure
            output = plot_obj;
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

