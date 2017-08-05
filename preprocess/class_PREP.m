classdef class_PREP < handle
    % for running PREP pipeline
    %   Usage:
    %       prep_obj = class_PREP('input',EEG);
    %       process(prep_obj);
    %       EEG = prep_obj.postEEG;
    %       % visualize difference before and after
    %       show(prep_obj);
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %
    %   Options:
    %       < for boundary >
    %       'ignoreBoundaryEvents': if you have boundary events, turn this
    %                               to true. [default: false]
    %
    %       < for detrend >
    %       'detrendChannels':      vector of channels to detrend.
    %                               [default: all channels]
    %
    %       'detrendCutoff':        frequency cutoff for detrending or high pass
    %                               filtering. [default: 0.1Hz]
    %
    %       < for line noise >
    %       'lineNoiseChannels':    vector of channels to remove line noise
    %                               from. [default: all channels]
    %
    %       'lineFrequencies':      vector of frequencies in Hz of the line
    %                               noise peaks to remove. [default: [60,120,180,240]]
    %
    %       < for reference >
    %           < channels >
    %           'referenceChannels':            vector of channels used for reference.
    %                                           [default: all channels]
    %
    %           'evaluationChannels':           vector of channels to test for
    %                                           noiseness. [default: all channels]
    %
    %           'rereferencedChannels':         vector of channels to rereference.
    %                                           [default: all channels]
    %
    %           < thresholds >
    %           'badTimeThreshold':             threshold fraction of bad correlation
    %                                           windows. [default: 0.1]
    %
    %           'robustDeviationThreshold':     z-score cutoff for robust channel
    %                                           deviation. [default: 7]
    %
    %           'highFrequencyNoiseThreshold':  z-score cutoff for SNR
    %                                           (signal above 50Hz). [default: 10]
    %
    %           < others >
    %           'meanEstimateType':             method for initial estimate of the
    %                                           robust mean. [default: median]
    %
    %           'ransacOff':                    if true, RANSAC is not used for bad channel.
    %                                           However, if you felt there's too much removal,
    %                                           consider turing this off. [default: true]
    %
    %           'ransacSampleSize':             Number fo sample matrices
    %                                           for computing ransac.
    %                                           [default: 50]
    %
    %           'ransacChannelFraction':        Fraction of evaluation
    %                                           channels RANSAC uses to predict a channel.
    %                                           [default: 0.25]
    %
    %           'ransacCorrelationThreshold':   Cutoff correlation for
    %                                           unpredictability be neighbors.
    %                                           [default: 0.7]
    %
    %           'ransacUnbrokenTime':           Cutoff fraction of time
    %                                           channel can have poor ransac predictability.
    %                                           [default: 0.4]
    %
    %           'ransacWindowSeconds':          Size of windows in seconds
    %                                           over which to computer RANSAC predictions.
    %                                           [default: 5]
    %
    %       < for reporting >
    %       'reportMode':       'normal' means report generated, skip does PREP and
    %                           no report. [default: 'skip']
    %
    %       'summaryFilePath':  file name (including necessary path) html
    %                           summmary. [default: current working directory]
    %
    %       'sessionFilePath':  file name (including necessary path) pdf
    %                           detailed report. [default: same as above]
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       PREP: https://github.com/VisLab/EEG-Clean-Tools
    %
    %   For more detail, read the paper:
    %       Bigdely-Shamlo N, Mullen T, Kothe C, Su K-M and Robbins KA (2015)
    %       The PREP pipeline: standardized preprocessing for large-scale EEG analysis
    %       Front. Neuroinform. 9:16. doi: 10.3389/fninf.2015.00016
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %               prepPipeline written by Kay Robbins
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
        % for PREP parameters
        params = struct();
        
        % for output
        postEEG;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_PREP(varargin)
            % add path to dependencies
            sep = filesep;
            addpath(which('dependencies'));
			
            % make sure to addpath to eeglab as well
            
            % input EEG (before PREP)
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % copy input to the output
            obj.postEEG = obj.preEEG;
            
            % ===== Other parameters structure for PREP =====
            % (for more to add, check getPipelineDefaults.m in PREP lib)
            % for boundary
            obj.params.ignoreBoundaryEvents = ...
                get_varargin(varargin,'ignoreBoundaryEvents',true);
            % for detrend
            obj.params.detrendChannels = ...
                get_varargin(varargin,'detrendChannels',1:obj.preEEG.nbchan);
            obj.params.detrendCutoff = ...
                get_varargin(varargin,'detrendCutoff',0.1);
            % for line noise
            obj.params.lineNoiseChannels = ...
                get_varargin(varargin,'lineNoiseChannels',1:obj.preEEG.nbchan);
            obj.params.lineFrequencies = ...
                get_varargin(varargin,'lineFrequencies', [60, 120, 180, 240]);
            % for reference
            % channels
            obj.params.referenceChannels = ...
                get_varargin(varargin,'referenceChannels',1:obj.preEEG.nbchan);
            obj.params.evaluationChannels = ...
                get_varargin(varargin,'evaluationChannels',1:obj.preEEG.nbchan);
            obj.params.rereferencedChannels = ...
                get_varargin(varargin,'rereferencedChannels',1:obj.preEEG.nbchan);
            % thresholds
            % making this part more conservative compared to the
            % original one.
            obj.params.badTimeThreshold = ...
                get_varargin(varargin,'badTimeThreshold',0.1);
            obj.params.robustDeviationThreshold = ...
                get_varargin(varargin,'robustDeviationThreshold',10);
            obj.params.highFrequencyNoiseThreshold = ...
                get_varargin(varargin,'highFrequencyNoiseThreshold',8);
            % others
            obj.params.meanEstimateType = ...
                get_varargin(varargin,'meanEstimateType','median');
            % (if you felt too much removal, make this true)
            % made this part more conservative to the original version
            obj.params.ransacOff = ...
                get_varargin(varargin,'ransacOff',true);
            obj.params.ransacSampleSize = ...
                get_varargin(varargin,'ransacSampleSize',50);
            obj.params.ransacChannelFraction = ...
                get_varargin(varargin,'ransacChannelFraction',0.25);
            obj.params.ransacCorrelationThreshold = ...
                get_varargin(varargin,'ransacCorrelationThreshold',0.65);
            obj.params.ransacUnbrokenTime = ...
                get_varargin(varargin,'ransacUnbrokenTime',0.4);
            obj.params.ransacWindowSeconds = ...
                get_varargin(varargin,'ransacWindowSeconds',5);
            % for report
            obj.params.reportMode = ...
                get_varargin(varargin,...
                'reportMode','skip');
            obj.params.summaryFilePath = ...
                get_varargin(varargin,...
                'summaryFilePath',[pwd,'\',obj.preEEG.setname,'_summary.html']);
            obj.params.sessionFilePath = ...
                get_varargin(varargin,...
                'sessionFilePath',[pwd,'\',obj.preEEG.setname,'_report.pdf']);
            % ===============================================
        end
    end
    
    methods
        function process(obj)
            % running the actual prep pipeline
            [obj.postEEG, ~] = prepPipeline(obj.preEEG, obj.params);
            % save interpolated channels as a result of PREP pipeline
            % this is only when some channels were removed
            try
                [~, interporatedChannelNames] = eeg_decodechan(obj.postEEG.chanlocs,...
                    obj.postEEG.etc.noiseDetection.reference.interpolatedChannels.all);
                interporatedChannels = obj.postEEG.etc.noiseDetection.reference.interpolatedChannels;
                obj.postEEG.etc.prep_interp_chans_name = interporatedChannelNames;
                obj.postEEG.etc.prep_interp_chans = interporatedChannels;
                % for checking purposes
                fprintf('Reporting interpolated channels:\n');
                disp(interporatedChannelNames);
                disp(interporatedChannels);
            catch e
                fprintf('No channels were removed using PREP\n');
            end
            % add note on processing steps
            if isfield(obj.postEEG,'process_step') == 0
                obj.postEEG.process_step = [];
                obj.postEEG.process_step{1} = 'PREP';
            else
                obj.postEEG.process_step{end+1} = 'PREP';
            end
        end
        
        function show(obj)
            % for visualizing pre and post EEG
            vis_artifacts(obj.postEEG, obj.preEEG);
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

