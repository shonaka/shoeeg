classdef class_filtIIR < handle
    % for filtering using zero-phase IIR filter (butterworth)
    %   Usage:
    %       % It doesn't have to be EEGLAB structure, you could feed data
    %       matrix as input
    %       filt_obj = class_filtIIR('input',EEG,'cutoff',0.1,'type','high','order',2);
    %       process(filt_obj);
    %       % extract the output EEG from object
    %       EEG = filt_obj.postEEG;
    %       % for visualization
    %       show(filt_obj);
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB or data (channel x samples)
    %   
    %   Options:
    %       'cutoff': Cutoff frequency. [default: 0.1 Hz]
    %       'type': 'high', 'low', and 'bandpass'.
    %               [default: 'high']
    %       'order': filter order for IIR butterworth, [default: 2]
    %       'Fs': needed only if the input was data matrix
    %               [default: 100 (Hz)]
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
        
        % checking the data status (whether it's EEGLAB struct or data mat)
        isEEGLABstruct;
        
        % other parameters
        cutoff;
        type;
        order;
        Fs; % needed only if the input was data matrix
        
        % for output
        postEEG;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_filtIIR(varargin)
            % add path to the function used in this class
            addpath(which('checkEEGLABstruct.m'));
            
            % make sure to addpath to eeglab as well
            
            % input EEG (before CAR)
            obj.preEEG = get_varargin(varargin,'input',randn(64,1000));
            
            % check if the input is EEGLAB structure or data matrix
            obj.isEEGLABstruct = checkEEGLABstruct(obj.preEEG);
            
            % copy input to the output
            obj.postEEG = obj.preEEG;
            
            % other parameters
            obj.cutoff = get_varargin(varargin,'cutoff',0.1);
            obj.type = get_varargin(varargin,'type','high');
            obj.order = get_varargin(varargin,'order',2);
            obj.Fs = get_varargin(varargin,'Fs',100);
        end
    end
    
    methods
        function process(obj)
            % for checking purposes
            fprintf('Start running filter ...\n');
            
            % Define other parameters needed for filtering
            if obj.isEEGLABstruct == 1
                % input is EEGLAB structure
                nqFreq = obj.preEEG.srate/2;
                nbChan = obj.preEEG.nbchan;
                signal_data = obj.preEEG.data;
            elseif obj.isEEGLABstruct == 0
                % input is just a data matrix (channel x samples)
                nqFreq = obj.Fs;
                nbChan = size(obj.preEEG,1);
                signal_data = obj.preEEG;
            end
            
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
            if obj.isEEGLABstruct == 1
                if isfield(obj.postEEG,'process_step') == 0
                    obj.postEEG.process_step = [];
                    obj.postEEG.process_step{1} = obj.type;
                else
                    obj.postEEG.process_step{end+1} = obj.type;
                end
            end
            
            % saving the filter processed EEG
            if obj.isEEGLABstruct == 1
                obj.postEEG.data = filtered_data;
            elseif obj.isEEGLABstruct == 0
                obj.postEEG = filtered_data;
            end
        end
        
        function show(obj)
            try
                % for visualizing the difference between pre and post
                vis_artifacts(obj.postEEG,obj.preEEG);
            catch e
                warning(['Maybe you have used data matrix ',...
                    '(channel x samples) ',...
                    'but vis_artifacts requires EEGLAB structure',...
                    ' as input. I will try to fix this problem later.']);
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

