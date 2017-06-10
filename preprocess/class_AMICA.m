classdef class_AMICA < handle
    % for running AMICA
    %   Usage:
    %       % try reducing maxiter if there's an error
    %       amica_obj = class_AMICA('input',EEG,'maxiter',1000);
    %       process(amica_obj);
    %       % extract processed EEG from object
    %       EEG = amica_obj.postEEG;
    %
    %   Arguments:
    %       'input': EEG structure from EEGLAB (required)
    %
    %   Options:
    %       'M': number of ICA mixture models [default: 1]
    %       'm': number of source density mixtures [default: 3]
    %       'maxiter': maximum number of iterations [default: 1000]
    %       'do_sphere': 1 = remove mean and sphere data [default]
    %                    2 = only remove mean and normalize channels
    %                    0 = do not remove mean or do sphere
    %       'do_newton': 1 = use newton update [default]
    %                    0 = use natural gradient updates
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       AMICA: https://sccn.ucsd.edu/~jason/amica_web.html
    %
    %   For more detail, read the paper:
    %       Palmer, Jason A., Ken Kreutz-Delgado, and Scott Makeig.
    %       "AMICA: An adaptive mixture of independent component analyzers
    %       with shared components."
    %       Swartz Center for Computatonal Neursoscience,
    %       University of California San Diego, Tech. Rep (2012).
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %               amica10 written by Jason Palmer
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
        preEEG; % before AMICA
        
        % for AMICA parameters
        M;
        m;
        maxiter;
        do_sphere;
        do_newton;
        
        % for outputEEG
        postEEG;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_AMICA(varargin)
            % add path to dependencies
            sep = filesep;
            addpath(which('dependencies'));
			
            % make sure to addpath to eeglab as well
            
            % input EEG (before AMICA)
            obj.preEEG = get_varargin(varargin,'input',eeg_emptyset());
            
            % copy input to the output
            obj.postEEG = obj.preEEG;
            
            % other parameters for AMICA
            obj.M = get_varargin(varargin,'M',1);
            obj.m = get_varargin(varargin,'m',3);
            obj.maxiter = get_varargin(varargin,'maxiter',1000);
            obj.do_sphere = get_varargin(varargin,'do_sphere',1);
            obj.do_newton = get_varargin(varargin,'do_newton',1);
        end
    end
    
    methods
        function process(obj)
            % for checking purposes
            fprintf('Start running AMICA...\n');
            warning('Make sure you compensate for the rank deficiency in the previous processes.');
            warning('Otherwise, it will most likely produce an error: LL = NaN');
            % Run AMICA with the options
            [A,W,S,khinds,c,LL,Ltall,gm,alpha,mu,beta,rho] = ...
                amica10(obj.preEEG.data,...
                obj.M,...
                obj.m,...
                obj.maxiter,...
                obj.do_sphere,...
                obj.do_newton);
            
            % put the results back into the structure
            obj.postEEG.icaweights = W;
            obj.postEEG.icasphere  = S;
            obj.postEEG = eeg_checkset(obj.postEEG, 'ica');
            % add note on processing steps
            if isfield(obj.postEEG,'process_step') == 0
                obj.postEEG.process_step = [];
                obj.postEEG.process_step{1} = 'AMICA';
            else
                obj.postEEG.process_step{end+1} = 'AMICA';
            end
            try
                obj.postEEG.setname = [obj.postEEG.setname,'_AMICA'];
            catch e
            end
            
            % for checking purposes
            fprintf('Finished running AMICA.\n');
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

