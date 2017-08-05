function decision = checkEEGLABstruct( input )
% checkEEGLABstruct.m check whether the input is EEGLAB structure or not
%   A function to check whether the input is EEGLAB structure or not


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


% Some variables to decide whether the input is EEGLAB structure or not
% 1 = it is EEGLAB structure, 0 = it is NOT EEGLAB structure
isEEGLABstruct = 0;
flag = zeros(7,1);

% first it has to be a structure
if isstruct(input)
    % then check some fields
    flag(1,1) = isfield(input,'setname');
    flag(2,1) = isfield(input,'data');
    flag(3,1) = isfield(input,'nbchan');
    flag(4,1) = isfield(input,'comments');
    flag(5,1) = isfield(input,'filename');
    flag(6,1) = isfield(input,'filepath');
    flag(7,1) = isfield(input,'srate');
    % if any of them is zero, then it's not the EEGLAB structure
    if min(flag) == 0
        isEEGLABstruct = 0;
    else
        isEEGLABstruct = 1;
    end
else
    % if not a structure, then it's not
    isEEGLABstruct = 0;
end

% output
decision = isEEGLABstruct;

end

