function uh_readcaptrak(captrakfilename,varargin)
% Date: 160408;
% Phat Luu. University of Houston, BMILab.
% tpluu2207@gmail.com
% ==
% This function reads captrak file and save in other format (.elec,
% .locs,...)
% External functions: get_varargin.
% Input:
% captrakfilename: filepath;
% Options: output format. 160408: Only support .elc format;
%          filenameoutput: output file. Default location is the same as
%          input file.
% Example: uh_readcaptrak(yourcaptrak_bvct_filepath);
%          uh_readcaptrak(yourcaptrak_bvct_filepath,'filename',youroutput_filepath);
%=====================================================================
outputformat = get_varargin(varargin,'format','.elc'); % default: EETrak format;
filenameoutput = get_varargin(varargin,'filename',strrep(captrakfilename,'.bvct',outputformat));
caplayout = get_varargin(varargin,'caplayout','EOG_avatar');
fid = fopen(captrakfilename);
filescan = textscan(fid,'%s','delimiter','\n');
filescan = filescan{:}; % Open settings file (importdata does not work)
k = 1;
for line = 1:length(filescan)
    fullLine=filescan{line};
    if strcmpi(fullLine,'<CapTrakElectrode>');
        elecline(k) =  line;
        k = k + 1;
    end
end
numchan = length(elecline)
for i = 1: numchan
    thisline = elecline(i);
    temp = getelectrode(filescan,thisline);
    if strcmpi(temp.label,'Nasion')
        temp.label = 'Nz';
    elseif strcmpi(temp.label,'A1')
        temp.label = 'LPA';
    elseif strcmpi(temp.label,'A2')
        temp.label = 'RPA';
    end
    elec(i) = temp;
end
for i = 1: numchan    
%     elec(i).channel = str2double(elec(i).channel);
%     if elec(i).channel == 0    % xml markup in captrak file <Channel> is all zero???
        if strcmpi(caplayout,'eog_avatar')
            elec(i).channel = get_EOG_avatarCap(elec(i).label); % use get_64activeCap (line 94) if standard cap is used.
        elseif strcmpi(caplayout,'eog_neuroleg')
            elec(i).channel = get_EOG_NeurolegCap(elec(i).label); % use get_64activeCap (line 94) if standard cap is used.
        elseif strcmpi(caplayout,'standard')
            elec(i).channel = get_64activeCap(elec(i).label); % use get_64activeCap (line 94) if standard cap is used.            
        end
%     end
end
[~,idx] = sort([elec.channel]);                     % Sort channel in standard order.
elec = elec(idx);
% Print to output file
mytext = getheader(outputformat,'numchan',numchan);
switch lower(outputformat)
    case '.elc'
        for i =  1:numchan
            mytext{end+1} = sprintf('%.4f %.4f %.4f',str2double(elec(i).x), str2double(elec(i).y), str2double(elec(i).z));
        end
        mytext{end+1} = 'Labels';
        for i =  1:numchan
            mytext{end+1} = elec(i).label;
        end
    otherwise
end
% Write to text file;
fid = fopen(filenameoutput,'w');
for i = 1 : length(mytext)
    fprintf(fid,'%s\n',mytext{i});    
end
fclose(fid);
fprintf('DONE: %s has been created.\n',filenameoutput);

function header = getheader(format,varargin)
numsens = get_varargin(varargin,'numchan',63);
if strcmpi(format,'.elc');
    header{1} = '# ASA electrode file';
    header{end+1} = 'ReferenceLabel	avg';
    header{end+1} = 'UnitPosition	mm';
    header{end+1} = sprintf('NumberPositions=	%d',numsens);
    header{end+1} = 'Positions';
end

function elec = getelectrode(filescan, line)
fieldnames = {'Name','X','Y','Z','Theta','Phi','Radius','Channel'};
elecfield = {'label','x','y','z','theta','phi','radius','channel'};
for i = 1: length(fieldnames)
    cmdstr = sprintf('elec.%s = getxml(filescan{line+%d},''%s'');',elecfield{i},i,fieldnames{i});
    eval(cmdstr);
end
    
function val = getxml(fullline,markup)
len = length(markup);
val = fullline(len+3:end-len-3);

function ch = get_64actiCap(label)
% Ref: 
% actiCap montage: http://www.brainproducts.com/downloads.php?kid=8
actiCaplabel = {'Fp1','Fp2',...                 % Green label channel
    'F7','F3','Fz','F4','F8',...
    'FC5','FC1','FC2','FC6',...
    'T7','C3','Cz','C4','T8',...
    'TP9','CP5','CP1','CP2','CP6','TP10',...
    'P7','P3','Pz','P4','P8',...
    'PO9','O1','Oz','O2','PO10',...
    'AF7','AF3','AF4','AF8',...                 % Yellow label channel
    'F5','F1','F2','F6',...
    'FT9','FT7','FC3','FC4','FT8','FT10',...
    'C5','C1','C2','C6',...
    'TP7','CP3','CPz','CP4','TP8',...
    'P5','P1','P2','P6',...
    'PO7','PO3','POz','PO4','PO8',...
    'LPA','RPA','Nz'};                          % fiducial;
ch = find(ismember(lower(actiCaplabel),lower(label)));

function ch = get_EOG_avatarCap(label)
% Ref: 
% actiCap montage: http://www.brainproducts.com/downloads.php?kid=8
% T7 move to GND, AFz and T8 move to Ref, FCz;
% Remove 4 channels for EOG in Captrak: FT9, FT10, TP9, TP10
actiCaplabel = {'Fp1','Fp2',...                 % Green label channel
    'F7','F3','Fz','F4','F8',...
    'FC5','FC1','FC2','FC6',...
    'AFz','C3','Cz','C4','FCz',...
    'CP5','CP1','CP2','CP6',...
    'P7','P3','Pz','P4','P8',...
    'PO9','O1','Oz','O2','PO10',...
    'AF7','AF3','AF4','AF8',...                 % Yellow label channel
    'F5','F1','F2','F6',...
    'FT7','FC3','FC4','FT8',...
    'C5','C1','C2','C6',...
    'TP7','CP3','CPz','CP4','TP8',...
    'P5','P1','P2','P6',...
    'PO7','PO3','POz','PO4','PO8',...
    'LPA','RPA','Nz'};                          % fiducial;
ch = find(ismember(lower(actiCaplabel),lower(label)));
        
function ch = get_EOG_NeurolegCap(label)
% Ref: 
% actiCap montage: http://www.brainproducts.com/downloads.php?kid=8
% FT9 move to GND, AFz and FT10 move to Ref, FCz; ?? Check with Justin
% Captrack file didn't change FT9 to AFz and FT10 to FCz.
% Remove 4 channels for EOG in Captrak: PO9, PO10, TP9, TP10
actiCaplabel = {'Fp1','Fp2',...                 % Green label channel
    'F7','F3','Fz','F4','F8',...
    'FC5','FC1','FC2','FC6',...
    'T7','C3','Cz','C4','T8',...
    'CP5','CP1','CP2','CP6',...
    'P7','P3','Pz','P4','P8',...
    'O1','Oz','O2',...
    'AF7','AF3','AF4','AF8',...                 % Yellow label channel
    'F5','F1','F2','F6',...
    'FT9','FT7','FC3','FC4','FT8','FT10'...
    'C5','C1','C2','C6',...
    'TP7','CP3','CPz','CP4','TP8',...
    'P5','P1','P2','P6',...
    'PO7','PO3','POz','PO4','PO8',...
    'LPA','RPA','Nz'};                          % fiducial;
ch = find(ismember(lower(actiCaplabel),lower(label)));



