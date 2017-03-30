classdef class_scatter
    % for plotting scatter plot with your intended properties
    %
    %   Usage:
    %       scat_obj = class_scatter('X',data,'Y',data,'facecolor',color,'marksize',msize);
    %       output = process(scat_obj);
    %
    %   Arguments:
    %       'X': data for x-axis (no need to put)
    %       'Y': data for y-axis (mandatory)
    %
    %   Options:
    %       'facecolor': what color you want for the plot
    %       'marksize': size for marker
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
        Y;
        
        % other options
        X;
        facecolor;
        marksize;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_scatter(varargin)
            % input data
            obj.Y = get_varargin(varargin,'Y',randn(20,1));
            
            % other parameters for plotting
            obj.X = get_varargin(varargin,'X',1:length(obj.Y));
            obj.facecolor = get_varargin(varargin,'facecolor','b');
            obj.marksize = get_varargin(varargin,'marksize',25);
        end
    end
    
    methods
        function output = process(obj)            
            % plotting
            scat_plot = scatter(obj.X,obj.Y,obj.marksize,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',obj.facecolor);
            
            % some other things to make the plot look nicer
            % this cannot be controlled by defaults
            ax1 = gca;
            set(ax1, 'box', 'off');
            set(ax1, 'TickDir', 'out');
            
            % saving the figure
            output = scat_plot;
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

