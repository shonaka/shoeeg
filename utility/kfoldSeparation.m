function [trainset, testset] = kfoldSeparation(data, varargin)
% Separates the data into trainset and testset
%   Usage:
%       % for simple 9 fold separation and assign the first to be testblock
%       [eegtrain, eegtest] = kfoldSeparation(eegdata, 'kfold', 9, 'testblock', 1);
%
%       % If you want to specify the datasize in each fold
%       [eegtrain, eegtest] = kfoldSeparation(eegdata, 'kfold', 9, 'testblock', 1, 'kfoldsize', array);
%
%   Inputs:
%       - data: data matrix to separate [observations x samples]
%
%       - kfold: specify the number of blocks to separate
%
%       - kfoldsize: give an array that contains data length if you
%                     wish to separate the data into specific length of segments
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
% check the input
for ind = 1:2:length(varargin)
    if strcmpi(varargin{ind}, 'kfold')
        kfold = varargin{ind+1};
    elseif strcmpi(varargin{ind}, 'testblock')
        testblock = varargin{ind+1};
    elseif strcmpi(varargin{ind}, 'kfoldsize')
        kfoldsize = varargin{ind+1};
    else
        warning('Unrecognizable argument.');
    end
end
% define values otherwise
if exist('kfoldsize') == 0
    kfoldsize = 0;
end
if exist('testblock') == 0
    testblock = 1;
end

% define information and preallocation
numsamp = size(data, 2);
div_numblock = zeros(1, kfold);
datablock = cell(1, kfold);

% separate into blocks
for ind = 1:kfold
    % kfold size not specified, so just divide the blocks equally
    if kfoldsize == 0
        div_numblock(ind) = floor(ind*Nsamples/kfold);
    else % otherwise divide accordingly
        div_numblock = cumsum(kfoldsize);
    end
    % acutally separate the data
    if ind == 1
        datablock{ind} = data(:, 1:div_numblock(ind));
    else
        datablock{ind} = data(:, div_numblock(ind-1)+1:div_numblock(ind));
    end
end

% assign test block from the separated data
testset = datablock{testblock};
trainset = [];

% make the rest to train set
datablock{testblock} = [];
trainset = cell2mat(datablock);

end

