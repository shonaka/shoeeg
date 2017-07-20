classdef class_detectNoisy
    % for detecting noisy sections based on two thresholds
    %   Usage:
    %       noisy_obj =
    %       class_detectNoisy('data',dataMat,'threshold_amp',10000,...
    %                         'threshold_samp',40,'which_channel',1);
    %       process(noisy_obj);
    %       visualize(noisy_obj);
    %
    %   Arguments:
    %       'data': data matrix (channel x time samples)
    %
    %   Options:
    %       'threshold_amp': threshold for the amplitude. If the signal
    %                        overpass this value, it is detected as pre-noisy
    %                        [default: 5000]
    %
    %       'threshold_samp': threshold for the consecutive number of
    %                         samples. If the non-detected noisy sections in
    %                         the above threshold_amp were sandwiched by the
    %                         noisy sections for a consecutive number of
    %                         samples, detect those sections as noisy too.
    %                         For example, If the above threshold_amp
    %                         gave a sequence of 0, 0, 1, 0, 1, 0, 0, 0, 1
    %                         and your threhsold_samp was 1, then the
    %                         resulting sequency will be
    %                         0, 0, 1, 1, 1, 0, 0, 0, 1 assuming that 1
    %                         zero sandwiched by the ones are also noisy.
    %                         [default: 30]
    %
    %       'which_channel': for visualizing the result, which channel to
    %                        plot. [default: 1]
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
        data;
        threshold_amp;
        threshold_samp;
        which_channel;
        results;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_detectNoisy(varargin)
            % input data
            obj.data = get_varargin(varargin,'data',randn(60,2500)*5000);
            
            % ===== Other parameters for this class =====
            obj.threshold_amp = get_varargin(varargin,'threshold_amp',5000);
            obj.threshold_samp = get_varargin(varargin,'threshold_samp',30);
            obj.which_channel = get_varargin(varargin,'which_channel',1);
            % ===========================================
            
            % pre-allocate the results matrix
            obj.results = zeros(size(data));
        end
    end
    
    methods
        function process(obj)
            % number of channels
            numchan = size(obj.data,1);
            % initialize matrix
            pre_detected = zeros(size(obj.data));
            % run for all the channels
            for ch = 1:numchan
                pre_detected(ch,:) = (abs(obj.data(ch,:)) > obj.threshold_amp);
            end
            % use the pre-detected results and run sample by sample to
            % detect sandwiched zeros
            for ch = 1:numchan
                % counting variables
                zero_count = 0;
                % flags
                zero_one_flag = 0;
                one_zero_flag = 0;
                % go through sample by sample
                for sample = 1:length(pre_detected(ch,:))
                    % counting ones and zeros
                    if pre_detected(ch,sample) == 1
                        % no need to count one
                    elseif pre_detected(ch,sample) == 0
                        zero_count = zero_count + 1;
                    end
                    
                    % detecting changing 1 and 0 (e.g. 0->1 or 1->0)
                    if (sample > 1) && (pre_detected(ch,sample) == 1) ...
                            && (pre_detected(ch,sample-1) == 0) ...
                            && (one_zero_flag == 1)
                        % 0 -> 1
                        zero_one_flag = 1;
                        % then we are sandwiching zeros so if they are less than a threshold
                        % convert them into ones (e.g. 1, 0, 0, 0, 0, 1)
                        if zero_count < obj.threshold_samp + 1
                            pre_detected(ch, sample - zero_count - 1 : sample) = 1;
                            zero_count = 0;
                            zero_one_flag = 0;
                            try
                                if pre_detected(ch,sample+1) == 1
                                    one_zero_flag = 0;
                                end
                            catch e
                            end
                        else
                            % zero_count was larger than the sample_threshold
                            one_zero_flag = 0;
                            zero_one_flag = 0;
                        end
                    elseif (sample > 1) && (pre_detected(ch,sample) == 0) ...
                            && (pre_detected(ch,sample-1) == 1)
                        % 1 -> 0
                        one_zero_flag = 1;
                    else
                        % 1 -> 1 or 0 -> 0
                    end
                    
                    % zero count has to be consecutive
                    % but deal with the above condition first so that you don't miss
                    % the sandwich zeros
                    if (zero_one_flag == 0) && (one_zero_flag == 0) && ...
                            (pre_detected(ch,sample) == 1)
                        zero_count = 0;
                    end
                end
                
                % store the outcome in to results properties
                obj.results = pre_detected;
            end
        end
        
        function visualize(obj)
            figure;
            % original data
            plot(obj.data(obj.which_channel,:));
            hold on;
            % outcome
            plot(obj.results(obj.which_channel,:));
            % legend
            legend('Original','Detected as noisy');
            legend boxoff
        end
    end
    
end

