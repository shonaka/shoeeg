classdef class_histogram
    % for plotting histogram with optimal binsize using the
    % Freedman-Diaconis rule
    %
    %   Usage:
    %       hist_obj = class_histogram('input',data,'facecolor',color);
    %       output = process(hist_obj);
    %
    %   Arguments:
    %       'input': data containing info for plot
    %                   (e.g. a single vector data)
    %
    %   Options:
    %       'facecolor': what color you want for the plot
    %
    %   References:
    %       The Freedman-Diaconis rule
    %       https://en.wikipedia.org/wiki/Freedman%E2%80%93Diaconis_rule
    
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
        data;
        
        % other options
        facecolor;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_histogram(varargin)
            % input data
            obj.data = get_varargin(varargin,'input',randn(20,1));
            
            % other parameters for plotting
            obj.facecolor = get_varargin(varargin,'facecolor','b');
        end
    end
    
    methods
        function output = process(obj)
            % for checking purposes
            fprintf('Plotting Histogram with optimal binsize...\n');
            
            % Set parameters and variables for plotting
            n = length(obj.data);
            % calculate the optimal bin width
            opt_binwidth = 2 * iqr(obj.data) / n^(1/3);
            
            % plotting
            hist_opt = histogram(obj.data);
            hist_opt.BinWidth = opt_binwidth;
            hist_opt.FaceColor = obj.facecolor;
            
            % saving the figure
            output = hist_opt;
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

