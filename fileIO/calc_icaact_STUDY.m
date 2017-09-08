function ALLEEGout = calc_icaact_STUDY(ALLEEG)
% calculate icaact on each component under STUDY, ALLEEG
%   Arguments:
%       - ALLEEG: EEG structure created when creating STUDY structure

% Copyright (C) 2017 Sho Nakagome (snakgome@uh.edu)
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

%% Extract necessary info to perform the task
% separator used in your OS
sep = filesep;
% total number of data
totdata = length(ALLEEG);

% for each data, load the EEG data to get the actual EEG data, then use
% icaweights and icasphere to calculate the icaact
for data_idx = 1:totdata
    % initialize
    tempEEG = [];
    % load the data
    tempEEG = pop_loadset([ALLEEG(data_idx).filepath,...
        sep,ALLEEG(data_idx).filename]);
    % calculate the icaact
    ALLEEG(data_idx).icaact = ...
        (ALLEEG(data_idx).icaweights*ALLEEG(data_idx).icasphere)*...
        tempEEG.data;
end

% export the structure to the output
ALLEEGout = ALLEEG;
