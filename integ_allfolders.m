function processAllFolders(baseFolder)
    % 모든 하위 폴더를 검색
    subFolders = genpath(baseFolder);
  
    folderList = strsplit(subFolders, pathsep);
    
    % 각 폴더에 대해 처리
    for k = 1:length(folderList)
        if ~isempty(folderList{k})
            processFolder(folderList{k});
        end
    end
end

function processFolder(folder)
    files = dir(fullfile(folder,'*.mat')); % Load .txt files

    if isempty(files)
        return; 
    end

    for n = 1:length(files)
        numcell = regexp(files(n).name,'\d+','match');
        files(n).cellnum = str2num(numcell{end-1});
    end

    % Unique 셀넘버
    cellnum_list = unique([files.cellnum]);

    sortedFiles = []; 

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
        sortedFiles = [sortedFiles; cellfile_list(sortedIndex)]; % Append sorted files for this cell
    end

    % folder path에서 파일이름 추출하기
    folderParts = strsplit(folder, filesep);
    if length(folderParts) >= 3
        newNamePart = strjoin(folderParts(end-2:end), '_');
    else
        newNamePart = strjoin(folderParts, '_'); 
    end

    for k = 1:length(cellnum_list)
        mergedData = []; a
        cellFiles = sortedFiles([sortedFiles.cellnum] == cellnum_list(k)); % Get files for this cell

        for i = 1:length(cellFiles)
            % Load each sorted file
            filePath = fullfile(folder,cellFiles(i).name);
            data_now = load(filePath);

            if isfield(data_now, 'data')
                if isempty(mergedData)
                    % For the first file of this cell, initialize cellData with its content
                    mergedData = data_now.data;
                else
                    % For subsequent files of this cell, append their content to cellData
                    mergedData = [mergedData; data_now.data];
                end
            else
                warning('File "%s" does not contain the expected variable "data".', cellFiles(i).name);
            end
        end

        % Define the path and file name for each cell's merged data
        saveFilePath = fullfile(folder, sprintf('%s_%d.mat', newNamePart, cellnum_list(k)));

        % Save the cellData variable to a .mat file for this cell
        save(saveFilePath, 'mergedData');

        % Confirm the save operation for this cell
        fprintf('Merged data for cell %d saved to %s\n', cellnum_list(k), saveFilePath);
    end
end