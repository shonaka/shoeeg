classdef class_dipplot < handle
    % for plotting dipole clusters
    %   Usage:
    %{
            dip_obj = class_dipplot('STUDY',STUDY,'ALLEEG',ALLEEG,...
                        'numclusts',5,'first_idx',2,'sort_idx',[4,2,3,5,1],...
                        'color_matrix',color_obj.blind_friendly.color,...
                        'endcolor_matrix',color_obj.blind_friendly.color,...
                        'dipsize',[25,60]);
            % or if you don't specify colors or sizes or sort order, use
            % dip_obj = class_dipplot('STUDY',STUDY,'ALLEEG',ALLEEG,...
            %   'numclusts',5,'first_idx',2);
            process(dip_obj);
            % visualization
            figure;
            subplot(2,2,1);
            visualize(dip_obj, 1, 1); % first cluster, top view
            subplot(2,2,2);
            visualize(dip_obj, 3, 2); % third cluster, sagittal view
            subplot(2,2,3);
            visualize(dip_obj, 5, 3); % fifth cluster, coronal view
    %}
    %   Arguments:
    %       'STUDY': STUDY structure made before running this (required)
    %       'ALLEEG': ALLEEG structure made at the same time as STUDY
    %
    %   Options:
    %       'numclusts': number of clusters you computed in k-means
    %
    %       'first_idx': first index for the cluster without parent or
    %                    outlier clusters. If you haven't computed the
    %                    outlier clusters, then the first index should be 2
    %                    so that you just skip the 1st parent cluster. If
    %                    you computed the outlier clusters, the first index
    %                    should be 3 so that you skip the first parent
    %                    cluster and the next outlier cluster. [default: 2]
    %
    %       'sort_idx': if you want to plot the clusters in a specific
    %                   order (e.g. plotting clusters that have more
    %                   subjects) then give an vector specifying the order.
    %                   As a default, it's 1:numclusts so if you have 5
    %                   clusters, 1:5
    %
    %       'color_matrix': specify the cluster colors. You could give 1 by
    %                       number of clusters cell array to this argument.
    %                       As a default, it's using color blind friendly
    %                       color cell arrays 1 x 10 from class_colors.
    %
    %       'endcolor_matrix': If you want to use different colors for the
    %                          centroids only, then give a cell array here.
    %                          As a default, it's the same color as the
    %                          color_matrix one above.
    %
    %       'dipsize': specify the size of each dipole to be plotted. make
    %                  sure to give 1 x 2 vector (e.g. [25, 60]). The first
    %                  one is the size for each dipole and the second one
    %                  is the size for the centroid. [default: [25, 60]]
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
        STUDY;
        ALLEEG;
        
        % for cluster plotting arguments
        options;
        numclusts;
        first_idx;
        sort_idx;
        color_matrix;
        endcolor_matrix;
        dipsize;
        
        % for output
        cluster_dip_models;
        dip_size_arr;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_dipplot(varargin)
            % load default colors
            try
                color_obj = class_colors;
                default_colors = color_obj.blind_friendly.color;
            catch e
                warning('You may need to add class_colors under shoeeg\plot');
            end
            
            % input STUDY
            obj.STUDY = get_varargin(varargin,'STUDY',[]);
            % input ALLEEG
            obj.ALLEEG = get_varargin(varargin,'ALLEEG',[]);
            
            % check errors (need the above inputs)
            [obj.STUDY, obj.ALLEEG] = ...
                std_checkset(obj.STUDY, obj.ALLEEG);
            
            % ===== Other parameters for Cluster plotting =====
            obj.numclusts = get_varargin(varargin,'numclusts',3);
            obj.first_idx = get_varargin(varargin,'first_idx',2);
            obj.sort_idx = get_varargin(varargin,'sort_idx',1:obj.numclusts);
            obj.color_matrix = get_varargin(varargin,'color_matrix',default_colors);
            obj.endcolor_matrix = obj.color_matrix;
            obj.dipsize = get_varargin(varargin,'dipsize',[25,60]);
            % =================================================
            
            % initialize
            obj.cluster_dip_models = {};
            obj.dip_size_arr = {};
        end
    end
    
    methods
        % for preparation before plotting clusters
        function process(obj)
            % initialize
            obj.cluster_dip_models = {};
            obj.dip_size_arr = {};
            
            % some default parameters to set
            obj.STUDY = pop_dipparams(obj.STUDY, 'default');
            opt_dipplot = {'projlines',obj.STUDY.etc.dipparams.projlines, ...
                'axistight', obj.STUDY.etc.dipparams.axistight,...
                'projimg', obj.STUDY.etc.dipparams.projimg,...
                'normlen', 'on', 'pointout', 'on',...
                'verbose', 'off', 'dipolelength', 0,'spheres','on'};
            for nc = 1:obj.numclusts
                obj.options{nc} = opt_dipplot;
                obj.options{nc}{end+1} =  'mri';
                obj.options{nc}{end+1} =  obj.ALLEEG(1).dipfit.mrifile; % standard BEM model
                obj.options{nc}{end+1} =  'coordformat';
                obj.options{nc}{end+1} =  'MNI';
            end
            
            % some variables needed to compute below calculations
            lencluster = length(obj.STUDY.cluster);
            lenshift = lencluster - obj.numclusts;
            
            % calculate how many ICs are in each cluster
            for i = 1:obj.numclusts
                numICs_sort(i) = ...
                    length(obj.STUDY.cluster(obj.sort_idx(i)+lenshift).comps);
            end
            
            % for each cluster set options
            for nc = 1:obj.numclusts
                % get info needed for the specific cluster
                len = numICs_sort(nc);
                % running through each of the ICs to make a structure that
                % contains all the information needed to plot dipplot. This
                % part is excluding the parent and outlier clusters if
                % there's any.
                for k = 1:len
                    abset = ...
                        obj.STUDY.datasetinfo(obj.STUDY.cluster(obj.sort_idx(nc)+lenshift).sets(1,k)).index;
                    comp = obj.STUDY.cluster(obj.sort_idx(nc)+lenshift).comps(k);
                    obj.cluster_dip_models{nc}(k).posxyz = obj.ALLEEG(abset).dipfit.model(comp).posxyz;
                    obj.cluster_dip_models{nc}(k).momxyz = obj.ALLEEG(abset).dipfit.model(comp).momxyz;
                    obj.cluster_dip_models{nc}(k).rv = obj.ALLEEG(abset).dipfit.model(comp).rv;
                end
                % other options
                dip_color = cell(1,len+1); % allocate
                % color for each IC
                dip_color(1:len+1) = {obj.color_matrix{nc}};
                % color for the last IC = centroid
                dip_color(end) = {obj.endcolor_matrix{nc}};
                % specify the color options you applied at the top
                obj.options{nc}{end+1} = 'color';
                obj.options{nc}{end+1} = dip_color;
                % for centroid
                try
                    obj.STUDY.cluster(obj.sort_idx(nc)+lenshift).dipole = ...
                        computecentroid(obj.cluster_dip_models{nc});
                catch e
                    warning('You may need to add path to computecentroid.m in shoeeg\dependencies');
                end
                obj.cluster_dip_models{nc}(end + 1) = ...
                    obj.STUDY.cluster(obj.sort_idx(nc)+lenshift).dipole;
                % for dipole size
                % specify the size for each of ICs
                obj.dip_size_arr{nc} = obj.dipsize(1) * ones(len,1);
                % specify the size for the centroids
                obj.dip_size_arr{nc}(end+1) = obj.dipsize(2);
            end
        end
        
        
        % for plotting the clusters
        function visualize(obj, which_cluster, viewangle)
            if viewangle == 1
                % plotting from top view
                dipplot(obj.cluster_dip_models{which_cluster},...
                    obj.options{which_cluster}{:},...
                    'view', [0 0 1], 'gui', 'off',...
                    'dipolesize', obj.dip_size_arr{which_cluster},...
                    'image', 'mri');
            elseif viewangle == 2
                % plotting from sagittal view
                dipplot(obj.cluster_dip_models{which_cluster},...
                    obj.options{which_cluster}{:},...
                    'view', [1 0 0], 'gui', 'off',...
                    'dipolesize', obj.dip_size_arr{which_cluster},...
                    'image', 'mri');
            elseif viewangle == 3
                % plotting from coronal view
                dipplot(obj.cluster_dip_models{which_cluster},...
                    obj.options{which_cluster}{:},...
                    'view', [0 -1 0], 'gui', 'off',...
                    'dipolesize', obj.dip_size_arr{which_cluster},...
                    'image', 'mri');
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

