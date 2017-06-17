classdef class_ASRonly < handle
    % for running only the Artifact Subspace Reconstruction (ASR)
    %   Usage:
    %       asr_obj = class_ASRonly('input',EEG,'cutoff',5);
    %       process(asr_obj);
    %       % extract processed EEG from object
    %       EEG = asr_obj.postEEG;
    %       % visualize difference before and after
    %       visualize(asr_obj);
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %                Assumed to be zero-mean. Highpass filtered.
    %
    %   Options:
    %       'cutoff': standard deviation cutoff for removal of bursts [default: 5]
    %
    %       == Below parameters should be used with default ==
    %       'windowlen': length of the stats window [default: 0.5]
    %       'stepsize': step size for processing [default: [] ]
    %       'maxdims': max dimensionality to reconstruct [default: 2/3]
    %       'ref_maxbadchannels': [default: 0.075]
    %       'ref_tolerances': [default: [-3.5 5.5] ]
    %       'ref_wndlen': [default: 1]
    %       'usegpu': [default: false]
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
    %               clean_asr written by Christian Kothe
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
        
        % for ASR parameters
        cutoff;
        windowlen;
        stepsize;
        maxdims;
        ref_maxbadchannels;
        ref_tolerances;
        ref_wndlen;
        usegpu; % not working should be always false
        
        % for outputEEG
        postEEG;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_ASRonly(varargin)
            % add path to dependencies
            sep = filesep;
            addpath(['..',sep,'dependencies']);
            % make sure to addpath to eeglab as well
            
            % input EEG
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % copy input to the output
            obj.postEEG = obj.preEEG;
            
            % other parameters for ASR
            obj.cutoff = get_varargin(varargin,'cutoff',5);
            obj.windowlen = get_varargin(varargin,'windowlen',0.5);
            obj.stepsize = get_varargin(varargin,'stepsize',[]);
            obj.maxdims = get_varargin(varargin,'maxdims',[]);
            obj.ref_maxbadchannels = get_varargin(varargin,'ref_maxbadchannels',[]);
            obj.ref_tolerances = get_varargin(varargin,'ref_tolerances',[]);
            obj.ref_wndlen = get_varargin(varargin,'ref_wndlen',[]);
            obj.usegpu = false;
        end
    end
    
    methods
        function process(obj)
            % for checking purposes
            fprintf('Start running ASR...\n');
            
            % Run ASR with the options
            obj.postEEG = clean_asr(obj.preEEG,...
                obj.cutoff,...
                obj.windowlen,...
                obj.stepsize,...
                obj.maxdims,...
                obj.ref_maxbadchannels,...
                obj.ref_tolerances,...
                obj.ref_wndlen,...
                obj.usegpu);
            
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
        
        function visualize(obj)
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

