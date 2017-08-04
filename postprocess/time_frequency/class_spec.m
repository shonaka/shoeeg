classdef class_spec < handle
    % for calculating and plotting spectrograms
    %   Usage:
    %       spec_obj = class_spec('input',data,'winsize',100,'Fs',100);
    %       output = process(spec_obj);
    %       % for plotting the spectrogram
    %       show(spec_obj);
    %
    %   Arguments:
    %       'input': data matrix (channel x samples)
    %
    %   Options:
    %       'winsize': sliding window size [default: 100]
    %
    %       'noverlap': overlapping sample size. As a default using a full
    %                   overlap = overlapping almost all but moving 1 sample
    %
    %       'nfft': number of sampling points to calculate the discrete
    %               fourier transform [default: 2^nextpow2(winsize)]
    %
    %       'Fs': sampling frequency of your signal input
    %             [default: 100 (Hz)]
    %
    %   Pre-requisites:
    %       Signal Processing Toolbox
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
        % for input
        input;
        
        % other parameters for spectrogram
        winsize;
        noverlap;
        nfft;
        Fs;
        
        % for storing the output of the spectrogram for later use
        sfft;
        cycFreq;
        timeInstants;
        psd;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_spec(varargin)
            % input data
            obj.input = get_varargin(varargin,'input',randn(64,2000));
            
            % other parameters for spectrogram
            % ================================
            obj.winsize = get_varargin(varargin,'winsize',100);
            obj.noverlap = get_varargin(varargin,'noverlap',obj.winsize-1);
            obj.nfft = get_varargin(varargin,'nfft',2^(nextpow2(obj.winsize)));
            obj.Fs = get_varargin(varargin,'Fs',100);
            % ================================
            
            % initialize the output
            obj.sfft = [];
            obj.cycFreq = [];
            obj.timeInstants = [];
            obj.psd = [];
        end
    end
    
    methods
        % calculating the spectrogram
        function output = process(obj)
            % calculate the spectrogram based on the given arguments
            [s,f,t,ps] = ...
                spectrogram(obj.input, obj.winsize, obj.noverlap, obj.nfft, obj.Fs);
            
            % put them into output and the class object
            output.s = s;
            output.f = f;
            output.t = t;
            output.ps = ps;
            
            obj.sfft = s;
            obj.cycFreq = f;
            obj.timeInstants = t;
            obj.psd = ps;
        end
        
        % showing the spectrogram but in our way of view
        function show(obj)
            % use color class in shoeeg\plot
            color_obj = class_colors();
            colgrad = color_obj.gradient.colormap;
            
            % actual plotting
            figure;
            imagesc(obj.timeInstants, obj.cycFreq, 10*log10(obj.psd));
            
            % labels
            xlabel('Time (seconds)');
            ylabel('Frequency (Hz)');
            
            % colorbar
            cl = colormap(colgrad);
            cb = colorbar;
            xlabel(cb,'dB');
            
            % other things to make the plot nicer
            set(gca,'YDir','Normal');
            set(gca,'box','off');
            set(gca,'TickDir','out');
        end
        
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

