function output = sho_pmtm(data,varargin)
% customized function of pmtm
%   Usage:
%       psdoutput = sho_pmtm(data);
%
%   Arguments:
%       'data': data matrix
%
%   Options:
%       pmtm parameters:
%           'nw': time-halfbandwidth product [default: 4]
%
%           'nfft': nfft points in the discrete fourier transform
%                   [default: 256]
%
%           'fs': sampling frequency [default: 100 (Hz)]
%
%
%       bandpower options:
%           bandpower frequency range:
%               'delta': default [0.1, 3]
%               'theta': default [4,8]
%               'alpha': default [8,12]
%               'beta': default [15,30]
%               'lgamma': default [30,50]
%
%   Pre-requisites:
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


%% ========================================================================

% Get the inputs and modify it if necessary
[rows, cols] = size(data);
% assuming that the number of channels are smaller than the number of time
% samples, make the matrix time samples x channels for pmtm input
if rows < cols
    warning('Assuming the number of channels is smaller than that of time samples, transposing the data.');
    data = data';
    numchan = rows;
    samples = cols;
else
    % do nothing because the input was already samples x channels
    numchan = cols;
    samples = rows;
end


% Get other options, if not specified, assign the default options
nw = get_varargin(varargin,'nw',4);
nfft = get_varargin(varargin,'nfft',2^nextpow2(samples));
fs = get_varargin(varargin,'fs',100);

% power range
delta = get_varargin(varargin,'delta',[0.1,3]);
theta = get_varargin(varargin,'theta',[4,8]);
alpha = get_varargin(varargin,'alpha',[8,12]);
beta = get_varargin(varargin,'beta',[15,30]);
lgamma = get_varargin(varargin,'lgamma',[30,50]);


% Calculate the power spectrum
fprintf('Start calculating the psds.\n');
[pxx,f] = pmtm(data,nw,nfft,fs);
fprintf('Finished calculating psds.\n');

% Calculate the bandpowers
fprintf('Start calculating the bandpowers.\n');
deltaP = zeros(numchan,1);
thetaP = zeros(numchan,1);
alphaP = zeros(numchan,1);
betaP = zeros(numchan,1);
lgammaP = zeros(numchan,1);
for ch = 1:numchan
    deltaP(ch,1) = bandpower(pxx(:,ch),f,delta,'psd');
    thetaP(ch,1) = bandpower(pxx(:,ch),f,theta,'psd');
    alphaP(ch,1) = bandpower(pxx(:,ch),f,alpha,'psd');
    betaP(ch,1) = bandpower(pxx(:,ch),f,beta,'psd');
    lgammaP(ch,1) = bandpower(pxx(:,ch),f,lgamma,'psd');
end

% calculate bandpowers in dB (10*log10)
delta_db = zeros(numchan,1);
theta_db = zeros(numchan,1);
alpha_db = zeros(numchan,1);
beta_db = zeros(numchan,1);
lgamma_db = zeros(numchan,1);
for ch = 1:numchan
    delta_db(ch,1) = 10*log10(deltaP(ch,1));
    theta_db(ch,1) = 10*log10(thetaP(ch,1));
    alpha_db(ch,1) = 10*log10(alphaP(ch,1));
    beta_db(ch,1) = 10*log10(betaP(ch,1));
    lgamma_db(ch,1) = 10*log10(lgammaP(ch,1));
end
fprintf('Finished calculating the bandpowers.\n');

% write everything into the output
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
