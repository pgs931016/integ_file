clc; clear; close all
dirPath = {'C:\Users\BSL\SynologyDrive\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC'};

I_1C = 0.00429; % [A]
n_hd = 14; % 'readtable' 옵션에서 사용되는 헤드라인 번호. WonA: 14, Maccor: 3.
sample_plot = [1];

save_Path = cell(size(dirPath)); % 수정된 경로를 저장할 셀 배열 초기화

for i = 1:length(dirPath)
    % dirPath를 슬래시 기준으로 분리
    splitPath = split(dirPath{i}, filesep);
    
    % "HNE_AgingDOE_processed"가 포함된 인덱스를 찾음
    index1 = find(strcmp('HNE_AgingDOE_processed', splitPath), 1);
    
    modifiedPath = [splitPath(1:index1)];
    
    % 수정된 경로를 셀 배열에 저장
    save_Path{i} = strjoin(modifiedPath, filesep);
end

% 새 디렉토리 경로가 존재하지 않으면 생성
for i = 1:length(save_Path)
    if ~exist(save_Path{i}, 'dir')
       mkdir(save_Path{i})
    end
end

% 모든 .mat 파일을 재귀적으로 가져오기
allFiles = {};
for i = 1:length(dirPath)
    files = getAllFiles(dirPath{i}, '*.mat');
    allFiles = [allFiles; files]; % 결과를 allFiles 배열에 추가
end

% 파일 처리 및 구조체에 묶기
filesStruct = struct();
pattern = '(\d+).mat'; 

for i = 1:length(allFiles)
    fullpath_now = allFiles{i}; % 현재 파일의 전체 경로
    [~, fileName, ext] = fileparts(fullpath_now);
    
    % 파일 이름에서 숫자 부분 추출
    splitName = split(fileName, '_'); % 파일 이름을 '_'로 분할
    numPart = splitName{end}; % 파일 이름에서 마지막 부분은 숫자
    match = regexp(numPart, pattern, 'match');
    
    if ~isempty(match)
        numPart = match{1}; 
        
        numPart = ['CH_' numPart]; 

        % 구조체 필드 할당 전 numPart 값 확인
        disp(['Field name being assigned: ', numPart]);

        % 구조체에 파일 경로 저장
        if ~isfield(filesStruct, numPart)
            filesStruct.(numPart) = {fullpath_now};
        else
            filesStruct.(numPart){end+1} = fullpath_now;
        end
    end
end


for numPartField = fieldnames(filesStruct)' 
    numPart = numPartField{1}; 
    fileList = filesStruct.(numPart); 

    combined_data = struct(); 

    for fileIdx = 1:length(fileList)
        filePath = fileList{fileIdx}; 
        data = load(filePath); 

        dataFields = fieldnames(data);
        for dataField = dataFields'
            fieldName = dataField{1};
            if ~isfield(combined_data, fieldName)
                combined_data.(fieldName) = data.(fieldName);
            else
                try
                    combined_data.(fieldName) = vertcat(combined_data.(fieldName), data.(fieldName));
                catch
                    warning('Failed to vertically concatenate field %s due to inconsistent dimensions.', fieldName);
                end
            end
        end
    end

    % 대상 파일들의 경로에 파일 저장
    [~, fileName, ~] = fileparts(fileList{1}); % 파일 이름 추출
    saveFileName = fullfile(fileparts(fileList{1}), [fileName, '_', numPart, '.mat']); % 수정된 파일 이름으로 저장
    save(saveFileName, 'combined_data', '-v7.3');
end

%% Helper Function to Recursively Get All Files
function fileList = getAllFiles(dirName, filePattern)
    dirData = dir(dirName);      % Get the data for the current directory
    dirIndex = [dirData.isdir];  % Find the index for directories
    fileList = {dirData(~dirIndex).name}';  % Get a list of the files
    if ~isempty(fileList)
        fileList = cellfun(@(x) fullfile(dirName,x),...  % Convert to full path
            fileList,'UniformOutput',false);
    end
    subDirs = {dirData(dirIndex).name};  % Get a list of sub-directories
    validIndex = ~ismember(subDirs,{'.','..'});  % Find index of sub-directories excluding '.' and '..'

    for iDir = find(validIndex)                  % Loop over valid sub-directories
        nextDir = fullfile(dirName,subDirs{iDir}); % Get the sub-directory path
        fileList = [fileList; getAllFiles(nextDir, filePattern)];  % Recurse
    end
end
