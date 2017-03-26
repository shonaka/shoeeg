classdef class_fig_defaults
    % for setting default settings of your own for figure plotting
    %   Usage:
    %       % Just to load the settings, use this
    %       fig_defaults_obj = class_fig_defaults();
    %
    %       % If you want to modify something, do so.
    %       fig_defaults_obj =
    %       class_fig_defautls('minortick','on','gridlines','on');
    %
    %   Reference:
    %       https://www.mathworks.com/help/matlab/creating_plots/default-property-values.html
    
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
        minortick;
        gridlines;
        fontname;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_fig_defaults(varargin)
            % parameters to change
            obj.minortick = get_varargin(varargin,'minortick','off');
            obj.gridlines = get_varargin(varargin,'gridlines','off');
            obj.fontname = get_varargin(varargin,'fontname','Arial');
            
            % change the default parameters
            set(groot, ...
                ... % Text related
                'DefaultTextFontName', obj.fontname, ...
                'DefaultTextVerticalAlignment', 'middle', ...
                'DefaultTextHorizontalAlignment', 'left', ...
                ...
                ... % Axis related
                'DefaultLineLineWidth', 3, ...
                'DefaultAxesFontName', obj.fontname, ...
                'DefaultAxesLineWidth', 1.5, ...
                'DefaultAxesFontSize', 14, ...
                'DefaultAxesBox', 'off', ...
                'DefaultAxesColor', 'w', ...
                'DefaultAxesLayer', 'Bottom', ...
                'DefaultAxesNextPlot', 'replace', ...
                'DefaultAxesTickDir', 'out', ...
                'DefaultAxesTickLength', [.02 .02], ...
                ...
                ... % Other figure related
                'DefaultFigureColor', 'w', ...
                'DefaultFigureInvertHardcopy', 'off', ...
                'DefaultFigurePaperUnits', 'inches', ...
                'DefaultFigureUnits', 'inches', ...
                'DefaultFigurePaperPosition', [0, 0, 5, 3.09], ...
                'DefaultFigurePaperSize', [5, 3.09], ...
                'DefaultFigurePosition', [2, 5, 4.9, 2.99]);
            
            % for putting minor ticks
            if strcmpi(obj.minortick,'on') == 1
                set(groot,...
                    'DefaultAxesXMinorTick', 'on', ...
                    'DefaultAxesYMinorTick', 'on', ...
                    'DefaultAxesZMinorTick', 'on');
            end
            
            % for putting grid lines
            if strcmpi(obj.gridlines,'on') == 1
                set(groot,...
                    'DefaultAxesXGrid', 'on', ...
                    'DefaultAxesYGrid', 'on', ...
                    'DefaultAxesZGrid', 'on');
            end
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

