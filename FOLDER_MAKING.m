clc; 
clear; 
close all;

slash = filesep;

% load xlxs
Data_path = 'G:\공유 드라이브\BSL_Data2\HNE_AgingDOE_mat';



% Data_path를 슬래시 기준으로 분리
splitPath = split(Data_path, filesep);

% "Data"가 포함된 인덱스를 찾음
index1 = find(strcmp('HNE_AgingDOE_mat', splitPath), 1);

% "Data"를 "Processed_Data"로 변경 (요구사항에 따라)
splitPath{index1} = 'HNE_AgingDOE_Processed';

% index까지의 경로만을 사용하여 save_path 설정
savePathComponents = splitPath(1:index1);

% save_path를 재구성
save_path = strjoin(savePathComponents, filesep);


% 엑셀 Data load
xlsfile = 'G:\공유 드라이브\BSL_Data2\HNE_Folder_Automation.xlsx';

if exist(xlsfile, 'file') == 2
    disp('File exists.');
else
    disp('File does not exist.');
end


% 각 시트를 읽어오기 위해 엑셀 파일의 정보를 가져옵니다.
sheetNames = sheetnames(xlsfile);
disp(class(sheetNames));  % sheetNames의 데이터 타입 출력




% 찾고자 하는 문자열
desiredString = 'RPT4';


% 입력한 문자열과 일치하는 시트를 찾아서 데이터를 적용
for i = 1:length(sheetNames)
    % 엑셀 파일에서 데이터를 읽어와 테이블로 변환
    data = readtable(xlsfile, 'Sheet', sheetNames(i));


    % 시트 헤더 가져오기
    sheetHeaders = data.Properties.VariableNames;

    % 입력한 문자열과 시트의 7번째 열의 1행의 문자가 일치하면 데이터 적용
    if strcmp(data.(sheetHeaders{7})(1), desiredString)
        % 시트의 첫 번째 열의 값을 가져와 폴더 이름으로 설정
        firstColumnData = data.(sheetHeaders{1});
        firstColumnData(cellfun(@(x) isequal(x, 'None') || isempty(x), firstColumnData)) = [];
        uniqueFirstValues = unique(firstColumnData);
        uniqueFirstValues = uniqueFirstValues(~cellfun('isempty', uniqueFirstValues));

        % 두 번째 셀의 첫 번째 값을 가져와 폴더 이름으로 설정
        secondColumnData = data.(sheetHeaders{7});
        secondColumnData(cellfun(@(x) isequal(x, 'None') || isempty(x), secondColumnData)) = [];
        uniqueSecondValues = unique(secondColumnData);
        uniqueSecondValues = uniqueSecondValues(~cellfun('isempty', uniqueSecondValues));

        % 세 번째 셀의 첫 번째 값을 가져와 폴더 이름으로 설정
        thirdColumnData = data.(sheetHeaders{2});
        thirdColumnData(cellfun(@(x) isequal(x, 'None') || isempty(x), thirdColumnData)) = [];
        uniqueThirdValues = unique(thirdColumnData);
        uniqueThirdValues = uniqueThirdValues(~cellfun('isempty', uniqueThirdValues));

        % 네 번째 셀의 첫 번째 값을 가져와 폴더 이름으로 설정
        fourthColumnData = data.(sheetHeaders{3});
        fourthColumnData(cellfun(@(x) isequal(x, 'None') || isempty(x), fourthColumnData)) = [];
        uniqueFourthValues = unique(fourthColumnData);
        uniqueFourthValues = uniqueFourthValues(~cellfun('isempty', uniqueFourthValues));

        % 다섯 번째 셀의 첫 번째 값을 가져와 폴더 이름으로 설정
        fifthColumnData = data.(sheetHeaders{5});
        fifthColumnData = fifthColumnData(~isnan(fifthColumnData));
        uniqueFifthValues = unique(fifthColumnData);

        % 여섯 번째 셀의 첫 번째 값을 가져와 폴더 이름으로 설정
        sixthColumnData = data.(sheetHeaders{6});
        sixthColumnData = sixthColumnData(~isnan(sixthColumnData));
        uniqueSixthValues = unique(sixthColumnData);


        % 폴더 생성
        for i = 1:length(uniqueFirstValues)
            folderPath1 = fullfile(save_path, uniqueFirstValues{i});
            % if ~exist(folderPath1, 'dir')
            %     mkdir(folderPath1);
            % end

            for j = 1:length(uniqueSecondValues)
                folderPath2 = fullfile(folderPath1, uniqueSecondValues{j});
                % if ~exist(folderPath2, 'dir')
                %     mkdir(folderPath2);
                % end

                for k = 1:length(uniqueThirdValues)
                    folderPath3 = fullfile(folderPath2, uniqueThirdValues{k});
                    % if ~exist(folderPath3, 'dir')
                    %     mkdir(folderPath3);
                    % end
                end
            end
        end
        break; % 일치하는 시트를 찾았으므로 루프 중단
    end
end


% RPT1 폴더 내의 파일들을 가져와서 처리

alltxtfiles = {};
subfolders = dir(Data_path);
subfolders = subfolders([subfolders.isdir]);
subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'}));

% desiredString과 일치하는 폴더 찾기
for i = 1:length(subfolders)
    if strcmp(subfolders(i).name, desiredString)
        % 일치하는 폴더 내의 .txt 파일 찾기
        targetfolderPath = fullfile(Data_path, subfolders(i).name);
        txtfiles = dir(fullfile(targetfolderPath, '*.mat'));

        % 각 파일의 전체 경로를 alltxtfiles에 추가
        for j = 1:length(txtfiles)
            alltxtfiles{end+1} = fullfile(targetfolderPath, txtfiles(j).name);
        end
    end
end



for i = 1:length(alltxtfiles)
    currentFile = alltxtfiles{i};
    [~, fileName, fileExt] = fileparts(currentFile);

    % 언더스코어(_)로 파일 이름을 분리
    fileName = strrep(fileName, '_DC', ''); % 파일 이름에서 '_DC' 제거
    parts = strsplit(fileName, '_');

    if length(parts) >= 2
        numPart = str2double(parts{end}); 

        for idx = 1:length(sixthColumnData)

                % sheetHeaders{5}와 numPart가 일치하는 경우
                if any(fifthColumnData == numPart)
                    % numPart와 일치하는 인덱스 찾기
                    numidx = find(fifthColumnData == numPart);

                    % sheetHeaders{2}와 sheetHeaders{3}에 폴더 분배
                    for k = 1:length(numidx)
                        idxToUse = numidx(k);
                        firstValue = data.(sheetHeaders{1}){idxToUse};
                        secondValue = data.(sheetHeaders{2}){idxToUse};
                        thirdValue = data.(sheetHeaders{3}){idxToUse};
                        fourthValue = data.(sheetHeaders{4}){idxToUse};
                        fifthValue = data.(sheetHeaders{5})(idxToUse);
                        sixthValue = data.(sheetHeaders{6})(idxToUse);
                        seventhValue = data.(sheetHeaders{7}){idxToUse};


                        folderPath1 = fullfile(save_path, firstValue);
                        folderPath2 = fullfile(folderPath1, seventhValue);
                        folderPath3 = fullfile(folderPath2, secondValue);
                        folderPath4 = fullfile(folderPath3, thirdValue);


                     % 새로운 파일 이름 구성
                    if floor(fifthValue) == fifthValue && floor(sixthValue) == sixthValue
                     % 정수인 경우
                     newFileName = sprintf('%s_%s_%s_%s_%d_%d_%s%s', firstValue, secondValue, thirdValue, fourthValue, fifthValue, sixthValue, seventhValue,  fileExt);
                    else
                     % 소수점이 포함된 경우
                     newFileName = sprintf('%s_%s_%s_%s_%.2f_%.2f_%s%s', firstValue, secondValue, thirdValue, fourthValue, fifthValue, sixthValue, seventhValue,  fileExt);
                    end

                    if ~exist(folderPath4, 'dir')
                            mkdir(folderPath4);

                    end

                        % 새 파일 경로 생성
                        newFilePath = fullfile(folderPath4, newFileName);

                        % 원본 파일을 새 경로로 복사
                        copyfile(currentFile, newFilePath);

                    end
                end
            end
        end
end
