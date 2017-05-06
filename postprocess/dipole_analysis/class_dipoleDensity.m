classdef class_dipoleDensity
    % for plotting dipole density from STUDY file
    %   Usage:
    %       dipden_obj = class_dipoleDensity('inputStudy',STUDY,'inputEEG',ALLEEG);
    %       process(dipden_obj);
    %
    %   Arguments:
    %       'inputStudy': STUDY structure made before running this (required)
    %       'inputEEG': ALLEEG structure made at the same time as STUDY
    %
    %   Options (for more info go to reference at the bottom):
    %       'which_clust': which cluster you want to show as dipole
    %                      density? [default: 2] (which is Parent cluster)
    %                      this depends on your STUDY.cluster structure.
    %                      If you have outliers, 4 should be the first
    %                      cluster. If you don't have outliers, then 3
    %                      should be the first cluster.
    %
    %       'which_group': which group you want to plot. [default: 2]
    %                      (which is all) this also depends on your
    %                      structure. Please check.
    %
    %       'dipole_color': what color do you want for your dipole?
    %                       [default: [1,0,0]] (which is Red)
    %
    %       'dipole_color_name': what is the name of the color?
    %                            [default: 'Red']
    %
    %       'slice_orientation': 1 = Axial (default), 2 = sagittal, 3 =
    %                            coronal
    %
    %       'gauss_smooth_sigma': Gaussian smoothing sigma in mm scale.
    %                             [default: 14.2]. This will be converted to
    %                             FWHM = 2.355 * sigma. For more
    %                             information, https://en.wikipedia.org/wiki/Full_width_at_half_maximum
    %
    %       'color_upper_limit': Color scale upper limit. [default: []]
    %
    %       'group_subtractor': 1 = none (default), 2 = all
    %
    %       'group_subtracted': 1 = none (default), 2 = all
    %
    %       'threshold_pval': Used for group analysis [default: 5] (%)
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       std_dipoleDensity: https://sccn.ucsd.edu/wiki/DipoleDensity
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %               2012 Makoto Miyakoshi (original program)
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
        inputSTUDY;
        inputALLEEG;
        
        % for Dipole Density parameters
        which_clust;
        which_group;
        dipole_color;
        dipole_color_name;
        slice_orientation;
        gauss_smooth_sigma;
        color_upper_limit;
        group_subtractor;
        group_subtracted;
        threshold_pval;
        
        % structure to summarize all
        plotParams;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_dipoleDensity(varargin)
            % add path to dependencies (need this for
            % custom dipole density function)
            if ispc == 1
                sep = '\';
            elseif isunix == 1
                sep = '/';
            end
            addpath(['..',sep,'..',sep,'dependencies']);
            % make sure to addpath to eeglab as well
            
            % input STUDY
            obj.inputSTUDY = get_varargin(varargin,'inputSTUDY',[]);
            % input ALLEEG
            obj.inputALLEEG = get_varargin(varargin,'inputEEG',[]);
            
            % check errors (need the above inputs)
            [obj.inputSTUDY, obj.inputALLEEG] = ...
                std_checkset(obj.inputSTUDY, obj.inputALLEEG);
            
            % ===== Other parameters for Dipole Density =====
            obj.which_clust = get_varargin(varargin,'which_clust',2);
            obj.which_group = get_varargin(varargin,'which_group',2);
            obj.dipole_color = get_varargin(varargin,'dipole_color',[1,0,0]);
            obj.dipole_color_name = get_varargin(varargin,'dipole_color_name','Red');
            obj.slice_orientation = get_varargin(varargin,'slice_orientation',1);
            obj.gauss_smooth_sigma = get_varargin(varargin,'gauss_smooth_sigma',14.2);
            obj.color_upper_limit = get_varargin(varargin,'color_upper_limit',[]);
            obj.group_subtractor = get_varargin(varargin,'group_subtractor',1);
            obj.group_subtracted = get_varargin(varargin,'group_substracted',1);
            obj.threshold_pval = get_varargin(varargin,'threshold_pval',5);
            % ===============================================
            
            % put the parameters into a structure
            obj.plotParams{1,1}.cluster = obj.which_clust;
            obj.plotParams{1,1}.group = obj.which_group;
            obj.plotParams{1,1}.color = obj.dipole_color;
            obj.plotParams{1,1}.colorName = obj.dipole_color_name;
            % just assingn 1 to the rest since we are not plotting
            for i = 1:4
                obj.plotParams{1,1+i}.cluster = 1;
                obj.plotParams{1,1+i}.group = 1;
            end
            obj.plotParams{1,6} = obj.slice_orientation;
            obj.plotParams{1,7} = obj.gauss_smooth_sigma/2.355;
            obj.plotParams{1,8} = obj.color_upper_limit;
            obj.plotParams{1,9} = obj.group_subtractor;
            obj.plotParams{1,10} = obj.group_subtracted;
            obj.plotParams{1,11} = obj.threshold_pval;
            obj.plotParams{1,12} = 0; % for saving figures
        end
    end
    
    methods
        % if you just want to run normally
        function process(obj)
            % run std_dipoleDensity to get all the plots
            std_dipoleDensity(obj.inputSTUDY, obj.inputALLEEG, obj.plotParams)
        end
        
        % if you want to plot slices only
        function sliceplot(obj)
            % run custom std_dipoleDensity to plot only slices
            onlyslices = 1;
            obj.plotParams{1,13} = onlyslices;
            std_dipoleDensity_sho(obj.inputSTUDY, obj.inputALLEEG, obj.plotParams)
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

