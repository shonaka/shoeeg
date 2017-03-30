classdef class_kde
    % for plotting kernel density estimation with Silverman's rule of thumb
    %
    %   Usage:
    %       kde_obj = class_kde('input',data);
    %       output = process(kde_obj);
    %       plot_obj = class_plot('X',output.xi,'Y',output.f);
    %       plotting = process(plot_obj);
    %
    %   Arguments:
    %       'input': data containing info for plot
    %                   (e.g. a single vector data)
    %
    %   References:
    %       < The Silverman's rule of thumb >
    %       Silverman, Bernard W. Density estimation for statistics and data analysis.
    %       Vol. 26. CRC press, 1986.
    
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
        
        % other parameters for kde
        opt_kde;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_kde(varargin)
            % input data
            obj.data = get_varargin(varargin,'input',randn(20,1));
            
            % Set parameters and variables for plotting
            n = length(obj.data);
            
            % calculate the optimal bandwidth h
            opt_h = 1.06 * std(obj.data) * n^(-1/5);
            
            % other parameters for kde
            obj.opt_kde = get_varargin(varargin,'opt_kde',opt_h);
        end
    end
    
    methods
        function output = process(obj)            
            % calculate optimal kde
            [f_opt, xi_opt] = ksdensity(obj.data, 'width', obj.opt_kde);
            
            % save the parameters for later plotting
            output.f = f_opt;
            output.xi = xi_opt;
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

