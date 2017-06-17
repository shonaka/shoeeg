classdef class_resamp < handle
    % for resampling EEGLAB structure data (better than normal resample.m)
    %   Usage:
    %       resamp_obj = class_resamp('input',EEG,'resampleFreq',100);
    %       process(resamp_obj);
    %       % extract processed EEG from object
    %       EEG = resamp_obj.postEEG;
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %   
    %   Options:
    %       'resampleFreq': Frequency you want to resample to.
    %                       [default: 100 Hz]
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       pop_resample: change the part where it automatically renames
    %       the setfile.
    %
    %   This function is better than normal resample in MATLAB, since it
    %   resamples not only the data, but event points too. Other related
    %   parameters in the EEGLAB structure is also resampled.
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %               pop_resample written by Arnaud Delorme
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
        resampleFreq;
        
        % for outputEEG
        postEEG;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_resamp(varargin)
            % add path to dependencies
            sep = filesep;
            addpath(['..',sep,'dependencies']);
            % make sure to addpath to eeglab as well
            
            % input EEG
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % copy input to the output
            obj.postEEG = obj.preEEG;
            
            % other parameters
            obj.resampleFreq = get_varargin(varargin,'resampFreq',100);
        end
    end
    
    methods
        function process(obj)
            % for checking purposes
            fprintf('Start resampling ...\n');
            
            % get the original setname
            orisetname = obj.preEEG.setname;
            
            % run resample in EEGLAB function
            obj.postEEG = pop_resample(obj.preEEG, obj.resampleFreq);
            
            % for checking purposes
            fprintf('Finished running resample in eeglab function.\n');

            % add note on processing steps
            if isfield(obj.postEEG,'process_step') == 0
                obj.postEEG.process_step = [];
                obj.postEEG.process_step{1} = 'Resample';
            else
                obj.postEEG.process_step{end+1} = 'Resample';
            end
            try
                obj.postEEG.setname = [orisetname,'_resamp'];
            catch e
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

