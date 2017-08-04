classdef class_getBA < handle
    % for calculating the estimated Brodmann Area (BA)
    %   Usage:
    %       ba_obj = class_getBA('input',tal_coordinates);
    %       % Just to get approximate brodmann areas and gyruses
    %       process(ba_obj);
    %       % give number of clusters, talairach coordinates sorted in a
    %       cell array as arguments to get the sorted Brodmann areas and
    %       the Gyruses
    %       output = getSortedBA(ba_obj, numclusts, tal_sorted);
    %
    %   Arguments:
    %       'input': input coordinates in Talairach (already converted
    %                from MNI coordinates [dimension: N x 3]
    %                [default: zeros(5,3)] if you wish to input MNI, change
    %                the option below.
    %
    %   Options:
    %       'coordinate_type': the type of input coordinates ( 1 (default) =
    %                          Talairach, 2 = MNI).
    %
    %       'search_spacing': how much mm in cube range you want to search
    %                         the area? [default: 5] (mm)
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       dependecies folder from shoeeg
    %
    %   References:
    %       Talairach Client: http://www.talairach.org/client.html
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %               base code obtained from MPT toolbox, headGrid.m,
    %               getBrodmannData
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
        input;
        coordinate_type;
        search_spacing;
        
        % for outputs
        brodmannAreas;
        gyrus;
        sorted_BAs;
        sorted_Gyrus;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_getBA(varargin)
            % add path to one of the files in dependencies
            addpath(which('icbm_spm2tal.m'));
            
            % input coordinates
            obj.input = get_varargin(varargin,'input',zeros(5,3));
            
            % ===== Other parameters  =====
            obj.coordinate_type = get_varargin(varargin,'coordinate_type',1);
            obj.search_spacing = get_varargin(varargin,'search_spacing',5);
            % =============================
            
            % initialization
            obj.brodmannAreas = {};
            obj.gyrus = {};
            obj.sorted_BAs = {};
            obj.sorted_Gyrus = {};
        end
    end
    
    methods
        % for processing to estimate the Brodmann areas and approximate
        % gyruses
        function process(obj)
            % add path to talairach client java
            javaaddpath(which('talairach.jar'));
            % load Talairach java object and data
            db = org.talairach.Database;
            db.load(which('talairach.nii'));
            % based on the input, convert to talairach coordinates
            if obj.coordinate_type == 1
                tal_xyz = obj.input;
            elseif obj.coordinate_type == 2
                tal_xyz = icbm_spm2tal(obj.input);
            end
            
            % loop through the labels to obtain the information
            for locationId = 1:size(tal_xyz,1)
                % initialize
                clearvars splitText areaNum potentialBAname areaGyrusRegion
                
                % for temporally holding area number
                tmpAreaNum = [];
                tmpGyrusRegion = {};
                
                labelsForLocation = db.search_range(tal_xyz(locationId,1),...
                    tal_xyz(locationId,2), tal_xyz(locationId,3), obj.search_spacing);
                
                for i = 1:length(labelsForLocation)
                    splitText = hlp_split(char(labelsForLocation(i)), ',');
                    potentialBAname = splitText{end};
                    
                    % if identified Brodmann area in the last segment, note
                    % down the information
                    if strfind(potentialBAname, 'Brodmann area')
                        areaNum = str2num(potentialBAname(length('Brodmann area '):end));
                        areaGyrusRegion = splitText{3};
                    end
                    
                    % if areaNum exists
                    if exist('areaNum')
                        tmpAreaNum = [tmpAreaNum,areaNum];
                        tmpGyrusRegion = [tmpGyrusRegion,areaGyrusRegion];
                    end
                end
                
                % if you couldn't find the Brodmann area, just get the
                % name of the first two Gyrus
                if exist('areaNum') == 0
                    for i = 1:2
                        splitText = hlp_split(char(labelsForLocation(i)),',');
                        areaGyrusRegion = splitText{3};
                        tmpGyrusRegion = [tmpGyrusRegion,areaGyrusRegion];
                    end
                end
                
                % sort identified BA number in order
                sortedAreaNum = sort(unique(tmpAreaNum));
                uniqueGyrus = unique(tmpGyrusRegion);
                
                % put the information in the cell array
                identified_BA{locationId,1} = sortedAreaNum;
                identified_Gyrus{locationId,1} = uniqueGyrus;
                
                % save the results into objects too
                obj.brodmannAreas = identified_BA;
                obj.gyrus = identified_Gyrus;
            end
        end
        
        % for sorting the output into a cell arry for later plotting
        function output = getSortedBA(obj, numclusts, tal_sorted)
            % initializations
            ba_idx = 0;
            ba_sorted = cell(numclusts,1);
            gyrus_sorted = cell(numclusts,1);
            % run through a loop to sort information
            for cl_idx = 1:numclusts
                temp = [];
                temp2 = [];
                if size(tal_sorted{cl_idx},1) == 2
                    ba_idx = ba_idx + 1;
                    % for BA
                    temp = [obj.brodmannAreas{ba_idx},obj.brodmannAreas{ba_idx+1}];
                    ba_sorted{cl_idx,1} = unique(temp);
                    % for Gyrus names
                    temp2 = [obj.gyrus{ba_idx},obj.gyrus{ba_idx+1}];
                    gyrus_sorted{cl_idx,1} = unique(temp2);
                    ba_idx = ba_idx + 1;
                elseif size(tal_sorted{cl_idx},1) == 1
                    ba_idx = ba_idx + 1;
                    % for BA
                    ba_sorted{cl_idx,1} = obj.brodmannAreas{ba_idx};
                    % for Gyrus names
                    temp2 = obj.gyrus{ba_idx};
                    gyrus_sorted{cl_idx,1} = unique(temp2);
                end
            end
            
            % save everything into the output
            output.sorted_BAs = ba_sorted;
            output.sorted_Gyrus = gyrus_sorted;
            
            % save them into the object too
            obj.sorted_BAs = ba_sorted;
            obj.sorted_Gyrus = gyrus_sorted;
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

