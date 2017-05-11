classdef class_MPA
    % for performing measure projection analysis (MPA)
    %   Usage:
    %       mpa_obj = class_MPA('STUDY',STUDY,'ALLEEG',ALLEEG);
    %       mpa_obj = process(mpa_obj); % for creating different domains
    %       mpa_obj = getBA(mpa_obj); % for getting Brodmann Areas
    %
    %   Arguments:
    %       'STUDY': STUDY structure made before running this (required)
    %       'ALLEEG': ALLEEG structure made at the same time as STUDY
    %       (To get the above two, [STUDY, ALLEEG] = pop_loadstudy();)
    %       !!! MAKE SURE all the measures you want to use are precomputed
    %       using std_precomp(); !!!
    %
    %   Options (for more info go to reference at the bottom):
    %       'measure': which measurement you want to use to calculate MP.
    %                  [default: 'ersp'] (other options: 'erp', 'itc', etc)
    %
    %       'pval': Significance p-value threshold you want to use for
    %               plotting domains [default: 0.01] (0.01 - 0.001)
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       MPT: https://sccn.ucsd.edu/wiki/MPT
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %               2014 Nima Bidgely-Shamlo (original program: MPT)
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
        
        % other input options
        measure;
        pval;
        
        % for outputs
        usedOptions;
        significance_level;
        maxDomainExemplar_correlation;
        num_domain;
        dipoleAndMeasures;
        domains;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_MPA(varargin)
            % add path to the custom function you made
            addpath(which('default_properties.m'));
            
            % input STUDY
            obj.STUDY = get_varargin(varargin,'STUDY',[]);
            % input ALLEEG
            obj.ALLEEG = get_varargin(varargin,'ALLEEG',[]);
            
            % check errors (need the above inputs)
            [obj.STUDY, obj.ALLEEG] = ...
                std_checkset(obj.STUDY, obj.ALLEEG);
            
            % ===== Other parameters for Dipole Density =====
            obj.measure = get_varargin(varargin,'measure','ersp');
            obj.pval = get_varargin(varargin,'pval',0.01);
            % ===============================================
            
            % read the data from STUDY and ALLEEG
            % make sure you have these from [STUDY,ALLEEG] =
            % pop_loadstudy();
            if strcmpi(obj.measure,'ersp')
                obj.STUDY.measureProjection.(obj.measure).object = ...
                    pr.dipoleAndMeasureOfStudyErsp(obj.STUDY, obj.ALLEEG);
            elseif strcmpi(obj.measure,'erp')
                obj.STUDY.measureProjection.(obj.measure).object = ...
                    pr.dipoleAndMeasureOfStudyErp(obj.STUDY, obj.ALLEEG);
            elseif strcmpi(obj.measure,'custom')
                obj.STUDY.measureProjection.(obj.measure).object = ...
                    pr.dipoleAndMeasureOfStudyCustom(obj.STUDY, obj.ALLEEG);
            elseif strcmpi(obj.measure,'itc')
                obj.STUDY.measureProjection.(obj.measure).object = ...
                    pr.dipoleAndMeasureOfStudyItc(obj.STUDY, obj.ALLEEG);
            elseif strcmpi(obj.measure,'sift')
                obj.STUDY.measureProjection.(obj.measure).object = ...
                    pr.dipoleAndMeasureOfStudySIFT(obj.STUDY, obj.ALLEEG);
            elseif strcmpi(obj.measure,'spec')
                obj.STUDY.measureProjection.(obj.measure).object = ...
                    pr.dipoleAndMeasureOfStudySpec(obj.STUDY, obj.ALLEEG);
            end
            
            % get extracted default properties
            default_properties;
            obj.STUDY.measureProjection.option = guiOptionValue;
            
            % define HeadGRID
            obj.STUDY.measureProjection.(obj.measure).headGrid = ...
                pr.headGrid(obj.STUDY.measureProjection.option.headGridSpacing);
            
            % do the actual projection
            obj.STUDY.measureProjection.(obj.measure).projection = ...
                pr.meanProjection(obj.STUDY.measureProjection.(obj.measure).object,...
                obj.STUDY.measureProjection.(obj.measure).object.getPairwiseMutualInformationSimilarity, ...
                obj.STUDY.measureProjection.(obj.measure).headGrid, 'numberOfPermutations', ...
                obj.STUDY.measureProjection.option.numberOfPermutations, 'stdOfDipoleGaussian',...
                obj.STUDY.measureProjection.option.standardDeviationOfEstimatedDipoleLocation,...
                'numberOfStdsToTruncateGaussian',...
                obj.STUDY.measureProjection.option.numberOfStandardDeviationsToTruncatedGaussaian, ...
                'normalizeInBrainDipoleDenisty', ...
                fastif(obj.STUDY.measureProjection.option.normalizeInBrainDipoleDenisty,'on','off'));
            
            % for checking purpose
            obj.STUDY.measureProjection.(obj.measure).projection.plotVolume(obj.pval);
        end
    end
    
    methods
        % if you just want to run normally
        function obj = process(obj)
            % depending on your measure, change the function you use
            low_measure = lower(obj.measure);
            fdrcoopt = [low_measure,'FdrCorrection'];
            signifiopt = [low_measure,'Significance'];
            maxcoopt = [low_measure,'MaxCorrelation'];
            obj.usedOptions.fdrcorrection = fdrcoopt;
            obj.usedOptions.significance = signifiopt;
            obj.usedOptions.maxcorrelation = maxcoopt;
            
            % find out the significance level to use (e.g. corrected by FDR)
            if obj.STUDY.measureProjection.option.(fdrcoopt)
                significanceLevel = fdr(obj.STUDY.measureProjection.(obj.measure).projection.convergenceSignificance(...
                    obj.STUDY.measureProjection.(obj.measure).headGrid.insideBrainCube(:)), ...
                    obj.STUDY.measureProjection.option.([signifiopt]));
            else
                significanceLevel = obj.STUDY.measureProjection.option.(signifiopt);
            end
            maxDomainExemplarCorrelation = obj.STUDY.measureProjection.option.(maxcoopt);
            % put them into outputs
            obj.significance_level = significanceLevel;
            obj.maxDomainExemplar_correlation = maxDomainExemplarCorrelation;
            
            % the command below makes the domains using parameters significanceLevel and maxDomainExemplarCorrelation:
            obj.STUDY.measureProjection.(obj.measure).projection = ...
                obj.STUDY.measureProjection.(obj.measure).projection.createDomain(...
                obj.STUDY.measureProjection.(obj.measure).object, ...
                maxDomainExemplarCorrelation, significanceLevel);
            
            % visualize domains (change 'voxle' to 'volume' for a different type of visualization)
            obj.STUDY.measureProjection.(obj.measure).projection.plotVolumeColoredByDomain;
        end
        
        % if you want to plot slices only
        function obj = getBA(obj)
            % get number of domains
            numdomain = ...
                length(obj.STUDY.measureProjection.(obj.measure).projection.domain);
            obj.num_domain = numdomain;
            
            for domainNumber = 1:numdomain
                % get the ERSP and dipole data (dataAndMeasure object) from the STUDY structure.
                dipoleAndMeasure = obj.STUDY.measureProjection.(obj.measure).object;
                % get the domain in a separate variable
                domain = obj.STUDY.measureProjection.(obj.measure).projection.domain(domainNumber);
                % print out the domains and their descriptions
                describe(domain)
                % put them into outputs
                obj.dipoleAndMeasures{domainNumber} = dipoleAndMeasure;
                obj.domains{domainNumber} = domain;
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

