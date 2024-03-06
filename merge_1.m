clear;clc;close all


rootfolder_path = 'G:\Shared drives\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\4CPD 1C (25-42)';

    % 모든 하위 폴더 검색
    subfolders = genpath(rootfolder_path );
    % 합쳐진 스트링을 각 폴더 스트링으로 쪼개기
    folder_list = strsplit(subfolders, pathsep);
        % 주의: 맨 끝단이 아니라 중간위 폴더도 포함 되어 있음


    % 각 폴더 별로 셀-머지 function 실행
    for m = 1:length(folder_list)
        if ~isempty(folder_list{m}) ...
            && ~isempty(regexp(folder_list{m},'degC','once')) % 주의: 맨하단 폴더를 degC로 조건으로 선별
            mergecell_folder(folder_list{m})
        end
    end





function mergecell_folder(folder_path)

files = [dir([folder_path filesep '*RPT*.mat']);...
         dir([folder_path filesep '*Aging*.mat'])];
% Merge.mat 파일이 있을 경우, 포함하지 않음. (추후 덮어씌움)


% 폴더의 파일들의 셀넘버를 지정
for n = 1:length(files)
    nums_incellname = regexp(files(n).name,'\d+','match');
    files(n).cellnum = str2double(nums_incellname{end-1});
end

% 폴더내 셀넘버의 리스트 만들기
cellnum_list = unique([files.cellnum]);


% 셀 별로 루프 돌리기
for i = 1:length(cellnum_list)

    % 각 셀에 해당하는 파일 모으기
    cellfile_list = files([files.cellnum] == cellnum_list(i));
    
        % 모아진 파일의 순서 정하기
    for j = 1:length(cellfile_list)
            % 파일이름의 모든 숫자 가져오기
            allnum = regexp(cellfile_list(j).name,'\d+','match');
            % RPT(n), Aging(n) 에서 해당하는 숫자 가져오기 (expnum) 
            cellfile_list(j).expnum = str2double(allnum{end});
            % RPT또는 AING 구분하기 (순서 정하기 위해서)
            if ~isempty(regexp(cellfile_list(j).name,'Aging','match'))
                cellfile_list(j).rptflag = 0; % aging의 경우, 0
            elseif ~isempty(regexp(cellfile_list(j).name,'RPT','match'))
                cellfile_list(j).rptflag = 1; % RPT의 경우, 1
            end

            % Sort priority 계산
            cellfile_list(j).order = cellfile_list(j).expnum + (1-cellfile_list(j).rptflag) * 0.5;
   end

   % 각셀에 해당하는 파일을을 sort 
   [~, sortedIndex] = sort([cellfile_list.order]);
   cellfile_list_sorted = cellfile_list(sortedIndex);


   % Sorted 된 순서대로, 하나씩 Append 하여 Merge
   data_merged = [];
   t_add = 0;
   cycle_add = 0;
   for k = 1:length(cellfile_list_sorted)
        
       % file 패쓰으로 데이터 로드
       fullpath_now = fullfile(folder_path,cellfile_list_sorted(k).name);
       data_now = load(fullpath_now);

       % 데이터 필드 잇는지 에러 확인
       if ~isfield(data_now, 'data')
           error('File "%s" does not contain the expected variable "data".', cellfile_list_sorted(k).name);
       end
       
       data = data_now.data;

       % rptflag 넣어주기
       rptflag_now = cellfile_list_sorted(k).rptflag; % scalar
       cell_rptflag = num2cell(ones([size(data,1),1]).*rptflag_now); % cell
       [data.rptflag] = cell_rptflag{:};


       % continuing time
       for l = 1:length(data)
            
           data(l).t = data(l).t + t_add;
           data(l).cycle = data(l).cycle + cycle_add;

       end

       t_add = data(end).t(end);
       cycle_add = data(end).cycle;

       % continuing cycle

       % Merge
       data_merged = [data_merged; data];
       

   end

   % confirm continuing time and cycle
%    figure(1)
%    plot([data_merged.cycle])
%    figure(2)
%    plot(vertcat(data_merged.t))

       
    if cellfile_list_sorted(end).rptflag ==1
        save_filename = regexprep(cellfile_list_sorted(end).name,'RPT*.','Merged');
    elseif cellfile_list_sorted(end).rptflag ==0
        save_filename = regexprep(cellfile_list_sorted(end).name,'Aging*.','Merged');
    end
    save_path = fullfile([folder_path filesep save_filename]);
    save(save_path, 'data_merged')

     fprintf('Merged data for cell %d saved to %s\n', cellnum_list(i), save_path);


end



end
