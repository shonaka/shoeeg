classdef class_psd < handle
    % for plotting power spectral density using pmtm
    %
    %   Usage:
    %       psd_obj = class_psd('input',data,'nw',numwindow,...
    %                           'f',f,'fs',fs);
    %       process(psd_obj);
    %
    %   Arguments:
    %       'input': input data in a vector format. [ 1 x something ]
    %
    %   Options:
    %       'nw': number of windows for pmtm [default: 4]
    %       'f': cycle per unit time [default: length(x) where x is the input]
    %       'fs': sampling frequency [default: 100]
    %       'confidence': confidence level 0-less than1 [default: 0.95]
    %       'linewidth': line width [default: 0.5]
    %
    %   Reference:
    %       - https://www.mathworks.com/help/signal/ref/pmtm.html
    
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
        input;
        
        % other options
        nw;
        f;
        fs;
        confidence;
        linewidth;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_psd(varargin)
            % input data
            obj.input = get_varargin(varargin,'input',randn(200,1));
            
            % other parameters for plotting
            obj.nw = get_varargin(varargin,'nw',4);
            obj.f = get_varargin(varargin,'f',length(obj.input));
            obj.fs = get_varargin(varargin,'fs',100);
            obj.confidence = get_varargin(varargin,'confidence',0.95);
            obj.linewidth = get_varargin(varargin,'linewidth',0.5);
        end
    end
    
    methods
        function process(obj)            
            % plotting
            [pxx, f, pxxc] = pmtm(obj.input, obj.nw, obj.f, obj.fs,...
                'ConfidenceLevel',obj.confidence);

            plot(f, 10*log10(pxx), 'LineWidth', obj.linewidth)
            hold on;
            plot(f, 10*log10(pxxc), 'LineWidth', obj.linewidth)
            xlim([0 obj.fs/2])
            xlabel('Hz')
            ylabel('dB')
            title(['Multitaper PSD Estimate with ',...
                num2str(obj.confidence*100),'%-Confidence Bounds'])
            % some other things to make the plot look nicer
            % this cannot be controlled by defaults
            ax1 = gca;
            set(ax1, 'box', 'off');
            set(ax1, 'TickDir', 'out');
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

