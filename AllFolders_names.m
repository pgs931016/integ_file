function AllFolders(baseFolder)
    % 모든 하위 폴더를 검색
    subFolders = genpath(baseFolder);
  
    folderList = strsplit(subFolders, pathsep);
    
    % 하위 폴더에 대해 처리
    for k = 1:length(folderList)
        if ~isempty(folderList{k})
            processFolder(folderList{k});
        end
    end
end

function processFolder(folder)
    files = dir(fullfile(folder,'*.mat')); % Load .mat files

    for n = 1:length(files)
        numcell = regexp(files(n).name,'\d+','match');
        if numel(numcell) >= 2 % Ensure that at least two numbers are found in the file name
            files(n).cellnum = str2double(numcell{end-1}); % Extract the second last number as cellnum
            files(n).samnum = str2double(numcell{end-2}); % Extract the third last number as samnum
        else
            warning('File "%s" does not contain enough numerical information.', files(n).name);
        end
    end

    % Unique cell numbers and sample numbers
    cellnum_list = unique([files.cellnum]);
    samnum_list = unique([files.samnum]);

    % Sorting files
    sortedFiles = [];

    for i = 1:length(cellnum_list)
        cellfile_list = files([files.cellnum] == cellnum_list(i));

        for j = 1:length(cellfile_list)
            allnum = regexp(cellfile_list(j).name,'\d+','match');
            cellfile_list(j).expnum = str2double(allnum{end});

            if ~isempty(regexp(cellfile_list(j).name,'Aging','match'))
                cellfile_list(j).rptflag = 0;
            elseif ~isempty(regexp(cellfile_list(j).name,'RPT','match'))
                cellfile_list(j).rptflag = 1;
            end

            % Calculate sort priority
            cellfile_list(j).order = cellfile_list(j).expnum + (cellfile_list(j).rptflag == 0) * 0.5;
        end

        % Add sorted files
        [~, sortedIndex] = sort([cellfile_list.order]);
        sortedFiles = [sortedFiles; cellfile_list(sortedIndex)]; % Append sorted files for this cell
    end

    % Extract folder name for file naming
    folderParts = strsplit(folder, filesep);
    if length(folderParts) >= 3
        newNamePart = strjoin(folderParts(end-2:end), '_');
    else
        newNamePart = strjoin(folderParts, '_');
    end

    % Process each cell's merged data
    for k = 1:length(cellnum_list)
        mergedData = [];
        cellFiles = sortedFiles([sortedFiles.cellnum] == cellnum_list(k)); % Get files for this cell

        for i = 1:length(cellFiles)
            % Load each sorted file
            filePath = fullfile(folder,cellFiles(i).name);
            data_now = load(filePath);

            if isfield(data_now, 'data')
                if isempty(mergedData)
                    % For the first file of this cell, initialize mergedData with its content
                    mergedData = data_now.data;
                else
                    % For subsequent files of this cell, append their content to mergedData
                    mergedData = [mergedData; data_now.data];
                end
            else
                warning('File "%s" does not contain the expected variable "data".', cellFiles(i).name);
            end
        end

        % Define the path and file name for each cell's merged data
        saveFilePath = fullfile(folder, sprintf('%s_s%d_%d.mat', newNamePart, samnum_list(k), cellnum_list(k)));

        % Save the mergedData variable to a .mat file for this cell
        save(saveFilePath, 'mergedData');

        % Confirm the save operation for this cell
        fprintf('Merged data for cell (samnum: %d, cellnum: %d) saved to %s\n', samnum_list(k), cellnum_list(k), saveFilePath);
    end
end
