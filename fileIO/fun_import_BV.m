function fun_import_BV(data_path, elc_path, save_path, chanlocs_path, do_trim)
% import Brain Vision file and make it to .mat format
%   Arguments:
%       - deta_path: the path to where the raw data are
%       - elc_path: the path to elc file from digitizer
%       - save_path: the path to save the data
%       - chanlocs_path: where chanlocs.mat is stored
%       - do_trim: whether to trim the data before and after the triggers
%                   (1 = do trimming, 0 = do not do trim)

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


%% Move to the path
cd(data_path);

% get all .vhdr files
files = dir('*.vhdr');

% iterate through a for loop and save the eeglab structure in .mat file
for i = 1:size(files,1)
    % load the data
    EEG = pop_loadbv(data_path, files(i).name);
    % specify set name
    split_name = strsplit(files(i).name,'.');
    EEG.setname = split_name{1};
    disp(['Loaded ', EEG.setname]);
    % load chanlocs file
    load([chanlocs_path,'\chanlocs.mat']);
    % store the info in the structure
    % chanlocs from mat
    locs_file = chanlocs;
    % from elc
    elc_file = pop_chanedit([], 'load',{elc_path, 'filetype', 'autodetect'});
    % make function here to sort elc_file to locs_file order
    new_elc = sort_eegchannel(locs_file, elc_file);
    % put them into the EEGLAB structure
    EEG.chanlocs = new_elc;
    EEG.chanlocs_fromLocs = locs_file;
    
    if (do_trim == 1) && (size(EEG.event,2) > 5)
        % trim before trigger (anything prior to 1 second before the first trigger)
        first_trigger = EEG.event(1, 1).latency;
        try
            fprintf('Trimming anything prior to 1 second before the first event');
            EEG = pop_select(EEG, 'nopoint', [1, first_trigger - (EEG.srate+1)]);
        catch
        end
        % trim after the last trigger (anything past 1 second after the last trigger)
        last_trigger = EEG.event(1, size(EEG.event,2)).latency;
        try
            fprintf('Trimming anything past 1 second after the last trigger');
            EEG = pop_select(EEG, 'nopoint', [last_trigger+1, EEG.pnts]);
        catch
        end
    end
    % save the data
    save([save_path,'\',EEG.setname,'.mat'],'EEG','-v7.3');
    fprintf('Saved the file\n');
end

end

