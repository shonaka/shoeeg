classdef class_inspectICs < handle
    % for running automatic IC rejection suggestions
    %   Usage:
    %       inspect_obj = class_inspectICs('input',EEG);
    %       process(inspect_obj);
    %       % extract the output EEG from object
    %       EEG = inspect_obj.postEEG;
    %       % for visualizing components
    %       visualize(inspect_obj);
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %
    %   Options:
    %       < DIPFIT >
    %       'threshold_RV': threshold of residual variance for rejection.
    %                       [default: 20] (reject RV > 20%)
    %
    %       < SASICA >
    %       'trial_focal': detect outlier trials. If you are using continuos
    %                      data, don't enable this. [default: 0] (disable)
    %       'EOG_corr': calculate correlation with EOG channels [default:
    %       0]
    %           If you are enabling the EOG correlation, need to specify:
    %           'vertical_eog': vertical EOG channel names
    %           'horizontal_eog': horizontal EOG channel names
    %       'SNR': signal to noise ratio [default: 1] (enable)
    %       'FASTER': use FASTER algorithm (not recommended) [default: 0]
    %       'ADJUST': use ADJUST algorithm [default: 1]
    %       'MARA': use MARA algorithm [default: 1]
    %       'noplot': plot the figures [default: 1] (don't plot)
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       DIPFIT2: donwload the plugin from eeglab GUI
    %       ADJUST: download the plugin from eeglab GUI
    %       MARA: download the plugin from eeglab GUI
    %       SASICA: download the plugin from eeglab GUI
    %
    %   References:
    %       <General dipfit: better to check the above wiki for dipfit>
    %       Delorme, Arnaud, et al. "EEGLAB, SIFT, NFT, BCILAB, and ERICA:
    %       new tools for advanced EEG processing."
    %       Computational intelligence and neuroscience 2011 (2011): 10.
    %
    %       <ADJUST>
    %       Mognon, Andrea, et al. "ADJUST: An automatic EEG artifact detector
    %       based on the joint use of spatial and temporal features."
    %       Psychophysiology 48.2 (2011): 229-240.
    %
    %       <SASICA>
    %       Chaumon, Maximilien, Dorothy VM Bishop, and Niko A. Busch.
    %       "A practical guide to the selection of independent components
    %       of the electroencephalogram for artifact correction."
    %       Journal of neuroscience methods 250 (2015): 47-63.
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %               dipfit_reject written by Robert Oostenveld
    %               eeg_SASICA written by Maximilien Chaumon
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
        
        % for other parameters
        threshold_RV;
        trial_focal;
        EOG_corr;
        vertical_eog;
        horizontal_eog;
        do_SNR;
        do_FASTER;
        do_ADJUST;
        do_MARA;
        opt_noplot;
        
        % for output
        postEEG;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_inspectICs(varargin)
            % add path to dependencies
            sep = filesep;
            addpath(['..',sep,'dependencies']);
            % make sure to addpath to eeglab as well
            
            % input EEG
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % copy input to the output
            obj.postEEG = obj.preEEG;
            
            % ===== Other parameters for DIPFIT and SASICA =====
            obj.threshold_RV = get_varargin(varargin,'threshold_RV',20);
            obj.trial_focal = get_varargin(varargin,'trial_focal',0);
            obj.EOG_corr = get_varargin(varargin,'EOG_corr',0);
            obj.vertical_eog = get_varargin(varargin,'vertical_eog',[]);
            obj.horizontal_eog = get_varargin(varargin,'horizontal_eog',[]);
            obj.do_SNR = get_varargin(varargin,'do_SNR',1);
            obj.do_FASTER = get_varargin(varargin,'do_FASTER',0);
            obj.do_ADJUST = get_varargin(varargin,'do_ADJUST',1);
            obj.do_MARA = get_varargin(varargin,'do_MARA',1);
            obj.opt_noplot = get_varargin(varargin,'opt_noplot',1);
            % ===============================================
        end
    end
    
    methods
        function process(obj)
            % Step 1: Run dipfit rejection to find RV > threshold
            obj.preEEG.dipfit.model = dipfit_reject(obj.preEEG.dipfit.model,...
                obj.threshold_RV/100);
            for i = 1:length(obj.preEEG.dipfit.model)
                dipoles(i)= isempty(obj.preEEG.dipfit.model(i).posxyz);
            end
            rejectdip = find(dipoles);
            
            % Step 2: Run SASICA to identify other non-brain ICs
            %   before that, change the chanlocs from digitized one since
            %   the captrak digitizer gives a weird 90 rotation
            obj.preEEG.digitized_chanlocs = obj.preEEG.chanlocs;
            try
                obj.preEEG.chanlocs = obj.preEEG.EEGraw.chanlocs;
            catch e
            end
            % load default configs from SASICA plugin
            cfg = SASICA('getdefs');
            % modify a few parameters
            cfg.trialfoc.enable = obj.trial_focal;
            cfg.EOGcorr.enable = obj.EOG_corr;
            cfg.Veogchannames = obj.vertical_eog;
            cfg.Heogchannames = obj.horizontal_eog;
            cfg.resvar.enable = 1;
            cfg.resvar.thresh = obj.threshold_RV;
            cfg.SNR.enable = obj.do_SNR;
            cfg.FASTER.enable = obj.do_FASTER;
            cfg.ADJUST.enable = obj.do_ADJUST;
            cfg.MARA.enable = obj.do_MARA;
            cfg.opts.noplot = obj.opt_noplot;
            % run SASICA
            [obj.postEEG, cfg] = eeg_SASICA(obj.preEEG, cfg);
            
            % add note on processing steps
            if isfield(obj.postEEG,'process_step') == 0
                obj.postEEG.process_step = [];
                obj.postEEG.process_step{1} = 'inspectICs';
            else
                obj.postEEG.process_step{end+1} = 'inspectICs';
            end
            
            % saving the processed EEG
            obj.postEEG.reject.residualVarianceReject = rejectdip;
            obj.postEEG.etc.SASICA_config = cfg;
        end
        
        function visualize(obj)
            % for visualizing identified components
            pop_selectcomps(obj.postEEG);
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

