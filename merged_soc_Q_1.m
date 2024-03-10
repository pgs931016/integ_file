clc;clear;close all

folder_path = 'H:\공유 드라이브\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\4CPD 1C (25-42)\25degC';


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
       


    %스텝별로 계산
    for l = 1:length(data_merged)
       I_1C = 0.00429; %[A]
       Vmin = 2.5; %[V]
       Vmax = 4.2;  %[V]
       cutoff_min = -0.05; %[C]
       cutoff_max = 0.05;  %[C]
       data_merged(l).Iavg = mean(data_merged(l).I); 
 
        

        % 각 스텝 별로 Q 계산하기
        data_merged(l).Q = trapz(data_merged(l).t,data_merged(l).I)/3600;  %[Ah]
        % 각 스텝 별로 SOC 계산하기
        data_merged(l).cumQ = cumtrapz(data_merged(l).t,data_merged(l).I)/3600; %[Ah]
        data_merged(l).soc = data_merged(l).cumQ/data_merged(l).Q;
       
       
       data_merged(l).OCVflag = 0;
       % OCV 스텝 찾기 (OCVflag 추가)
       if data_merged(l).rptflag == 1 && abs(Vmax - data_merged(l).V(end)) < 10e-3 && abs(cutoff_max - data_merged(l).Iavg/I_1C) < 10e-3 && data_merged(l+2).type == 'D'
          data_merged(l).OCVflag = 1;
                  
       elseif data_merged(l).rptflag == 1 && abs(Vmin - data_merged(l).V(end)) < 10e-3 && abs(cutoff_min - data_merged(l).Iavg/I_1C) < 10e-3 && data_merged(l-2).type == 'C'
          data_merged(l).OCVflag = 2;

       end 
       


        

        
        % [1] OCV 스텝에 OCV 필드 생성
          % 1) OCV 스텝 -> OCVflag 0 (not OCV),1 (chg OCV),2 (dch (OCV)
          % 2) SOC 계산 -> 필드 추가 (Nx1) (충전/방전 둘다 0-1로 생각하면됨)
              % OCV 스탭일때
                % SOC 필드 추가
                % OCV 필드 추가 (N,2)
                % Fitting 실행 --> [x,,,,Q] 

    end

    %[2] Q, SOC, OCV 추가된 merged data 저장 (overwritting)


    save_path = fullfile([folder_path, merged_files(n).name]);
    save(save_path, 'data_merged')

    

    fileParts = strsplit(merged_files(n).name, '_');
    newNamePart = strjoin(fileParts(end-5:end-1));
  


% (예시) 방전 "사이클" 데이터만 (DCIR 등 제외) 플랏
% [3] 주요 조건에 대해서 플랏 하기.(라벨 추가)
figure(1)
data_D = data_merged(([data_merged.type]=='D')&(abs([data_merged.Q])>0.003)&([data_merged.rptflag]==0)|([data_merged.OCVflag])==2);
scatter([data_D.cycle],abs([data_D.Q]),'b'); hold on
legend(newNamePart)

figure(2)
data_D_Aging = data_merged(([data_merged.type]=='D')&(abs([data_merged.Q])>0.003)&([data_merged.rptflag]==0));
plot([data_D_Aging.cycle],abs([data_D_Aging.Q]),'ok'); 
legend(newNamePart)

figure(3)
data_D_RPT = data_merged(([data_merged.type]=='D')&(abs([data_merged.Q])>0.003)&([data_merged.OCVflag]==2));
plot([data_D_RPT.cycle],abs([data_D_RPT.Q]),'or'); 
legend(newNamePart)
end

% ylim([0 max(abs([data_D_RPT.Q]))]); hold off