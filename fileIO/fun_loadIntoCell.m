%% Function to load bunch of data into a cell array
function out_cell_array =...
    fun_loadIntoCell(loc, subtot, numses, sep, usearr, howmanyeach)

% load .mat files into a cell array in a sorted form
%
% input variables:
%   - loc: the location where all .mat files are
%   - subtot: how many subjects are there to process
%   - numses: how many sessions does each subject have
%   - sep: separator -> '-' or '_' or '.' ?
%   - usearr: which part of the name of the file you want to use
%       if you want to use SL01-T01-eeg out of SL01-T01-16-06-21-eeg.mat,
%       when separated with a separator '-', the name is going to be
%       ['SL01','T01','16','06','21','eeg']
%       therefore, if you want to use SL01_T01_eeg as a name,
%       the array you have to give is [1,2,6] each corresponds to
%       1 = 'SL01', 2 = 'T01', 6 = 'eeg'
%   - howmanyeach: how many trials does each subject has?
%       e.g. [10, 11, 9, 9, 9, 10];
%
% example:
%   if the data are like SL01-T01-16-06-21-eeg.mat
%   each of the data in a cell array is going to be SL01, SL02,... etc.

% move to the folder where data are stored
cd(loc);

% Load data
files = dir('*.mat');
count = 1;
onetime = ones(1,subtot);
fixed_count = zeros(1,subtot);

% Get the pattern of the file name
namefile = strsplit(files(1).name, {sep, '.mat'});
name_len = length(namefile{1});
pat_name = namefile{1}(1:name_len-1);
begin_idx = namefile{1}(name_len);

% Create the name array for all the subjects
count = 1;
for sub = str2num(begin_idx):str2num(begin_idx)+subtot-1
    sub_all{count} = [pat_name,num2str(sub)];
    count = count + 1;
end

% put all the data into a cell array
for i = 1:length(files)
    split = strsplit(files(i).name, {sep, '.mat'});
    % making a new name for that data
    namearr = [];
    for j = 1:length(usearr)
        namearr = cat(2,namearr,split(usearr(j)));
    end
    sub_trial{i} = strjoin(namearr,'_');
    name_trial{i} = strjoin(namearr,sep);
    % load the data into cell array
    data = load(files(i).name);
    data.EMG.name = name_trial{i};
    preoutput{i,1} = data;
end

% reshape
for sub = 1:subtot
    for ses = 1:howmanyeach(sub)
%         disp(['ses = ',num2str(ses)]);
%         disp(['sub = ',num2str(sub)]);
%         disp(['idx = ',num2str(ses+howmanyeach(sub-1)*(sub-1))]);
        if sub > 1
            output{ses, sub} = preoutput{ses+howmanyeach(sub-1)*(sub-1),1};
        elseif sub == 1
            output{ses, sub} = preoutput{ses,1};
        end
    end
end

% write to the output
out_cell_array = output;