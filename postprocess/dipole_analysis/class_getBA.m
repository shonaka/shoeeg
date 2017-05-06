classdef class_getBA
    % for calculating the estimated Brodmann Area (BA)
    %   Usage:
    %       ba_obj = class_getBA('input',tal_coordinates);
    %       identified_ba = process(ba_obj);
    %
    %   Arguments:
    %       'input': input coordinates in Talairach (already converted
    %                from MNI coordinates [dimension: N x 3]
    %                [default: zeros(5,3)] if you wish to input MNI, change
    %                the option below.
    %
    %   Options:
    %       'type': the type of input coordinates ( 1 (default) =
    %       Talairach, 2 = MNI).
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
        xyzdata;
        coordinate_type;
        search_spacing;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_getBA(varargin)
            % add path to one of the files in dependencies
            addpath(which('icbm_spm2tal.m'));
            
            % input coordinates
            obj.xyzdata = get_varargin(varargin,'input',zeros(5,3));
            
            % ===== Other parameters  =====
            obj.coordinate_type = get_varargin(varargin,'coordinate_type',1);
            obj.search_spacing = get_varargin(varargin,'search_spacing',5);
            % =============================
        end
    end
    
    methods
        function identified_BA = process(obj)
            % add path to talairach client java
            javaaddpath(which('talairach.jar'));
            % load Talairach java object and data
            db = org.talairach.Database;
            db.load(which('talairach.nii'));
            % based on the input, convert to talairach coordinates
            if obj.coordinate_type == 1
                tal_xyz = obj.xyzdata;
            elseif obj.coordinate_type == 2
                tal_xyz = icbm_spm2tal(obj.xyzdata);
            end
            
            % preallocate cell array containing BA info
            identified_BA{size(tal_xyz,1),1} = [];
            
            % loop through the labels to obtain the information
            for locationId = 1:size(tal_xyz,1)
                % for temporally holding area number
                tmpAreaNum = [];
                
                labelsForLocation = db.search_range(tal_xyz(locationId,1),...
                    tal_xyz(locationId,2), tal_xyz(locationId,3), obj.search_spacing);
                
                for i = 1:length(labelsForLocation)
                    splitText = hlp_split(char(labelsForLocation(i)), ',');
                    potentialBAname = splitText{end};
                    
                    % if identified Brodmann area in the last segment, note
                    % down the information
                    if strfind(potentialBAname, 'Brodmann area')
                        areaNum = str2num(potentialBAname(length('Brodmann area '):end));
                    end
                    
                    % if areaNum exists
                    if exist('areaNum')
                        tmpAreaNum = [tmpAreaNum,areaNum];
                    end
                end
                
                % sort identified BA number in order
                sortedAreaNum = sort(unique(tmpAreaNum));
                
                % put the information in the cell array
                identified_BA{locationId} = sortedAreaNum;
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

