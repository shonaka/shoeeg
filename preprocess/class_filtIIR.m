classdef class_filtIIR
    % for filtering using zero-phase IIR filter (butterworth)
    %   Usage:
    %       filt_obj = class_filtIIR('input',EEG,'cutoff',0.1,'type','highpass','order',2);
    %       EEG = process(filt_obj);
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %   
    %   Options:
    %       'cutoff': Cutoff frequency. [default: 0.1 Hz]
    %       'type': 'high', 'low', and 'bandpass'.
    %               [default: 'high']
    %       'order': filter order for IIR butterworth, [default: 2]
    %
    %   Pre-requisites:
    %       Singal processing toolbox
    %       Parallel processing toolbox
    
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
        % for handling EEG data
        preEEG;
        
        % other parameters
        cutoff;
        type;
        order;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_filtIIR(varargin)
            % add path to dependencies
            if ispc == 1
                sep = '\';
            elseif isunix == 1
                sep = '/';
            end
            addpath(['..',sep,'dependencies']);
            % make sure to addpath to eeglab as well
            
            % input EEG (before CAR)
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % other parameters
            obj.cutoff = get_varargin(varargin,'cutoff',0.1);
            obj.type = get_varargin(varargin,'type','high');
            obj.order = get_varargin(varargin,'order',2);
        end
    end
    
    methods
        function outEEG = process(obj)
            % for checking purposes
            fprintf('Start running filter ...\n');
            
            % Define other parameters needed for filtering
            nqFreq = obj.preEEG.srate/2;
            nbChan = obj.preEEG.nbchan;
            signal_data = obj.preEEG.data;
            
            % preallocate output
            filtered_data = zeros(size(signal_data));
            
            % Run filtering
            [num, den, z, p] = butter(obj.order,obj.cutoff./nqFreq,obj.type);
            [num_tf, den_tf] = ss2tf(num, den, z, p);
            
            parfor ch = 1:nbChan
                filtered_data(ch,:) = filtfilt(num_tf, den_tf ,signal_data(ch,:));
            end
            
            % for checking purposes
            fprintf('Finished running class_filtIIR.\n');

            % add note on processing steps
            if isfield(obj.preEEG,'process_step') == 0
                obj.preEEG.process_step = [];
                obj.preEEG.process_step{1} = obj.type;
            else
                obj.preEEG.process_step{end+1} = obj.type;
            end
            
            % saving the filter processed EEG
            obj.preEEG.data = filtered_data;
            outEEG = obj.preEEG;
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

