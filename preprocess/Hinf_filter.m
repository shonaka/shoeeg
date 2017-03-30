function shsh = Hinf_filter(eegin,varargin)
%eegin = uh_tocolumn(eegin);
%EOGch = get_varargin(varargin,'EOG',[17 22 41 46]); % above, below, left, right;
%EOGch = [17,22,41,46]; % Avatar
EOGch = [28,32,17,22]; % Neuroleg
Yf = eegin;
Yf(:,EOGch) = []; % Remove EOG channel
eogUD = eegin(:,EOGch(1)) - eegin(:,EOGch(2));
eogLR = eegin(:,EOGch(3)) - eegin(:,EOGch(4));
Rf = [eogUD, eogLR, ones(length(eogUD),1)];
refch = size(Rf,2); % 3;
% Get input from varargin
%gamma = get_varargin(varargin,'gamma',2);  % Controls supression.  1.05:.05:1.50 all ok.  1.15 seems best 
%q = get_varargin(varargin,'q',1e-10); %deviation factor from gamma<=1 condition for time varying hinfinity weight estimation problem s.t. gamma^2<=1+q*ref_bar 
gamma = 2;
q = 1e-10;
% convert to column
[Nsamples, eegch] = size(Yf);
Pt = repmat({0.5*eye(refch)},1,eegch); % 3x3 matrix. Must be a cell array of 3x3 matrices for parallel!
wh    = zeros(3,eegch);               % Initialize weights matrix
shsh=zeros(size(Yf));
for m=1:size(Yf,2)            %--> iteration over channels
    sh = zeros(size(Rf,1),1);
    for n=1:size(Rf,1)   %--> iteration over samples
        %get sample per channel (eeg+noise2 and noise1)   noise2 is the reflection of noise1 onto that channel
        y = Yf(n,m);  
        r = Rf(n,:)';        
        % calculate filter gains
        P = inv(  inv(Pt{m}) - (gamma^(-2))*(r*r')  );        
        g = (P*r)/(1+r'*P*r);
        % identify noise 2
        zh = r'*wh(:,m);
        % calculate the error, this is also the clean eeg
        sh(n) = y-zh;   
        % update filter weights
        wh(:,m) = wh(:,m) + g*sh(n);
        % update noise covariance matrix
        Pt{m} = inv (  (inv(Pt{m})) + ((1-gamma^(-2))*(r*r')) ) + q*eye(size(Rf,2));        
    end 
    shsh(:,m) = sh;
end
shsh = shsh';