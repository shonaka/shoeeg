classdef class_reref
    % for computing Re-reference to average or Common Average Reference
    %   Usage:
    %       reref_obj = class_reref('input',EEG);
    %       EEG = process(reref_obj);
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %   
    %   Options:
    %       
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    
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
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_reref(varargin)
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
        end
    end
    
    methods
        function outEEG = process(obj)
            % for checking purposes
            fprintf('Start running Common Average Reference ...\n');
            % Run CAR
            obj.preEEG.nbchan = obj.preEEG.nbchan+1;
            obj.preEEG.data(end+1,:) = zeros(1, obj.preEEG.pnts);
            obj.preEEG.chanlocs(1,obj.preEEG.nbchan).labels = 'initialReference';
            obj.preEEG = pop_reref(obj.preEEG, []);
            obj.preEEG = pop_select(obj.preEEG,'nochannel',{'initialReference'});
            
            % for checking purposes
            fprintf('Finished running CAR.\n');

            % add note on processing steps
            if isfield(obj.preEEG,'process_step') == 0
                obj.preEEG.process_step = [];
                obj.preEEG.process_step{1} = 'CAR';
            else
                obj.preEEG.process_step{end+1} = 'CAR';
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

