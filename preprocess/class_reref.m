classdef class_reref < handle
    % for computing Re-reference to average or Common Average Reference
    %   Usage:
    %       reref_obj = class_reref('input',EEG);
    %       process(reref_obj);
    %       % extract processed EEG from object
    %       EEG = reref_obj.postEEG;
    %       % visualize difference before and after
    %       show(reref_obj);
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       clean_rawdata plugin: http://sccn.ucsd.edu/wiki/Plugin_list_process
    
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
        
        % for outputEEG
        postEEG;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_reref(varargin)
            % add path to dependencies
            sep = filesep;
            addpath(['..',sep,'dependencies']);
            % make sure to addpath to eeglab as well
            
            % input EEG (before CAR)
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % copy input to the output
            obj.postEEG = obj.preEEG;
        end
    end
    
    methods
        function process(obj)
            % for checking purposes
            fprintf('Start running Common Average Reference ...\n');
            % Run CAR
            obj.postEEG.nbchan = obj.preEEG.nbchan+1;
            obj.postEEG.data(end+1,:) = zeros(1, obj.preEEG.pnts);
            obj.postEEG.chanlocs(1,obj.preEEG.nbchan).labels = 'initialReference';
            obj.postEEG = pop_reref(obj.preEEG, []);
            obj.postEEG = pop_select(obj.preEEG,'nochannel',{'initialReference'});
            
            % for checking purposes
            fprintf('Finished running CAR.\n');

            % add note on processing steps
            if isfield(obj.postEEG,'process_step') == 0
                obj.postEEG.process_step = [];
                obj.postEEG.process_step{1} = 'CAR';
            else
                obj.postEEG.process_step{end+1} = 'CAR';
            end
        end
        
        function show(obj)
            % for visualizing the difference between pre and post
            vis_artifacts(obj.postEEG,obj.preEEG);
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

