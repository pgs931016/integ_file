clear; clc; close all


%% USE PROCESSED DATA
folder = 'G:\공유 드라이브\BSL_Data2\HNE_AgingDOE_Raw\HNE_FCC\4CPD 1C (25-42)\25degC';

files = dir(fullfile(folder,'*.txt')); % .mat


for n = 1:size(files,1)

% identify cell number
% 한 폴더에 셀 2개 에 대한 파일 이 있음
    numcell=regexp(files(n).name,'\d+','match');
    files(n).cellnum = str2num(numcell{end-1})                                                          ;


end


% 몇개의 셀이 있는지 확인, 셀넘버 가져오기)
cellnum_list = [files.cellnum]';
cellnum_list = unique(cellnum_list);


% 각 셀당 당 (2개)
for i = 1:length(cellnum_list)
    

        cellfile_list = files([files.cellnum]==cellnum_list(i));

        
    
        for j = 1:size(cellfile_list,1) % 각 셀의 실험 파일들 (aging N개, + RPT 개 )

            
            % identify experiment number "RPT_N" --> N "AgingN" --> N
            allnum = regexp(cellfile_list(j).name,'\d+','match');
            cellfile_list(j).expnum = str2num(allnum{end});

            % identify if RPT or Aging
            if ~isempty(regexp(cellfile_list(j).name,'Aging','match'))
        
                cellfile_list(j).rptflag = 0;
                
            elseif  ~isempty(regexp(cellfile_list(j).name,'RPT','match'))
        
                cellfile_list(j).rptflag = 1;
        
            end


            % sort by expnum --> rptflag(rev)
                % (1) sort --> sorted ind
                % (2) rearrange cellfile_list 
                %           cellfile_list = cellfile_list(sorted_ind)
            
            % merge (append) mat files AND SAVE
                % (a) save ('',.'','-append'(
                % (b) merge 명령어 있는지 찾아보

        end




end