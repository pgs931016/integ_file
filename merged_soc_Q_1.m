

folder_path = 'G:\Shared drives\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\4CPD 1C (25-42)\25degC';


% [4] rootfolder_path 에서 하위 폴더로 실행, 이하 함수화
% --> merge_1.m 참고



% merged 파일만 불러오기
merged_files = dir([folder_path filesep '*Merged.mat']);

for n = 1:length(merged_files)
  % 데이터 불러오기
       fullpath_now = fullfile(folder_path,merged_files(n).name);
       data_now = load(fullpath_now);
       % 데이터 필드 잇는지 에러 확인
       if ~isfield(data_now, 'data_merged')
           error('File "%s" does not contain the expected variable "data".', merged_files(n).name);
       end
       data_merged = data_now.data_merged;

    % 스텝별로 계산
    for l = 1:length(data_merged)
        % 각 스텝 별로 Q 계산하기
        data_merged(l).Q = trapz(data_merged(l).t,data_merged(l).I);
        % 각 스텝 별로 SOC 계산하기
        
        % [1] OCV 스텝에 OCV 필드 생성
          % 1) OCV 스텝 -> OCVflag 0 (not OCV),1 (chg OCV),2 (dch (OCV)
          % 2) SOC 계산 -> 필드 추가 (Nx1) (충전/방전 둘다 0-1로 생각하면됨)
              % OCV 스탭일때
                % SOC 필드 추가
                % OCV 필드 추가 (N,2)
                % Fitting 실행 --> [x,,,,Q] 


    end

    %[2] Q, SOC, OCV 추가된 merged data 저장 (overwritting)


end


% (예시) 방전 "사이클" 데이터만 (DCIR 등 제외) 플랏
% [3] 주요 조건에 대해서 플랏 하기.(라벨 추가)
figure(4)
data_D = data_merged(([data_merged.type]=='D')&(abs([data_merged.Q])>6)&([data_merged.rptflag]==0));
plot([data_D.cycle],abs([data_D.Q]),'ok'); hold on
data_D_RPT = data_merged(([data_merged.type]=='D')&(abs([data_merged.Q])>6)&([data_merged.rptflag]==1));
plot([data_D_RPT.cycle],abs([data_D_RPT.Q]),'or'); 

ylim([0 max(abs([data_D_RPT.Q]))]); hold off