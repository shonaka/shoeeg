function output = cuda_hinf(EEG, EOG, qhinf, gamma)
% ===== H-infinity filter using cuda =====
% If you have any questions, send an email to Sho Nakagome
% (email: snakagome@uh.edu)
%
% Make sure that you have a CUDA enabled GPU from NVIDIA
% for more information:
% https://www.mathworks.com/discovery/matlab-gpu.html
%
% Input:
% - EEG: EEG data in a matrix (channels x samples)
% - EOG: which channels are EOG? (In Avatar project, 17, 22, 41, 46)
% - qhinf: deviation factor from gamma <= 1 condition for time varying hinf
% weight estimation problem (1e-10)
% - gamma: supression control (1 - 2 maybe 1.15 is good or 2 for avatar)
%
% Example:
%   hinfEEG = cuda_hinf(EEG, [17,22,41,46], 1e-10, 2);
% ===============================

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

% include ptx and cuda directory
addpath('./ptx_cuda_files');

%% Separate EEG and EOG
% Remove EOG channels from EEG
EEGwoEOG = EEG;
EEGwoEOG(EOG, :) = [];
% get the size of a matrix
[M, N] = size(EEGwoEOG);
% put it into a gpuArray
gpu_EEG = gpuArray(EEGwoEOG);

% Calcuate the EOG vector for H=infinity
eogUD = EEG(EOG(1), :) - EEG(EOG(2), :);
eogLR = EEG(EOG(3), :) - EEG(EOG(4), :);
eogRef = [eogUD; eogLR; zeros(1, length(eogUD))];
% put it into a gpuArray
gpu_EOG = gpuArray(eogRef);

% create other necessary matrix
sh_hinf = zeros(M, N);
% put it into a gpuArray
gpu_sh_hinf = gpuArray(sh_hinf);

% predefine the output gpuArray
pre_out = zeros(M, N);
gpu_out = gpuArray(pre_out);

% create a hinfinity kernel in MATLAB
k = parallel.gpu.CUDAKernel('cuda_hinf.ptx', 'cuda_hinf.cu');

% set object properties
k.GridSize = [1 1];
k.ThreadBlockSize = [M 1];

% Run the kernel
result = feval(k, gpu_out, gpu_EEG, gpu_EOG, gpu_sh_hinf, M, N, qhinf, gamma);

% Gather the results
output = gather(result);
