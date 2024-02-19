% 디렉토리 경로 설정
dirPath = {
    '/Users/g.park/Library/CloudStorage/GoogleDrive-gspark@kentech.ac.kr/공유 드라이브/BSL_Data2/HNE_AgingDOE_mat/RPT1',
    '/Users/g.park/Library/CloudStorage/GoogleDrive-gspark@kentech.ac.kr/공유 드라이브/BSL_Data2/HNE_AgingDOE_mat/Aging1',
    '/Users/g.park/Library/CloudStorage/GoogleDrive-gspark@kentech.ac.kr/공유 드라이브/BSL_Data2/HNE_AgingDOE_mat/RPT2',
    '/Users/g.park/Library/CloudStorage/GoogleDrive-gspark@kentech.ac.kr/공유 드라이브/BSL_Data2/HNE_AgingDOE_mat/Aging2',
    '/Users/g.park/Library/CloudStorage/GoogleDrive-gspark@kentech.ac.kr/공유 드라이브/BSL_Data2/HNE_AgingDOE_mat/RPT3',
    '/Users/g.park/Library/CloudStorage/GoogleDrive-gspark@kentech.ac.kr/공유 드라이브/BSL_Data2/HNE_AgingDOE_mat/Aging3',
    '/Users/g.park/Library/CloudStorage/GoogleDrive-gspark@kentech.ac.kr/공유 드라이브/BSL_Data2/HNE_AgingDOE_mat/RPT4'
};

I_1C = 0.00429; % [A]
n_hd = 14; % 'readtable' 옵션에서 사용되는 헤드라인 번호. WonA: 14, Maccor: 3.
sample_plot = [1];

save_Path = cell(size(dirPath)); % 수정된 경로를 저장할 셀 배열 초기화

for i = 1:length(dirPath)
    % dirPath를 슬래시 기준으로 분리
    splitPath = split(dirPath{i}, filesep);
    
    % "HNE_AgingDOE_processed"가 포함된 인덱스를 찾음
    index1 = find(strcmp('HNE_AgingDOE_mat', splitPath), 1);
    
    % "HNE_AgingDOE_processed" 다음에 "Experiment_data/RPT"를 추가
    modifiedPath = [splitPath(1:index1); "Combined"];
    
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
pattern = '(\d+).mat'; % 숫자 부분을 찾기 위한 패턴 정의

for i = 1:length(allFiles)
    fullpath_now = allFiles{i}; % 현재 파일의 전체 경로
    [~, fileName, ext] = fileparts(fullpath_now);
    
    % 파일 이름에서 숫자 부분 추출
    match = regexp([fileName, ext], pattern, 'match');
    
    if ~isempty(match)
        numPart = match{1}; % 첫 번째 일치 항목 사용
        numPart = regexprep(numPart, '.mat', ''); % '.mat' 부분 제거하여 순수 숫자만 남김
        
        % 숫자로 시작하면 'CellID_' 접두사 추가 (이미 숫자만 추출되므로 필요 없을 수 있음)
        numPart = ['CellID_' numPart]; 

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



baseSavePath = save_Path{1}; % 기본 저장 경로로 save_Path의 첫 번째 항목 사용

for numPartField = fieldnames(filesStruct)' 
    numPart = numPartField{1}; 
    fileList = filesStruct.(numPart); 

    groupDataStruct = struct(); 

    for fileIdx = 1:length(fileList)
        filePath = fileList{fileIdx}; 
        data = load(filePath); 

        dataFields = fieldnames(data);
        for dataField = dataFields'
            fieldName = dataField{1};
            if ~isfield(groupDataStruct, fieldName)
                groupDataStruct.(fieldName) = data.(fieldName);
            else
                try
                    groupDataStruct.(fieldName) = vertcat(groupDataStruct.(fieldName), data.(fieldName));
                catch
                    warning('Failed to vertically concatenate field %s due to inconsistent dimensions.', fieldName);
                end
            end
        end
    end

    % 각 numPart 그룹 데이터를 특정 경로에 저장
    numPartSavePath = fullfile(baseSavePath, numPart); % numPart에 해당하는 저장 경로 생성
    if ~exist(numPartSavePath, 'dir')
        mkdir(numPartSavePath); % 디렉토리가 존재하지 않으면 생성
    end
    saveFileName = fullfile(numPartSavePath, sprintf('%s_Experiment_data.mat', numPart));
    save(saveFileName, 'groupDataStruct', '-v7.3');
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
