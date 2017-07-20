classdef class_DIPFIT < handle
    % for running DIPFIT
    %   Usage:
    %       dipfit_obj = class_DIPFIT('input',EEG);
    %       process(dipfit_obj);
    %       % extract processed EEG from object
    %       EEG = dipfit_obj.postEEG;
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %   
    %   Options:
    %       'threshold_grid': rejection threshold during component scan
    %                           [default: 100] (residual variance above
    %                           100% currently not rejecting any since we
    %                           reject later using dipfit_reject)
    %
    %       'threshold_twodip': threshold value for "true" peak selection
    %                           [default: 35]
    %
    %       'dipplot_show': whether to show the 3D interactive view of
    %                       dipole fitting results after the process
    %                       [default: 'off']
    %
    %       'plot_opt': plot option for dipplot [default: {'normlen','on'}
    %                   'image', 'fullmri'?
    %
    %       'mri_input': for providing individual MRI normalized to MNI
    %                    coordinates using SPM. For more information about
    %                    how to do normalization, take a look at:
    %                    https://sccn.ucsd.edu/wiki/A09:_Using_custom_MRI_from_individual_subjects
    %
    %       'head_model': for providing individual MRI based head models.
    %                     You can create this using Fieldtrip toolbox.
    %                     For more reference, take a look at:
    %                     http://www.fieldtriptoolbox.org/tutorial/headmodel_eeg_bem
    %
    %       'disable_fitTwo': disable fitTwoDipoles plugin [default: 'off']
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       DIPFIT2: https://sccn.ucsd.edu/wiki/A08:_DIPFIT
    %       fitTwoDipoles: EEGLAB plugin search from the GUI
    %       Fieldtrip-lite: Extension in EEGLAB to use fieldtrip functions
    %
    %   References:
    %       < General dipfit: better to check the above wiki for dipfit >
    %       Delorme, Arnaud, et al. "EEGLAB, SIFT, NFT, BCILAB, and ERICA:
    %       new tools for advanced EEG processing." 
    %       Computational intelligence and neuroscience 2011 (2011): 10.
    %
    %       < For Step 4: fitTwoDipoles >
    %       Piazza, Caterina, et al. "An Automated Function for Identifying
    %       EEG Independent Components Representing Bilateral Source Activity."
    %       XIV Mediterranean Conference on Medical and Biological Engineering
    %       and Computing 2016. Springer International Publishing, 2016.
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %               dipfit functions written by Arnaud Delorme
    %               fitTwoDiples written by Makoto Miyakoshi, Catarina
    %               Piazza
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
        preEEG; % before DIPFIT
        
        % for DIPFIT parameters
        threshold_grid;
        threshold_twodip;
        dipplot_show;
        plot_opt;
        mri_input;
        head_model;
        disable_fitTwo;
        
        % for outputEEG
        postEEG;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_DIPFIT(varargin)
            % input EEG
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % copy input to the output
            obj.postEEG = obj.preEEG;
            
            % load default settings from dipfit plugin
            dipfitdefs;
            
            % ===== Other parameters for DIPFIT =====
            obj.threshold_grid = get_varargin(varargin,'threshold_grid',100);
            obj.threshold_twodip = get_varargin(varargin,'threshold_twodip',35);
            obj.dipplot_show = get_varargin(varargin,'dipplot_show','off');
            obj.plot_opt = get_varargin(varargin,'plot_opt',{'normlen','on'});
            obj.mri_input = get_varargin(varargin,'mri_input',template_models(2).mrifile);
            obj.head_model = get_varargin(varargin,'head_model',template_models(2).hdmfile);
            obj.disable_fitTwo = get_varargin(varargin,'disable_fitTwo','off');
            % ===============================================
        end
    end
    
    methods
        function process(obj)
            % load default settings from dipfit plugin
            dipfitdefs;
            
            try
                % Corresponding to DIPFIT wiki: https://sccn.ucsd.edu/wiki/A08:_DIPFIT
                % Step 1: setting models and preferences
                %   coregister to deal with difference of digitized chanlocs with
                %   normal chanlocs.
                [~,coordinateTransformParameters] = ...
                    coregister(obj.preEEG.chanlocs, template_models(2).chanfile,...
                    'mesh', obj.head_model,...
                    'warp', 'auto', 'manual', 'off');
                obj.postEEG = pop_dipfit_settings(obj.preEEG,'hdmfile',obj.head_model,...
                    'coordformat','MNI',...
                    'mrifile',obj.mri_input,...
                    'chanfile',template_models(2).chanfile,...
                    'coord_transform',coordinateTransformParameters);

                % Step 2: Grid scanning
                %   this includes pop_dipfit_gridsearch and non-linear fit
                %   here, not rejecting anything, thus threshold = 100
                %   later, with dipfit_reject, reject RV > 20% or something
                obj.postEEG = pop_multifit_sho(obj.postEEG, 1:obj.postEEG.nbchan,...
                    'threshold', obj.threshold_grid, 'dipplot', obj.dipplot_show,...
                    'plotopt', obj.plot_opt);
                obj.postEEG.etc.dipfit_used = 'individualBEM';
            catch e
                fprintf('Something went wrong. Maybe the input head model issue\n');
                fprintf('Running with template files\n');
                [~,coordinateTransformParameters] = ...
                    coregister(obj.preEEG.chanlocs, template_models(2).chanfile,...
                    'mesh', template_models(2).hdmfile,...
                    'warp', 'auto', 'manual', 'off');
                obj.postEEG = pop_dipfit_settings(obj.preEEG,'hdmfile',template_models(2).hdmfile,...
                    'coordformat','MNI',...
                    'mrifile',obj.mri_input,...
                    'chanfile',template_models(2).chanfile,...
                    'coord_transform',coordinateTransformParameters);
                obj.postEEG = pop_multifit(obj.postEEG, 1:obj.postEEG.nbchan,...
                    'threshold', obj.threshold_grid, 'dipplot', obj.dipplot_show,...
                    'plotopt', obj.plot_opt);
                obj.postEEG.etc.dipfit_used = 'standard';
            end
            
            % Step 3: Search for and estimate symmetrically constrained
            % bilateral dipoles
            %   LRR = large rectangular region
            if strcmpi(obj.disable_fitTwo,'on')
                % do nothing
            elseif strcmpi(obj.disable_fitTwo,'off')
                obj.postEEG = fitTwoDipoles(obj.postEEG, 'LRR', obj.threshold_twodip);
            end
            
            % add note on processing steps
            if isfield(obj.postEEG,'process_step') == 0
                obj.postEEG.process_step = [];
                obj.postEEG.process_step{1} = 'DIPFIT';
            else
                obj.postEEG.process_step{end+1} = 'DIPFIT';
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

