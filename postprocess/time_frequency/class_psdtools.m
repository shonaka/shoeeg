classdef class_psdtools
    % for calculating psds and some other related stuff
    %   Usage:
    %       psd_obj = class_psdtools('input',data,'method','pmtm');
    %       output = process(psd_obj);
    %
    %   Arguments:
    %       'input': data matrix (channel x samples)
    %
    %   Options:
    %       'method': 'pmtm' or 'pwelch' [default: 'pmtm']
    %
    %       'nw': time halfbandwidth product [default: 4]
    %
    %       'freq': defines frequency resolution [default: 0:.1:Fs/2] where
    %               Fs/2 is the nyquist frequency
    %
    %       'delta': frequency range for delta power [default: [0.1,3]]
    %
    %       'theta': frequency range for theta [default: [4,8]]
    %
    %       'alpha': frequency range for alpha [default: [8,12]]
    %
    %       'beta': frequency range for beta [default: [15,30]]
    %
    %       'lgamma': frequency range for low gamma [default: [30,50]]
    %
    %   Pre-requisites:
    %       EEGLAB: https://sccn.ucsd.edu/eeglab/
    %       Signal Processing Toolbox
    %
    
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
        % for input
        input;
        
        % choosing methods
        method;
        
        % for pmtm
        nw;
        freq;
        
        % for calculating powers
        delta;
        theta;
        alpha;
        beta;
        lgamma;
        
        % used for calculation
        nbchan;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_psdtools(varargin)
            % input data
            obj.input = get_varargin(varargin,'input',randn(64,2000));
            obj.nbchan = size(obj.input,1);
            
            % ===== Other parameters (methods) =====
            obj.method = get_varargin(varargin,'method','pmtm');
            % ======================================
            
            % ===== Parameters for pmtm =====
            obj.nw = get_varargin(varargin,'nw',4);
            obj.freq = get_varargin(varargin,'freq',0:0.1:obj.input.srate/2);
            % ===============================
            
            % ===== Parameters for calculating powers =====
            obj.delta = get_varargin(varargin,'delta',[0.1,3]);
            obj.theta = get_varargin(varargin,'theta',[4,8]);
            obj.alpha = get_varargin(varargin,'alpha',[8,12]);
            obj.beta = get_varargin(varargin,'beta',[15,30]);
            obj.lgamma = get_varargin(varargin,'lgamma',[30,50]);
            % =============================================
        end
    end
    
    methods
        function output = process(obj)
            % for checking purposes
            fprintf('Calculating psds ... \n');
            
            % calculate psds using pmtm or pwelch
            if strcmpi(obj.method,'pmtm')
                % initialize
                pxx{obj.nbchan,1} = [];
                f{obj.nbchan,1} = [];
                % for each channel
                parfor ch = 1:obj.nbchan
                    [pxx{ch,1},f{ch,1}] = ...
                        pmtm(obj.input(ch,:),obj.nw,obj.freq,obj.input.srate);
                end
            elseif strcmpi(obj.method,'pwelch')
                warning('Still building, coming soon');
            end
            
            % for checking purposes
            fprintf('Finished calculating psds.\n');
            fprintf('Start calculating bandpowers in each frequency bands.\n');
            
            % calculate bandpowers
            % initialize the outputs
            deltaP = zeros(obj.nbchan,1);
            thetaP = zeros(obj.nbchan,1);
            alphaP = zeros(obj.nbchan,1);
            betaP = zeros(obj.nbchan,1);
            lgammaP = zeros(obj.nbchan,1);
            for ch = 1:obj.nbchan
                deltaP(ch,1) = bandpower(pxx{ch,1},f{ch,1},obj.delta,'psd');
                thetaP(ch,1) = bandpower(pxx{ch,1},f{ch,1},obj.theta,'psd');
                alphaP(ch,1) = bandpower(pxx{ch,1},f{ch,1},obj.alpha,'psd');
                betaP(ch,1) = bandpower(pxx{ch,1},f{ch,1},obj.beta,'psd');
                lgammaP(ch,1) = bandpower(pxx{ch,1},f{ch,1},obj.lgamma,'psd');
            end
            
            % calculate bandpowers in dB (10*log10)
            delta_db = zeros(obj.nbchan,1);
            theta_db = zeros(obj.nbchan,1);
            alpha_db = zeros(obj.nbchan,1);
            beta_db = zeros(obj.nbchan,1);
            lgamma_db = zeros(obj.nbchan,1);
            for ch = 1:obj.nbchan
                delta_db(ch,1) = 10*log10(deltaP(ch,1));
                theta_db(ch,1) = 10*log10(thetaP(ch,1));
                alpha_db(ch,1) = 10*log10(alphaP(ch,1));
                beta_db(ch,1) = 10*log10(betaP(ch,1));
                lgamma_db(ch,1) = 10*log10(lgammaP(ch,1));
            end
            
            % for checking purposes
            fprintf('Finished calculating bandpowers.\n');
            fprintf('Writing into output structure.\n');
            
            % write everything into the output
            output = struct();
            output.pxx = pxx;
            output.f = f;
            output.pow.delta = deltaP;
            output.pow.theta = thetaP;
            output.pow.alpha = alphaP;
            output.pow.beta = betaP;
            output.pow.lgamma = lgammaP;
            output.powdb.delta = delta_db;
            output.powdb.theta = theta_db;
            output.powdb.alpha = alpha_db;
            output.powdb.beta = beta_db;
            output.powdb.lgamma = lgamma_db;
            
            fprintf('Finished writing into output.\n');
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

