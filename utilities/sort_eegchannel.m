function [sorted_chanlocs] = sort_eegchannel(baseline_chanlocs, sorting_chanlocs)
% function to sort the order of channels
%   make sure to give chanlocs structure for both arguments

% run through baseline chanlocs to get the correct channels
for i = 1:length(baseline_chanlocs)
    % run through the sorting chanlocs to get that channel
    for j = 1:length(sorting_chanlocs)
        % identify the channel
        if strfind(sorting_chanlocs(j).labels,baseline_chanlocs(i).labels) == 1
            % put it into a structure
            out_struct(i) = sorting_chanlocs(j);
        end
    end
end

% make sure to change urchan order
for i = 1:length(baseline_chanlocs)
    out_struct(i).urchan = i;
end

% output the finished structure
sorted_chanlocs = out_struct;

end

