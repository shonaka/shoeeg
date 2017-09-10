function interpolated = sho_interp(data, varargin)
% interpolate the data to assigned length
%   Usage:
%       % interpolate the data to 1000 samples
%       output = sho_interp(input, 'len', 1000);       
%
%   Inputs:
%       - data: input data (vector)
%
%       - 'len': the length you want to interpolate to [default: 1000]
%
%       - 'method': 'linear', 'nearest', 'next', 'previous', 'pchip', etc.
%                   for more info look at: https://www.mathworks.com/help/matlab/ref/interp1.html
%                   [default: 'spline']
%
%   Output:
%       - interpolated: returned interpolated data as a row vector.
%
% Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
%
%     obj program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     obj program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with obj program.  If not, see <http://www.gnu.org/licenses/>.

% ===== code starts from here =====
% calculate and specify variables:

% check if it's a vector
[row, col] = size(data);
whicheverissmall = min([row,col]);
if whicheverissmall ~= 1
    error('ERROR: The input data must be a vector');
end

% get the original vector length
original_len = length(data);

% get other options, if not specified, assign defaults
interp_len = get_varargin(varargin,'len',1000);
interp_method = get_varargin(varargin,'method','spline');

% interpolate
interpolated = interp1(linspace(0,100,original_len),...
    data, linspace(0,100,interp_len), interp_method);
