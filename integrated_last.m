clear; clc; close all;
slash = filesep;

% folder 경로 설정
folder = 'C:\Users\GSPARK\SynologyDrive\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\4CPD 1C (25-42)\25degC';
files = dir(fullfile(folder,'*.mat')); % Load .mat files

for n = 1:length(files)
    numcell = regexp(files(n).name,'\d+','match');
    files(n).cellnum = str2num(numcell{end-1});
end

% Unique 셀넘버
cellnum_list = unique([files.cellnum]);

sortedFiles = []; % 

for i = 1:length(cellnum_list)
    cellfile_list = files([files.cellnum] == cellnum_list(i));
    
    for j = 1:length(cellfile_list)
        allnum = regexp(cellfile_list(j).name,'\d+','match');
        cellfile_list(j).expnum = str2num(allnum{end});

        if ~isempty(regexp(cellfile_list(j).name,'Aging','match'))
            cellfile_list(j).rptflag = 0;
        elseif ~isempty(regexp(cellfile_list(j).name,'RPT','match'))
            cellfile_list(j).rptflag = 1;
        end

        % Sort priority 계산
        cellfile_list(j).order = cellfile_list(j).expnum + (cellfile_list(j).rptflag == 0) * 0.5;
    end

    % sortedFiles 추가
    [~, sortedIndex] = sort([cellfile_list.order]);
    sortedFiles = [sortedFiles; cellfile_list(sortedIndex)]; 
end


% folder path에서 파일이름 추출하기
folderParts = strsplit(folder, filesep);
if length(folderParts) >= 3
    newNamePart = strjoin(folderParts(end-2:end), '_');
end


for k = 1:length(cellnum_list)
    cellData = []; 
    cellFiles = sortedFiles([sortedFiles.cellnum] == cellnum_list(k)); % Get files for this cell
    

    for i = 1:length(cellFiles)


        filePath = fullfile(folder,cellFiles(i).name);
        data_now = load(filePath);
        

        if isfield(data_now, 'data')
            if isempty(cellData)
                % Initialize cellData with its content
                cellData = data_now.data;
            else
                % Append their content to cellData
                cellData = [cellData; data_now.data];
            end
        else
            warning('File "%s" does not contain the expected variable "data".', cellFiles(i).name);
        end
    end
    

    % Define the path and file name for each cell's merged data
    saveFilePath = fullfile(folder, sprintf('%s_%d.mat', newNamePart, cellnum_list(k)));
    
    save(saveFilePath, 'cellData');
    
    % Confirm the save operation for this cell
    fprintf('Merged data for cell %d saved to %s\n', cellnum_list(k), saveFilePath);
end


