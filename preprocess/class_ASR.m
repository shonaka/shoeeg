classdef class_ASR
    % for running Artifact Subspace Reconstruction (ASR)
    %   Usage:
    %       asr_obj = class_ASR('input',EEG,'cutoff',5);
    %       outEEG = process(asr_obj);
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
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_ASR(varargin)
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
            
            % other parameters for ASR
            obj.cutoff = get_varargin(varargin,'cutoff',5);
            obj.windowlen = get_varargin(varargin,'windowlen',...
                max(0.5,1.5*obj.preEEG.nbchan/obj.preEEG.srate));
            obj.stepsize = get_varargin(varargin,'stepsize',[]);
            obj.maxdims = get_varargin(varargin,'maxdims',0.66);
            obj.ref_maxbadchannels = get_varargin(varargin,'ref_maxbadchannels',0.075);
            obj.ref_tolerances = get_varargin(varargin,'ref_tolerances',[-3.5 5.5]);
            obj.ref_wndlen = get_varargin(varargin,'ref_wndlen',1);
            obj.usegpu = false;
        end
    end
    
    methods
        function outEEG = process(obj)
            % for checking purposes
            fprintf('Start running ASR...\n');
            
            % Run ASR with the options
            obj.preEEG = clean_asr(obj.preEEG,...
                obj.cutoff,...
                obj.windowlen,...
                obj.stepsize,...
                obj.maxdims,...
                obj.ref_maxbadchannels,...
                obj.ref_tolerances,...
                obj.ref_wndlen,...
                obj.usegpu);
            
            % add note on processing steps
            if isfield(obj.preEEG,'process_step') == 0
                obj.preEEG.process_step = [];
                obj.preEEG.process_step{1} = 'ASR';
            else
                obj.preEEG.process_step{end+1} = 'ASR';
            end
            
            % for checking purposes
            fprintf('Finished running ASR.\n');
            
            % saving the ASR processed EEG
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
