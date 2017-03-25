classdef class_resamp
    % for resampling EEGLAB structure data (better than normal resample.m)
    %   Usage:
    %       resamp_obj = class_resamp('input',EEG,'resampleFreq',100);
    %       EEG = process(resamp_obj);
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
    %
    %   This function is better than normal resample in MATLAB, since it
    %   resamples not only the data, but event points too. Other related
    %   parameters in the EEGLAB structure is also resampled.
    
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
        resampleFreq;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_resamp(varargin)
            % add path to dependencies
            if ispc == 1
                sep = '\';
            elseif isunix == 1
                sep = '/';
            end
            addpath(['.',sep,'dependencies']);
            % make sure to addpath to eeglab as well
            
            % input EEG
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % other parameters
            obj.resampleFreq = get_varargin(varargin,'resampFreq',100);
        end
    end
    
    methods
        function outEEG = process(obj)
            % for checking purposes
            fprintf('Start resampling ...\n');
            
            % run resample in EEGLAB function
            obj.preEEG = pop_resample(obj.preEEG, obj.resampleFreq);
            
            % for checking purposes
            fprintf('Finished running resample in eeglab function.\n');

            % add note on processing steps
            if isfield(obj.preEEG,'process_step') == 0
                obj.preEEG.process_step = [];
                obj.preEEG.process_step{1} = 'Resample';
            else
                obj.preEEG.process_step{end+1} = 'Resample';
            end
            try
                EEG.setname = [dataName,'_resamp'];
            catch e
            end
            
            % saving the CAR processed EEG
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

