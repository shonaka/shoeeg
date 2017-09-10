function markercells = significant_marker(p_value)
% get p-value and convert them to signficance markers
%   Arguments:
%       - p_value: p-value array matrix

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

%% Load data
% get dimensions
[p_row, p_col] = size(p_value);
% initialize the output
markercells = cell(p_row, p_col);

% based on the p-value, assign asterisk markers
%   p < 0.05 = '*';
%   p < 0.01 = '**';
%   p < 0.001 = '***';
%   p > 0.05 = ''; % nothing, no significance
for row_idx = 1:p_row
    for col_idx = 1:p_col
        % default
        markercells{row_idx,col_idx} = '';
        % overwrite
        if p_value(row_idx,col_idx) < 0.05
            markercells{row_idx,col_idx} = '*';
        end
        % overwrite
        if p_value(row_idx,col_idx) < 0.01
            markercells{row_idx,col_idx} = '**';
        end
        % overwrite
        if p_value(row_idx,col_idx) < 0.001
            markercells{row_idx,col_idx} = '***';
        end
    end
end