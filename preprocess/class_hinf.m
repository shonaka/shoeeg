function output = class_hinf(eegdata, eogdata, qhinf, gamma)
% ===== H-infinity filter using cpu =====
% If you have any questions, send an email to Sho Nakagome
% (email: snakagome@uh.edu)
%
% Make sure that you have a CUDA enabled GPU from NVIDIA
% for more information:
% https://www.mathworks.com/discovery/matlab-gpu.html
%
% Input:
% - EEG: eeg data (channel x samples)
% - EOG: eog data (channel x samples)
%        1st row: Up (In avatar 17, moved from FT9)
%        2nd row: Down (In avatar 22, moved from FT10)
%        3rd row: Left (In avatar 41, moved from TP9)
%        4th row: Right (In avatar 46, moved from TP10)
% - qhinf: deviation factor from gamma <= 1 condition for time varying hinf
% weight estimation problem (1e-10)
% - gamma: supression control (1 - 2 maybe 1.15 is good or 2 for avatar)
%
% Example:
%   hinfEEG = class_hinf(EEG.data, eogdata, 1e-10, 2);
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

%% Preprocess
EEGwoEOG = eegdata;
% get the size of a matrix
[numch, numsamp] = size(EEGwoEOG);

% make sure to convert into double before putting in
EEGwoEOG = double(EEGwoEOG);

% Calcuate the EOG vector for H-infinity
eogUD = eogdata(1, :) - eogdata(2, :);
eogLR = eogdata(3, :) - eogdata(4, :);
eogRef = [eogUD; eogLR; zeros(1, length(eogUD))];

% make sure to convert into double before putting in
eogRef = double(eogRef);

% transpose so that it's number of samples and channels
EEGwoEOG = EEGwoEOG';
eogRef = eogRef';

% Hinf algorithm
Pt = repmat({0.5*eye(3)}, 1, numch);
wh = zeros(3, numch);
shsh = zeros(size(EEGwoEOG));
parfor m = 1:size(EEGwoEOG, 2)
    sh = zeros(size(eogRef, 1),1);
    for n = 1:size(eogRef, 1)
        y = EEGwoEOG(n, m);
        r = eogRef(n, :)';        
        P = inv(  inv(Pt{m}) - (gamma^(-2))*(r*r')  );        
        g = (P*r)/(1+r'*P*r);
        zh = r'*wh(:, m);
        sh(n) = y-zh;   
        wh(:, m) = wh(:, m) + g*sh(n);
        Pt{m} = inv (  (inv(Pt{m})) + ((1-gamma^(-2))*(r*r')) ) + qhinf*eye(size(eogRef, 2));        
    end
    shsh(:, m) = sh;
end
shsh = shsh';

% Gather the results
output = shsh;
