classdef class_ASRwrapper < handle
    % for running Artifact Subspace Reconstruction (ASR) wrapper
    % this is better than running ASR only one
    %   Usage:
    %       asr_obj = class_ASRwrapper('input',EEG);
    %       process(asr_obj);
    %       % extract processed EEG from object
    %       EEG = asr_obj.postEEG;
    %       % visualize difference before and after
    %       show(asr_obj);
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %                Assumed to be zero-mean. Highpass filtered.
    %
    %   Options:
    %       'FlatlineCriterion': if it has X seconds of flatline, reject
    %                            [default: 5]
    %       'BurstCriterion': standard deviation cutoff for removal of bursts [default: 5]
    %       
    %       You could use baseline feeding in the ASR, but it's not
    %       recommended if the data are not recorded continuously.
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       ASR: http://sccn.ucsd.edu/eeglab/plugins/clean_rawdata0_31.zip
    %
    %   For more detail, read the paper:
    %       Mullen, Tim, et al. "Real-time modeling and 3D visualization of
    %       source dynamics and connectivity using wearable EEG."
    %       Engineering in Medicine and Biology Society (EMBC), 2013
    %       35th Annual International Conference of the IEEE. IEEE, 2013.
    %
    %   Or refer to this PDF:
    %       http://sccn.ucsd.edu/eeglab/plugins/ASR.pdf
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %               clean_artifacts written by Christian Kothe
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
        
        % for ASR wrapper parameters
        FlatlineCriterion;
        BurstCriterion;
        BurstCriterionRefMaxBadChns;
        
        % for outputEEG
        postEEG;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_ASRwrapper(varargin)
            % add path to dependencies
            if ispc == 1
                sep = '\';
            elseif isunix == 1
                sep = '/';
            end
            addpath(['..',sep,'dependencies']);
            % make sure to addpath to eeglab as well
            
            % input EEG
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % copy input to the output
            obj.postEEG = obj.preEEG;
            
            % other parameters for ASR
            obj.FlatlineCriterion = get_varargin(varargin,'FlatlineCriterion',5);
            obj.BurstCriterion = get_varargin(varargin,'BurstCriterion',5);
            obj.BurstCriterionRefMaxBadChns = ...
                get_varargin(varargin,'BurstCriterionRefMaxBadChns',[]);
        end
    end
    
    methods
        function process(obj)
            % for checking purposes
            fprintf('Start running ASR wrapper ...\n');
            
            % Run ASR wrapper with options
            obj.postEEG = clean_artifacts(obj.preEEG, ...
                'FlatlineCriterion', obj.FlatlineCriterion,...
                'Highpass',         'off',... % disabled should be handled by PREP
                'ChannelCriterion',  'off',... % disabled
                'LineNoiseCriterion',  'off',... % disabled
                'BurstCriterion',    obj.BurstCriterion,...
                'WindowCriterion',   'off',...
                'BurstCriterionRefMaxBadChns', obj.BurstCriterionRefMaxBadChns);
            
            % add note on processing steps
            if isfield(obj.postEEG,'process_step') == 0
                obj.postEEG.process_step = [];
                obj.postEEG.process_step{1} = 'ASR';
            else
                obj.postEEG.process_step{end+1} = 'ASR';
            end
            
            % for checking purposes
            fprintf('Finished running ASR.\n');
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

