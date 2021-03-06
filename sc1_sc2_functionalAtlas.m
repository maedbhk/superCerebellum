
function varargout=sc1_sc2_functionalAtlas(what,varargin)

% Directories
baseDir          = '/Users/maedbhking/Documents/Cerebellum_Cognition';
% baseDir          = '/Users/maedbhking/Remote/Documents2/Cerebellum_Cognition';
baseDir            = '/Volumes/MotorControl/data/super_cerebellum_new';
% baseDir          = '/Users/jdiedrichsen/Data/super_cerebellum_new';

atlasDir='/Users/maedbhking/Documents/Atlas_templates/';

studyDir{1}     =fullfile(baseDir,'sc1');
studyDir{2}     =fullfile(baseDir,'sc2');
studyStr        = {'SC1','SC2','SC12'};
behavDir        ='/data';
suitDir         ='/suit';
caretDir        ='/surfaceCaret';
regDir          ='/RegionOfInterest/';
encodeDir       ='/encoding';

funcRunNum = [51,66];  % first and last behavioural run numbers (16 runs per subject)

run = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16'};

subj_name = {'s01','s02','s03','s04','s05','s06','s07','s08','s09','s10','s11',...
    's12','s13','s14','s15','s16','s17','s18','s19','s20','s21','s22','s23','s24',...
    's25','s26','s27','s28','s29','s30','s31'};

returnSubjs=[2,3,4,6,8,9,10,12,14,15,17,18,19,20,21,22,24,25,26,27,28,29,30,31];

hem={'lh','rh'};
hemName={'LeftHem','RightHem'};

switch what
    
    case 'PARTICIPANT:info'
        % load in excel file with participant info
        
        D=dload(fullfile(baseDir,'sc1_sc2_taskDesign.txt'));
        
        % how many women/men ?
        idx=D.include==1;
        fprintf('there are %d women and %d men \n',sum(char(D.Sex(idx))=='F'),sum(char(D.Sex(idx))=='M'));
        
        % average age across men and women
        numdays = datenum(D.BEHA1(idx),'dd-mm-yy') - datenum(D.DOB(idx),'dd-mm-yy');
        ages=round(numdays/365);
        fprintf('the average age is %2.2f (sd=%2.2f) \n',mean(ages),std(ages))
        
        % average time between sessions
        numdays = datenum(D.BEHB1(idx),'dd-mm-yy') - datenum(D.BEHA1(idx),'dd-mm-yy');
        fprintf('the average amount of time between task sets is %2.2f days (sd=%2.2f) \n',mean(numdays),std(numdays));
        
        % SCANNING
        numdays = datenum(D.SCANA1(idx),'dd-mm-yy') - datenum(D.BEHA3(idx),'dd-mm-yy');
        fprintf('the average amount of time from behav 3 to scan 1 in setA is %2.2f days (sd=%2.2f) \n',mean(numdays),std(numdays));
        
        numdays = datenum(D.SCANB1(idx),'dd-mm-yy') - datenum(D.BEHB3(idx),'dd-mm-yy');
        fprintf('the average amount of time from behav 3 to scan 1  in setB is %2.2f days (sd=%2.2f) \n',mean(numdays),std(numdays));
        
        numdays = datenum(D.SCANA2(idx),'dd-mm-yy') - datenum(D.SCANA1(idx),'dd-mm-yy');
        fprintf('the average amount of time from scan 1 to scan 2 in setA is %2.2f days (sd=%2.2f) \n',mean(numdays),std(numdays));
        
        numdays = datenum(D.SCANB2(idx),'dd-mm-yy') - datenum(D.SCANB1(idx),'dd-mm-yy');
        fprintf('the average amount of time from scan 1 to scan 2 in setB is %2.2f days (sd=%2.2f) \n',mean(numdays),std(numdays));
        
        %  BEHAVIOUR
        numdays = datenum(D.BEHA3(idx),'dd-mm-yy') - datenum(D.BEHA1(idx),'dd-mm-yy');
        fprintf('the average amount of time across behav sessions in setA is %2.2f days (sd=%2.2f) \n',mean(numdays+1),std(numdays+1));
        
        numdays = datenum(D.BEHB3(idx),'dd-mm-yy') - datenum(D.BEHB1(idx),'dd-mm-yy');
        fprintf('the average amount of time across behav sessions in setB is %2.2f days (sd=%2.2f) \n',mean(numdays+1)+1,std(numdays+1));
        
    case 'BEHAVIOURAL:get_data'
        sess=varargin{1}; % 'behavioural' or 'scanning'
        
        sn=returnSubjs;
        
        tasks={'stroop','nBack','visualSearch','GoNoGo','nBackPic','affective','emotional','ToM','arithmetic','intervalTiming',...
            'CPRO','prediction','spatialMap','mentalRotation','emotionProcess','respAlt','visualSearch2','nBackPic2','ToM2'};
        
        study=[1;1;1;1;1;1;1;1;1;1;2;2;2;2;2;2;2;2;2];
        
        T=[];
        for s=sn,
            for t=1:length(tasks),
                D = dload(fullfile(studyDir{study(t)},behavDir,subj_name{s},sprintf('sc%d_%s_%s.dat',study(t),subj_name{s},tasks{t})));
                switch sess,
                    case 'training'
                        A = getrow(D,D.runNum>=1 & D.runNum<=51);
                    case 'scanning'
                        A = getrow(D,D.runNum>=funcRunNum(1) & D.runNum<=funcRunNum(2));
                end
                S.taskName=A.taskName;
                S.numCorr=A.numCorr;
                S.rt=A.rt;
                S.SN=repmat(s,length(A.taskName),1);
                S.runNum=A.runNum;
                S.respMade=A.respMade;
                T=addstruct(T,S);
            end
            fprintf('subj%d done \n',s)
        end
        
        % save out results
        save(fullfile(studyDir{2},behavDir,sprintf('%sLearning.mat',sess)),'T');
    case 'PLOT:behavioural'
        sess=varargin{1}; % 'behavioural' or 'scanning'
        type=varargin{2}; % plot 'subject' or 'run'
        
        vararginoptions({varargin{3:end}},{'CAT'}); % option if doing individual map analysis
        
        % load in data
        load(fullfile(studyDir{2},behavDir,sprintf('%sLearning.mat',sess)),'T')
        
        switch type,
            case 'subject'
                lineplot([T.SN], T.numCorr,'subset', T.respMade>0,'CAT',CAT);
                xlabel('Subject')
                ylabel('Percent correct')
            case 'run'
                lineplot([T.runNum], T.numCorr,'subset', T.respMade>0,'CAT',CAT);
                hold on
                CAT.errorcolor={'r'};
                CAT.linecolor={'r'};
                lineplot([T.runNum], T.numCorr,'subset', T.respMade>0 & strcmp(T.taskName,'spatialMap'),'CAT',CAT);
                hold on
                CAT.errorcolor={'g'};
                CAT.linecolor={'g'};
                lineplot([T.runNum], T.numCorr,'subset', T.respMade>0 & strcmp(T.taskName,'emotional'),'CAT',CAT);
                xlabel('Run')
                ylabel('Percent correct')
        end
        
    case 'ACTIVITY:make_model' % make X matrix (feature models)
        study=varargin{1}; % 1, 2, or [1,2]
        model=varargin{2}; % 'full' or 'excludeMotor'
        
        F=dload(fullfile(baseDir,'motorFeats.txt')); % load in motor features
        
        % sort out which study we're taking (or both) ?
        if length(study)>1,
            Fs=F;
        else
            Fs=getrow(F,F.studyNum==study);
        end
        numConds=length(Fs.studyNum);
        
        % rest
        if length(study)>1,
            rest=[29,61];
        else
            rest=numConds;
        end
        
        featNames=Fs.condNames;
        % make feature model
        switch model,
            case 'full'
                x=[eye(numConds) Fs.lHand./Fs.duration Fs.rHand./Fs.duration Fs.saccades./Fs.duration];
                featNames{numConds+1}='lHand';
                featNames{numConds+2}='rHand';
                featNames{numConds+3}='saccades';
            case 'excludeMotor'
                x=[eye(numConds)];
        end
        
        X.x=x;
        X.idx=[1:size(x,1)]';
        
        % normalise features
        X.x   = bsxfun(@minus,X.x,nanmean(X.x));
        X.x   = bsxfun(@rdivide,X.x,sqrt(nansum(X.x.^2)));  % Normalize to unit length vectors
        X=X.x;        

        varargout={X,featNames,numConds,F};
    case 'ACTIVITY:patterns'
        study=varargin{1}; % [1,2]
        lambda=.01;
        model='full';
        
        vararginoptions({varargin{2:end}},{'lambda','model'}); 
        
        % load in activity patterns
        [data,volIndx,V]=sc1_sc2_functionalAtlas('EVAL:get_data',returnSubjs,study,'eval');
        
        % get feature model
        [X,featNames,numConds]=sc1_sc2_functionalAtlas('ACTIVITY:make_model',study,model); % load in model (including motor features)
        
        % regress out motor features
        for s=1:length(returnSubjs),
            B(:,s,:)=(X'*X+eye(size(X,2))*lambda)\(X'*data(:,:,s));
            fprintf('ridge regress done for subj%d done \n',returnSubjs(s))
            
            % evaluate prediction for each subj
            SST = nansum(data(:,:,s).*data(:,:,s));
            u=permute(B(:,s,:),[1 3 2]);
            Ypred(:,:,s)=X*u;
            res =data(:,:,s)-Ypred(:,:,s);
            SSR = nansum(res.^2);
            R2(s) = 1-nansum(SSR)/nansum(SST);
            
        end;
        clear data

        % subtract baseline
        baseline=nanmean(B,1);
        B=bsxfun(@minus,B,baseline);
         
        varargout={B,featNames,numConds,volIndx,V,R2,Ypred};
    case 'ACTIVITY:writeOut_GROUP'
        writeOut=varargin{1}; % 'paper' (average taskConds - SUIT space - metric file)
        % or 'website' (all taskConds - MNI and SUIT space - nifti file)
        study=[1,2];
        
        websiteDir_SUIT=fullfile(baseDir,'website_maps','SUIT_group_contrasts');dircheck(websiteDir_SUIT) % where website contrasts are being saved for SUIT
        websiteDir_MNI=fullfile(baseDir,'website_maps','MNI_group_contrasts');dircheck(websiteDir_MNI) % where website contrasts are being saved for MNI
        suitDir=fullfile(studyDir{2},caretDir,'suit_flat','glm4'); % where figure contrasts are being saved
        
        % get activity patterns
        [B,featNames,numConds,volIndx,V]=sc1_sc2_functionalAtlas('ACTIVITY:patterns',study);
        
        % set up volume info
        Yy=zeros(length(featNames),length(returnSubjs),V.dim(1)*V.dim(2)*V.dim(3));
        C{1}.dim=V.dim;
        C{1}.mat=V.mat;
        
        % make volume
        Yy(:,:,volIndx)=B;
        Yy=permute(Yy,[2 1 3]);
        
        indices=nanmean(Yy,1);
        indices=reshape(indices,[size(indices,2),size(indices,3)]);
        
        % vol data
        indices=reshape(indices,[size(indices,1) V.dim(1),V.dim(2),V.dim(3)]);
        for i=1:size(indices,1),
            data=reshape(indices(i,:,:,:),[C{1}.dim]);
            C{i}.dat=data;
        end
        
        switch writeOut,
            case 'paper'
                % load in task structure file for paper
                F=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
                
                % map vol 2 surf
                S=caret_suit_map2surf(C,'space','SUIT','stats','nanmean','column_names',featNames);  % MK created caret_suit_map2surf to allow for output to be used as input to caret_save
                
                % average shared tasks
                condNumUni=[F.condNumUni;62;63;64];
                 
                X1=indicatorMatrix('identity_p',condNumUni);
                uniqueTasks=S.data*X1; % try pinv here ?
                % get new condNames (unique only)
                condNames=[F.condNames(F.StudyNum==1);F.condNames(F.StudyNum==2 & F.overlap==0)];
                condNames{length(condNames)+1}='lHand';
                condNames{length(condNames)+1}='rHand';
                condNames{length(condNames)+1}='saccades';
                S.data=uniqueTasks;
                S.column_name=condNames';
                S.num_cols=size(S.column_name,2);
                S.column_color_mapping=S.column_color_mapping(1:S.num_cols,:);
                outName='unCorr_avrgTaskConds'; % average of certain tasks

                % save out metric files for paper
                caret_save(fullfile(suitDir,sprintf('%s.metric',outName)),S);
            case 'website'
                % load in task structure file for website
                F=dload(fullfile(baseDir,'website_taskNames.txt'));
                
                exampleVol=fullfile(studyDir{2},'suit','glm4','s02','wdbeta_0001.nii');% must be better way of doing this
                X=spm_vol(exampleVol);
                
                % loop over task conditions
                for c=1:length(C),
                    X.fname=fullfile(websiteDir_SUIT,sprintf('%s.nii',F.condNames{c}));
                    X.private.dat.fname=fullfile(websiteDir_SUIT,sprintf('%s.nii',F.condNames{c}));
                    % normalise to SUIT and MNI
                    spm_write_vol(X,C{c}.dat);
                    cd(websiteDir_SUIT)
                    % normalise to MNI
                    suit_mni2suit(sprintf('%s.nii',F.condNames{c}),'def','suit2mni');
                    fprintf('save out vol in MNI %s \n',F.condNames{c})
                    movefile(sprintf('Ws2m_%s.nii',F.condNames{c}),fullfile(websiteDir_MNI,sprintf('%s.nii',F.condNames{c})))
                    delete(fullfile(websiteDir_SUIT,sprintf('Ws2m_%s.nii',F.condNames{c})));
                end
                
        end
    case 'ACTIVITY:writeOut_INDIV'
        writeOut=varargin{1}; % 'paper' (average taskConds - SUIT space - metric file)
        % or 'website' (all taskConds - MNI and SUIT space - nifti file)
        study=[1,2];
        
        % get activity patterns
        [B,featNames,numConds,volIndx,V]=sc1_sc2_functionalAtlas('ACTIVITY:patterns',study);
        
        
        for s=1:length(returnSubjs),
            
            websiteDir_SUIT=fullfile(baseDir,'website_maps','SUIT_individual_contrasts',subj_name{returnSubjs(s)});dircheck(websiteDir_SUIT) % where website contrasts are being saved for SUIT
            websiteDir_MNI=fullfile(baseDir,'website_maps','MNI_individual_contrasts',subj_name{returnSubjs(s)});dircheck(websiteDir_MNI) % where website contrasts are being saved for MNI
            suitDir=fullfile(studyDir{2},caretDir,sprintf('x%s',subj_name{returnSubjs(s)}),'cerebellum');dircheck(suitDir) % where figure contrasts are being saved
            
            if exist(fullfile(studyDir{2},caretDir,sprintf('x%s',subj_name{returnSubjs(s)}),'cerebellum',sprintf('%s_unCorr_avrgTaskConds.metric',subj_name{returnSubjs(s)})));
                delete(fullfile(studyDir{2},caretDir,sprintf('x%s',subj_name{returnSubjs(s)}),'cerebellum',sprintf('%s_unCorr_avrgTaskConds.metric',subj_name{returnSubjs(s)}))); % average of certain task
            end
            
            % set up volume info
            Yy=zeros(length(featNames),1,V.dim(1)*V.dim(2)*V.dim(3));
            C{1}.dim=V.dim;
            C{1}.mat=V.mat;
            
            % make volume
            Yy(:,:,volIndx)=B(:,s,:);
            Yy=permute(Yy,[2 1 3]);
            
            indices=reshape(Yy,[size(Yy,2),size(Yy,3)]);
            
            % vol data
            indices=reshape(indices,[size(indices,1) V.dim(1),V.dim(2),V.dim(3)]);
            for i=1:size(indices,1),
                data=reshape(indices(i,:,:,:),[C{1}.dim]);
                C{i}.dat=data;
            end
            
            switch writeOut,
                case 'paper'
                    % load in task structure file for paper
                    F=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
                    
                    % map vol 2 surf
                    S=caret_suit_map2surf(C,'space','SUIT','stats','nanmean','column_names',featNames);  % MK created caret_suit_map2surf to allow for output to be used as input to caret_save
                    
                    % average shared tasks
                    condNumUni=[F.condNumUni;62;63;64];
                    X1=indicatorMatrix('identity_p',condNumUni);
                    uniqueTasks=S.data*X1; % try pinv here ?
                    % get new condNames (unique only)
                    condNames=[F.condNames(F.StudyNum==1);F.condNames(F.StudyNum==2 & F.overlap==0)];
                    condNames{length(condNames)+1}='lHand';
                    condNames{length(condNames)+1}='rHand';
                    condNames{length(condNames)+1}='saccades';
                    S.data=uniqueTasks;
                    S.column_name=condNames';
                    S.num_cols=size(S.column_name,2);
                    S.column_color_mapping=S.column_color_mapping(1:S.num_cols,:);
                    outName='unCorr_avrgTaskConds'; % average of certain tasks
                    
                    % save out metric files for paper
                    caret_save(fullfile(suitDir,sprintf('%s.metric',outName)),S);
                case 'website'
                    % load in task structure file for website
                    F=dload(fullfile(baseDir,'website_taskNames.txt'));
                    
                    exampleVol=fullfile(studyDir{2},'suit','glm4','s02','wdbeta_0001.nii');% must be better way of doing this
                    X=spm_vol(exampleVol);
                    
                    % loop over task conditions
                    for c=1:length(C),
                        X.fname=fullfile(websiteDir_SUIT,sprintf('%s.nii',F.condNames{c}));
                        X.private.dat.fname=fullfile(websiteDir_SUIT,sprintf('%s.nii',F.condNames{c}));
                        % normalise to SUIT and MNI
                        spm_write_vol(X,C{c}.dat);
                        cd(websiteDir_SUIT)
                        % normalise to MNI
                        suit_mni2suit(sprintf('%s.nii',F.condNames{c}),'def','suit2mni');
                        fprintf('save out vol in MNI %s \n',F.condNames{c})
                        movefile(sprintf('Ws2m_%s.nii',F.condNames{c}),fullfile(websiteDir_MNI,sprintf('%s.nii',F.condNames{c})))
                        delete(fullfile(websiteDir_SUIT,sprintf('Ws2m_%s.nii',F.condNames{c})));
                    end
            end
            clear Yy C
        end
    case 'ACTIVITY:checkRidge'
        lambda=varargin{1}; 
        
        study=[1,2];
        
        [data]=sc1_sc2_functionalAtlas('EVAL:get_data',returnSubjs,study,'eval');
        [~,~,~,~,~,R2_full,Ypred_full]=sc1_sc2_functionalAtlas('ACTIVITY:patterns',study,'lambda',lambda,'model','full');
        [~,~,~,~,~,R2_noMotor,Ypred_noMotor]=sc1_sc2_functionalAtlas('ACTIVITY:patterns',study,'lambda',lambda,'model','excludeMotor');
        
        % plot pred against data for full and noMotor models
        subplot(2,1,1)
        Ypred=permute(Ypred_full,[1 3 2]); data=permute(data,[1 3 2]);
        plot(nanmean(Ypred,3),nanmean(data,3))
        title('full model')
        text(1,1,sprintf('R^2=%2.3',nanmean(R2_noMotor)));
        subplot(2,1,2)
        Ypred=permute(Ypred_noMotor,[1 3 2]); data=permute(data,[1 3 2]);
        plot(nanmean(Ypred_noMotor,3),nanmean(data,3))
        title('no motor')
        xlabel('Ypred');ylabel('data');text(1,1,sprintf('R^2=%2.3',nanmean(R2_noMotor)));
        
        fprintf('lambda=%2.2f:average prediction of full model across subjects is %2.4f \n',lambda,nanmean(R2_full)); 
        fprintf('lambda=%2.2f: average prediction of noMotor model across subjects is %2.4f \n',lambda,nanmean(R2_noMotor)); 
%          
    case 'ACTIVITY:checkRest_indivSubjects'
        taskConds=[28,31];  % no instruct, no rest
        
        indx=1;
        for study=1:2,
            for s=1:length(returnSubjs),
                
                % load in SPM
                SPM_info=load(fullfile(studyDir{study},'GLM_firstlevel_4',subj_name{returnSubjs(s)},'SPM_info.mat'));
                
                % load in betas (resliced into suit space)
                betaDir=dir(fullfile(studyDir{study},'suit','glm4',subj_name{returnSubjs(s)},'*wdbeta*')); 
                
                % get task conditions
                for c=1:taskConds(study),
                    idx=find(SPM_info.cond==c);
                    Vi=cellstr(char(betaDir(idx).name));
                    taskN=SPM_info.TN{SPM_info.cond==c};
                    
                    cd(fullfile(studyDir{study},'suit','glm4',subj_name{returnSubjs(s)}));
                   
                    % make contrast
                    spm_imcalc(Vi,sprintf('wdcon_%s.nii',taskN),'(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i13+i14+i15+i16)/16');
                    
                    % store contrast name
                    conName{c}=sprintf('wdcon_%s.nii',taskN); 
                end
                
                % calculate average across task conditions (must be better
                % way than manual input)
                if study==1,
                    spm_imcalc(conName','wdcon_taskAvrg.nii','(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i13+i14+i15+i16+i17+i18+i19+i20+i21+i22+i23+i24+i25+i26+i27+i28)/28');
                elseif study==2,
                    spm_imcalc(conName','wdcon_taskAvrg.nii','(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i13+i14+i15+i16+i17+i18+i19+i20+i21+i22+i23+i24+i25+i26+i27+i28+i29+i30+i31)/31');
                end
                
                % calculate rest
                spm_imcalc('wdcon_taskAvrg.nii','wdcon_rest.nii','i1*-1');
                
                % map 2 surf
                data(indx,:)=suit_map2surf('wdcon_rest.nii'); 

                featNames{indx}=sprintf('sc%d-%s-rest',study,subj_name{returnSubjs(s)});
                
                indx=indx+1;
            end
        end
        
         % map vol 2 surf 
         S=caret_struct('metric','data',data','column_name',featNames);

         % save out rest metric file (both sc1 and sc2, all subjs)
         caret_save(fullfile(studyDir{2},caretDir,'suit_flat','glm4','rest_indivSubjs.metric'),S)
    case 'ACTIVITY:checkRest_avrg_taskSet'     
        indx=1;
        for study=1:2,
            for s=1:length(returnSubjs),
                conName{s}=fullfile(studyDir{study},'suit','glm4',subj_name{returnSubjs(s)},'wdcon_rest.nii'); 
            end
            cd(fullfile(studyDir{study},'suit','glm4',subj_name{returnSubjs(s)}))
            % average rest across subjects
                spm_imcalc(conName','wdcon_rest_avrg.nii','(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i13+i14+i15+i16+i17+i18+i19+i20+i21+i22+i23+i24)/24');
                % map 2 surf
                data(indx,:)=suit_map2surf('wdcon_rest_avrg.nii'); 
                delete(fullfile(studyDir{study},'suit','glm4',subj_name{returnSubjs(s)},'wdcon_rest_avrg.nii'));

                featNames{indx}=sprintf('sc%d-rest',study);
                indx=indx+1;
        end
        
         % map vol 2 surf 
         S=caret_struct('metric','data',data','column_name',featNames);

         % save out rest metric file (both sc1 and sc2, all subjs)
         caret_save(fullfile(studyDir{2},caretDir,'suit_flat','glm4','rest_avrg.metric'),S)
         
        
    case 'ACTIVITY:reliability_shared'
        glm=varargin{1};
        type=varargin{2}; % 'cerebellum' or 'cortex' 'basalGanglia'
        
        D=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        
        load(fullfile(studyDir{2},encodeDir,sprintf('glm%d',glm),sprintf('allVox_sc1_sc2_sess_%s.mat',type)));
        Y=Yy;clear Yy;
        
        numSubj=length(Y);
        
        S=[];
        for subj=1:numSubj,
            R=[];
            idx=1;
            for study=1:2,
                D1=getrow(D,D.StudyNum==study);
                sharedConds=D1.condNumUni.*D1.overlap;
                if study==1,
                    condNames=D1.condNames(find(sharedConds));
                end
                % sharedConds=sharedConds(randperm(numel(sharedConds{2}))); % Shuffle
                cN=condNum{study}-1;  % Important: In the allVox file, instruction is still included!
                pN=partNum{study};    % Partition Numner
                sN=(pN>8)+1;          % Sessions Number
                for se=1:2,
                    X1=indicatorMatrix('identity_p',cN.*(sN==se));  % This one is the matrix that related trials-> condition numbers
                    X2=indicatorMatrix('identity_p',sharedConds); % THis goes from condNum to shared condNumUni
                    Yf(:,:,idx,subj)=pinv(X1*X2)*Y{subj}{study};
                    Yf(:,:,idx,subj)=bsxfun(@minus,Yf(:,:,idx,subj),nanmean(Yf(:,:,idx,subj)));
                    idx=idx+1;
                end;
            end;
            for c=1:size(Yf,1),
                CORR(c,:,:,subj)=interSubj_corr(Yf(c,:,:,subj));
                T.SN      = returnSubjs(subj);
                T.within1 = CORR(c,1,2,subj);
                T.within2 = CORR(c,3,4,subj);
                T.across  = nanmean(nanmean(CORR(c,1:2,3:4,subj)));
                T.condNum = c;
                T.condNames={condNames{c}};
                R=addstruct(R,T);
                clear T
            end;
            S=addstruct(S,R);
            clear R
        end;
        save(fullfile(studyDir{2},regDir,'glm4','patternReliability.mat'),'S','CORR')
    case 'ACTIVITY:reliability_overall'
        glm=varargin{1};
        type=varargin{2}; % 'cerebellum' or 'cortex' 'basalGanglia'
        study=varargin{3}; % studyNum = 1 or 2
        
        D=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        
        load(fullfile(studyDir{2},encodeDir,sprintf('glm%d',glm),sprintf('allVox_sc1_sc2_sess_%s.mat',type)));
        Y=Yy;clear Yy;
        
        numSubj=length(Y);
        
        S=[];
        for subj=1:numSubj,
            R=[];
            idx=1;
            D1=getrow(D,D.StudyNum==study);
            %                 sharedConds=D1.condNumUni.*D1.overlap;
            overallConds=D1.condNumUni.*D1.StudyNum;
            if study==1,
                condNames=D1.condNames(find(overallConds));
            end
            % sharedConds=sharedConds(randperm(numel(sharedConds{2}))); % Shuffle
            cN=condNum{study}-1;  % Important: In the allVox file, instruction is still included!
            pN=partNum{study};    % Partition Numner
            sN=(pN>8)+1;          % Sessions Number
            for se=1:2,
                X1=indicatorMatrix('identity_p',cN.*(sN==se));  % This one is the matrix that related trials-> condition numbers
                X2=indicatorMatrix('identity_p',overallConds); % THis goes from condNum to shared condNumUni
                Yf(:,:,idx,subj)=pinv(X1*X2)*Y{subj}{study};
                Yf(:,:,idx,subj)=bsxfun(@minus,Yf(:,:,idx,subj),nanmean(Yf(:,:,idx,subj)));
                idx=idx+1;
            end;
            CORRMatrix=corr(Yf(:,:,1,subj),Yf(:,:,2,subj));
            CORR(:,subj)=diag(CORRMatrix);
            %             for c=1:size(Yf,1),
            %                 CORR(c,:,:,subj)=interSubj_corr_voxel(Yf(c,:,:,subj));
            %                 T.SN      = returnSubjs(subj);
            %                 T.within1 = CORR(c,1,2,subj);
            %                 T.within2 = CORR(c,3,4,subj);
            %                 T.across  = nanmean(nanmean(CORR(c,1:2,3:4,subj)));
            %                 T.condNum = c;
            %                 T.condNames={condNames{c}};
            %                 R=addstruct(R,T);
            %                 clear T
            %             end;
            fprintf('subj%d done',returnSubjs(subj));
        end;
        save(fullfile(studyDir{study},regDir,'glm4','patternReliability_voxel.mat'),'CORR')
    case 'ACTIVITY:modelThresh' % DEPRECIATED CASE
        threshold=0.2;
        
        [B,featNames,V,volIndx]=sc1_sc2_functionalAtlas('ACTIVITY:patterns','group',[1,2],'averageConds');
        
        [RVox]=sc1_sc2_functionalAtlas('PREDICTIONS:datasets','R','run');
        
        % load in task structure file
        F=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        
        subjs=size(B,2);
        numConds=size(B,1);
        P=size(B,3);
        
        % get thresholded R on group
        RVox_group=nanmean(RVox,1);
        volIndx_thresh=find(RVox_group>threshold);
        
        B_thresh=zeros(numConds,subjs,P);
        for s=1:subjs,
            B_thresh(:,s,volIndx_thresh)=B(:,s,volIndx_thresh);
        end
        
        % make volume
        Yy=zeros(numConds,subjs,V.dim(1)*V.dim(2)*V.dim(3));
        for s=1:subjs,
            Yy(:,s,volIndx)=B_thresh(:,s,:);
        end
        Yy=permute(Yy,[2 1 3]);
        
        % set up volume info
        C{1}.dim=V.dim;
        C{1}.mat=V.mat;
        
        indices=nanmean(Yy,1);
        indices=reshape(indices,[size(indices,2),size(indices,3)]);
        
        % map vol2surf
        indices=reshape(indices,[size(indices,1) V.dim(1),V.dim(2),V.dim(3)]);
        for i=1:size(indices,1),
            data=reshape(indices(i,:,:,:),[C{1}.dim]);
            C{i}.dat=data;
        end
        S=caret_suit_map2surf(C,'space','SUIT','stats','nanmean','column_names',featNames);  % MK created caret_suit_map2surf to allow for output to be used as input to caret_save
        
        % get averageConds
        condNumUni=[F.condNumUni;62;63;64];
        X1=indicatorMatrix('identity_p',condNumUni);
        uniqueTasks=S.data*X1; % try pinv here ?
        % get new condNames (unique only)
        condNames=[F.condNames(F.StudyNum==1);F.condNames(F.StudyNum==2 & F.overlap==0)];
        condNames{length(condNames)+1}='lHand';
        condNames{length(condNames)+1}='rHand';
        condNames{length(condNames)+1}='saccades';
        S.data=uniqueTasks;
        S.column_name=condNames';
        S.num_cols=size(S.column_name,2);
        S.column_color_mapping=S.column_color_mapping(1:S.num_cols,:);
        
        % save out metric
        outDir=fullfile(studyDir{2},caretDir,'suit_flat','glm4');
        outName='unCorr_avrgTaskConds_thresh';
        caret_save(fullfile(outDir,sprintf('%s.metric',outName)),S);
    case 'PLOT:reliabilityA'
        % load relability
        load(fullfile(studyDir{2},regDir,'glm4','patternReliability_cerebellum.mat'));
        
        %         figure();lineplot(S.condNum,[S.within1,S.within2,S.across],'leg',{'within1','within2','across'})
        A=tapply(S,{'SN'},{'across'},{'within1'},{'within2'});
        
        % within & between-dataset reliability
        myboxplot([],[A.within1 A.within2 A.across],'style_twoblock','plotall',1);
        drawline(0,'dir','horz');
        ttest(sqrt(A.within1.*A.within2),A.across,2,'paired');
        
        x1=nanmean(A.within1);x2=nanmean(A.within2);x3=nanmean(A.across);
        SEM1=std(A.within1)/sqrt(length(returnSubjs));SEM2=std(A.within2)/sqrt(length(returnSubjs));SEM3=std(A.across)/sqrt(length(returnSubjs));
        fprintf('average corr for set A is %2.3f; CI:%2.3f-%2.3f \n average corr for set B is %2.3f; CI:%2.3f-%2.3f and average corr across sets A and B is %2.3f; CI:%2.3f-%2.3f \n',...
            x1,x1-(1.96*SEM1),x1+(1.96*SEM1),x2,...
            x2-(1.96*SEM2),x2+(1.96*SEM2),...
            x3,x3-(1.96*SEM3),x3+(1.96*SEM3));
    case 'PLOT:reliability_voxel'
        
        for sess=1:2,
            load(fullfile(studyDir{sess},regDir,'glm4','patternReliability_voxel.mat'))
            data(:,sess)=nanmean(CORR,2);
            clear CORR
        end
        
        % get average across task sets
        data_average=nanmean(data,2);
        data_average=data_average';
        
        [~,~,~,idx]=sc1_sc2_functionalAtlas('PREDICTIONS:datasets','R','run');
        
        V=spm_vol(fullfile(studyDir{1},suitDir,'anatomicals','cerebellarGreySUIT.nii'));
        C{1}.dim=V.dim;
        C{1}.mat=V.mat;
        
        Yy=zeros(size(data_average,1),V.dim(1)*V.dim(2)*V.dim(3));
        
        % make vol
        Yy(:,idx)=data_average;
        
        % get avrg across subjs
        indices=nanmean(Yy,1);
        
        % map vol2surf
        data=reshape(indices,[V.dim(1),V.dim(2),V.dim(3)]);
        C{1}.dat=data;
        
        M=caret_suit_map2surf(C,'space','SUIT','stats','nanmean');  % MK created caret_suit_map2surf to allow for output to be used as input to caret_save
        
        % save out metric
        caret_save(fullfile(studyDir{2},caretDir,'suit_flat','glm4','voxel_reliability.metric'),M);
        
    case 'PREDICTIONS:taskModel' % DEPRECIATED. ACTIVITY:make_model needs to be modified for this function to work.
        sn=varargin{1}; % returnSubjs
        study=varargin{2}; % 1 or 2
        partition=varargin{3}; % session or run
        
        lambdas=[.01:.1:.5];
        subjs=length(sn);
        l=1;
        
        % load X
        [Xx,~,numConds]=sc1_sc2_functionalAtlas('ACTIVITY:make_model',study,'yes');
        
        % loop over subjects
        Ys=[];
        for s=1:subjs,
            
            encodeSubjDir = fullfile(studyDir{study},encodeDir,'glm4',subj_name{sn(s)}); % set directory
            
            % load Y (per subj)
            load(fullfile(encodeSubjDir,'Y_info_glm4_grey_nan.mat'));
            Yp=getrow(Y,Y.cond~=0);
            
            switch partition,
                case 'run'
                    part=Yp.run;
                    block=run;
                case 'session'
                    part=Yp.sess;
                    block=[1,2]; % session
            end
            
            % normalise (either by run or by session)
            N = (numConds)*numel(run);
            B = indicatorMatrix('identity',part);
            R  = eye(N)-B*pinv(B);
            X = R*Xx;            % Subtract block mean (from X)
            X=bsxfun(@rdivide,X,sqrt(sum(X.*X)/(size(X,1)-numel(block))));
            Yact = R*Yp.data;    % Subtract block mean (from Y)
            Yact=bsxfun(@rdivide,Yact,sqrt(sum(Yact.*Yact)/(size(Yact,1)-numel(block))));
            
            % run encoding model (with ridge regress)
            [M.R2_vox,M.R_vox]=encode_crossval(Yact,X,part,'ridgeFixed','lambda',lambdas(l));
            
            fprintf('subj%d:model done ...\n',sn(s))
            
            M.SN=sn(s);
            M.idx=Yp.nonZeroInd(1,:);
            Ys=addstruct(Ys,M);
            clear Yp
        end
        
        % save out results
        save(fullfile(studyDir{study},encodeDir,'glm4',sprintf('encode_taskModel_cerebellum_%s.mat',partition)),'Ys','-v7.3');
    case 'PREDICTIONS:datasets' % get predictions across datasets
        stat=varargin{1}; % 'R' or 'R2' ?
        partition=varargin{2}; % cv across 'run' or 'session' ?
        
        F=dload(fullfile(baseDir,'motorFeats.txt')); % load in motor features
        
        YN=[];
        for i=1:2,
            numCond=length(F.condNum(F.studyNum==i));
            load(fullfile(studyDir{i},encodeDir,'glm4',sprintf('encode_taskModel_%s.mat',partition)))
            Ys.study=repmat(i,size(Ys.SN,1),1);
            YN=addstruct(YN,Ys);
        end
        X=indicatorMatrix('identity_p',YN.SN);
        
        % which stat: R or R2 ?
        switch stat,
            case 'R'
                data=YN.R_vox;
            case 'R2'
                data=YN.R2_vox;
        end
        
        % get average of models across datasets
        RVox=pinv(X)*data;
        RVox_sc1=nanmean(nanmean(data(YN.study==1,:)));
        RVox_sc2=nanmean(nanmean(data(YN.study==2,:)));
        
        varargout={RVox,RVox_sc1,RVox_sc2,YN.idx(1,:)};
    case 'PREDICTIONS:vol2surf' % visualise predictions for motor feats
        stat=varargin{1}; % 'R' or 'R2' ?
        partition=varargin{2}; % cv across 'run' or 'session' ?
        
        [RVox,RVox_sc1,RVox_sc2,idx]=sc1_sc2_functionalAtlas('PREDICTIONS:datasets',stat,partition);
        
        % what is within task set reliability ?
        fprintf('set A reliability is %2.3f \n',RVox_sc1);
        fprintf('set B reliability is %2.3f \n',RVox_sc2);
        
        SN=length(returnSubjs);
        
        V=spm_vol(fullfile(studyDir{1},suitDir,'anatomicals','cerebellarGreySUIT.nii'));
        C{1}.dim=V.dim;
        C{1}.mat=V.mat;
        
        Yy=zeros(size(RVox,1),V.dim(1)*V.dim(2)*V.dim(3));
        
        % make vol
        Yy(:,idx)=RVox;
        
        % get avrg across subjs
        indices=nanmean(Yy,1);
        
        % map vol2surf
        data=reshape(indices,[V.dim(1),V.dim(2),V.dim(3)]);
        C{1}.dat=data;
        
        M=caret_suit_map2surf(C,'space','SUIT','stats','nanmean');  % MK created caret_suit_map2surf to allow for output to be used as input to caret_save
        
        % save out metric
        caret_save(fullfile(studyDir{2},caretDir,'suit_flat','glm4','taskModel.metric'),M);
        
    case 'RELIABILITY:get_spatialFreq'
        study=varargin{1};
        frequencyBands  = [0 0.5 1 1.5 2 inf];
        load(fullfile(studyDir{study},'encoding','glm4','cereb_avrgDataStruct.mat'));
        RR=[];
        sn=unique(T.SN);
        for s = 1:length(sn)
            fprintf('subject %d\n',sn(s));
            for se=1:2
                S=getrow(T,T.SN == sn(s) & T.sess==se);
                for c=1:max(T.cond)
                    X=zeros(V.dim);
                    X(volIndx)=S.data(c,:);
                    X(isnan(X))=0;
                    % Y=mva_frequency3D(X,frequencyBands,'Voxelsize',[2 2 2],'plotSlice',15);
                    Y=mva_frequency3D(X,frequencyBands,'Voxelsize',[2 2 2]);
                    R=getrow(S,c);
                    for f=1:size(Y,4);
                        YY=Y(:,:,:,f);
                        R.data=YY(volIndx);
                        R.freq = f;
                        R.freqLow = frequencyBands(f);
                        RR=addstruct(RR,R);
                    end;
                end;
            end;
        end;
        save(fullfile(studyDir{study},'encoding','glm4','cereb_avrgDataStruct_freq.mat'),'-struct','RR');
    case 'RELIABILITY:spatialFreqCorr'
        study = [1 2]; % %experiment
        glm   = 'glm4';
        
        vararginoptions(varargin,{'study','glm'});
        C=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        A=[];
        for e=study
            T=load(fullfile(studyDir{e},'encoding',glm,'cereb_avrgDataStruct_freq.mat'));
            D=load(fullfile(studyDir{e},'encoding',glm,'cereb_avrgDataStruct.mat'));
            D.T.freq = ones(length(D.T.SN),1)*0;
            D.T.freqLow = -1*ones(length(D.T.SN),1);
            T=addstruct(T,D.T);
            T.study = ones(length(T.SN),1)*e;
            % Recenter Data and combine
            commonCond = C.condNum(C.StudyNum==e & C.overlap==1);
            for sn = unique(T.SN)'
                for se = unique(T.sess)'
                    for f = unique(T.freq)'
                        i = find(T.SN==sn & T.sess==se & T.freq==f);
                        j = find(T.SN==sn & T.sess==se & T.freq==f & ismember(T.cond,commonCond));
                        T.data(i,:)=bsxfun(@minus,T.data(i,:),nanmean(T.data(j,:)));
                    end;
                end;
            end;
            A=addstruct(A,T);
        end;
        
        % before - code below was computing corr on study 2 only (structure
        % was T instead of A)
        D=[];
        sn=unique(A.SN);
        numSubj = length(sn);
        SS=[];
        for st=1:2, % loop over studies
            RR=[];
            for f=unique(A.freq)', % loop over frequencies
                for s = 1:numSubj  % loop over subjects
                    for se=1:2     % loop over sessions
                        temp = A.data(A.study==st & A.SN==sn(s) & A.sess==se & A.freq==f,:);
                        %                         temp = bsxfun(@minus,temp,mean(temp));
                        D(:,:,s+(se-1)*length(sn))=temp;
                    end;
                end;
                C=intersubj_corr(D);
                R.sess = [ones(1,numSubj) ones(1,numSubj)*2]';
                R.subj = [1:numSubj 1:numSubj]';
                R.subj = sn(R.subj);
                R.freq = f*ones(numSubj*2,1);
                R.study= st*ones(numSubj*2,1);
                SameSess = bsxfun(@eq,R.sess',R.sess);
                SameSubj = bsxfun(@eq,R.subj',R.subj);
                for i=1:numSubj*2;
                    R.withinSubj(i,:)=C(i,SameSubj(i,:) & ~SameSess(i,:));
                    R.betweenSubj(i,:)=mean(C(i,~SameSubj(i,:)));
                    R.totSS(i,1) = nansum(nansum(D(:,:,i).^2));
                end;
                RR=addstruct(RR,R);
            end;
            clear temp D R
            SS=addstruct(SS,RR);
        end
        save(fullfile(studyDir{2},'encoding','glm4','cereb_spatialCorr_freq.mat'),'-struct','SS');
        varargout={SS};
    case 'PLOT:spatialFreqCorr'
        CAT=varargin{1};
        
        % load in spatialCorrFreq struct
        T=load(fullfile(studyDir{2},'encoding','glm4','cereb_spatialCorr_freq.mat'));
        
        xlabels={'overall','0-0.5','0.5-1','1-1.5','1.5-2','>2'};
        
        T=tapply(T,{'subj','freq'},{'withinSubj'},{'betweenSubj'},{'totSS'},'subset',ismember(T.subj,returnSubjs));
        T.freqK = T.freq>0;
        [ss,sn]=pivottable(T.subj,[],T.totSS,'mean','subset',T.freq==0);
        a(sn,1)=ss;
        T.relSS=T.totSS./a(T.subj);
        lineplot([T.freqK T.freq],[T.relSS],'CAT',CAT);
        set(gca,'XTickLabel',xlabels,'YLim',[0 0.35]);
        ylabel('Relative Power');
        xlabel('Cycles/cm');
        title('Relative amount of Variance per Frequency band');
    case 'PLOT:interSubjCorr'
        CAT=varargin{1};
        
        % load in spatialCorrFreq struct
        T=load(fullfile(studyDir{2},'encoding','glm4','cereb_spatialCorr_freq.mat'));
        
        T=tapply(T,{'subj','freq'},{'withinSubj'},{'betweenSubj'},{'totSS'},'subset',ismember(T.subj,returnSubjs));
        T.freqK = T.freq>0;
        lineplot([T.freqK T.freq],[T.withinSubj T.betweenSubj],'CAT',CAT,'leg','auto');
        
    case 'REPRESENTATION:get_distances'
        type=varargin{1}; % 'cerebellum'
        removeMotor=varargin{2}; % 'hands','saccades','all','none'
        taskType=varargin{3}; % 'unique' or 'all' task conditions ?
        
        load(fullfile(studyDir{2},regDir,'glm4',sprintf('G_hat_sc1_sc2_%s.mat',type)))
        subjs=size(G_hat,3);
        
        % load in condName info
        T=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        
        % load feature matrix
        F=dload(fullfile(baseDir,'motorFeats.txt')); % load in motor features
        
        % get unique tasks
        switch taskType,
            case 'unique'
                X1=indicatorMatrix('identity_p',T.condNumUni);
                for s=1:subjs,
                    G(:,:,s)=X1'*(G_hat(:,:,s)*X1);
                end
                condNames=[T.condNames(T.StudyNum==1);T.condNames(T.StudyNum==2 & T.overlap==0)];
            case 'all'
                G=G_hat;
                condNames=T.condNames;
        end
        numDist=size(G,1);
        
        switch removeMotor,
            case 'all'
                X   = [F.lHand./F.duration F.rHand./F.duration F.saccades./F.duration];
            case 'none'
                X   = [];
        end
        
        % get unique taskConds
        if strcmp(taskType,'unique'),
            X   = pivottablerow(T.condNumUni,X,'mean(x,1)');
        end
        
        X   = [X eye(numDist)];
        X   = bsxfun(@minus,X,mean(X));
        X   = bsxfun(@rdivide,X,sqrt(sum(X.^2)));  % Normalize to unit length vectors
        
        % Get RDM
        for s=1:subjs,
            H=eye(numDist)-ones(numDist)/numDist; % centering matrix
            G(:,:,s)=H*G(:,:,s)*H'; % subtract out mean pattern
            IPM=rsa_vectorizeIPM(G(:,:,s));
            con = indicatorMatrix('allpairs',[1:numDist]);
            N = rsa_squareIPM(IPM);
            D = rsa.rdm.squareRDM(diag(con*N*con'));
            fullRDM(:,:,s) = D;
        end
        
        varargout={fullRDM,condNames,X,taskType};
    case 'REPRESENTATION:reliability'
        glm=varargin{1};
        type=varargin{2}; % 'cerebellum'
        % example 'sc1_sc2_imana('CHECK:DIST',4,'cerebellum')
        
        load(fullfile(regDir,sprintf('glm%d',glm),sprintf('G_hat_sc1_sc2_sess_%s.mat',type)));
        D=dload('sc1_sc2_taskConds.txt');
        D1=getrow(D,D.StudyNum==1);
        D2=getrow(D,D.StudyNum==2);
        
        % Look at the shared conditions only
        i1 = find(D1.overlap==1);
        i2 = find(D2.overlap==1);
        [~,b] = sort(D2.condNumUni(i2));     % Bring the indices for sc2 into the right order.
        i2=i2(b);
        numCond = length(i1);
        numSubj = size(G_hat_sc1,4);
        numSess = 2;
        
        C=indicatorMatrix('allpairs',[1:numCond]);
        for i=1:numSubj
            for j=1:numSess,
                dist(:,j  ,i)  = ssqrt(diag(C*G_hat_sc1(i1,i1,j,i)*C'));
                dist(:,j+2,i)  = ssqrt(diag(C*G_hat_sc2(i2,i2,j,i)*C'));
            end;
            CORR(:,:,i)    = corr(dist(:,:,i));
            T.SN(i,1)      = i;
            T.within1(i,1) = CORR(1,2,i);
            T.within2(i,1) = CORR(3,4,i);
            T.across(i,1)  = mean(mean(CORR(1:2,3:4,i)));
        end;
        
        save(fullfile(studyDir{2},regDir,'glm4',sprintf('distanceReliability_%s.mat'),type),'T','dist')
    case 'REPRESENTATION:eigDecomp'
        CAT=varargin{1};
        % load in condName info
        T=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        load(fullfile(studyDir{2},regDir,'glm4',sprintf('G_hat_sc1_sc2_%s.mat','cerebellum')))
        
        %                 R=[];
        %                 for s=1:2,
        %                     SC=getrow(T,T.StudyNum==s);
        %                     idx=SC.condNum;
        %                     numDist=length(idx);
        %                     avrgG_hat=nanmean(G_hat(idx,idx),3);
        %                     H=eye(numDist)-ones(numDist)/length(numDist);
        %                     avrgG_hat=(H*avrgG_hat*H);  % center G matrix
        %
        %                     [V,L]   = eig(avrgG_hat);
        %                     [l,i]   = sort(diag(L),1,'descend');
        %                     S.study=repmat(s,length(i),1);
        %                     S.eig=real(l);
        %                     R=addstruct(R,S);
        %                 end
        %                   lineplot([1:size(R.study,1)]',R.eig,'split',R.study,'CAT',CAT);
        idx=T.condNum;
        numDist=length(idx);
        avrgG_hat=nanmean(G_hat(idx,idx),3);
        H=eye(numDist)-ones(numDist)/length(numDist);
        avrgG_hat=(H*avrgG_hat*H);  % center G matrix
        
        [V,L]   = eig(avrgG_hat);
        [l,i]   = sort(diag(L),1,'descend');
        S.eig=real(l);
        S.idx=i;
        
        lineplot(S.idx,S.eig,'CAT',CAT)
    case 'REPRESENTATION:RDM'
        taskType=varargin{1}; % 'unique' or 'all' tasks
        
        threshold=.001;
        
        condNames={'1.No-Go','2.Go','3.Theory of Mind','4.Action Observation','5.Video Knots','6.IAPS Unpleasant',...
            '7.IAPS Pleasant','8.Math','9.Digit Judgement','10.Objects','11.IAPS Sad','12.IAPS Happy','13.Interval Timing',...
            '14.Motor Imagery','15.Finger Simple','16.Finger Sequence','17.Verbal 0Back','18.Verbal 2Back','19.Object 0Back',...
            '20.Object 2Back','21.Spatial Navigation','22.Stroop Incongruent','23.Stroop Congruent','24.Verb Generation',...
            '25.Word Reading','26.Visual Search Small','27.Visual Search Medium','28.Visual Search Hard','29.Rest','30.CPRO','31.Prediction',...
            '32.Prediction Violated','33.Prediction Scrambled','34.Spatial Map Easy','35.Spatial Map Medium','36.Spatial Map Hard',...
            '37.Nature Movie','38.Animated Movie','39.Landscape Movie','40.Mental Rotation Easy','41.Mental Rotation Medium',...
            '42.Mental Rotation Hard','43.Biological Motion','44.Scrambled Motion','45.Response Alt Easy','46.Response Alt Medium','47.Response Alt Hard'};
        
        % load in fullRDM
        [fullRDM,~]=sc1_sc2_functionalAtlas('REPRESENTATION:get_distances','cerebellum','all',taskType); % remove all motorFeats
        
        numDist=size(fullRDM,1);
        
        % Plot RDM
        switch taskType,
            case 'unique',
                reOrder=[1:5,8:10,14:18,21,24,25,29,30,34:39,6,7,11,12,19,20,13,31:33,26:28,22,23,40:47];
            case 'all',
                reOrder=[1,2,6,7,8,9,10,11,12,13,14,17,18,22,23,3,4,5,15,16,19,20,21,24,25,26,...
                    27,28,29,58,59,60,43,44,49,48,36,34,35,55,56,57,61,30,31,32,33,37,38,39,40,41,42,45,46,47,50,51,52,53,54]'; % reorder
        end
        
        % reorder RDM
        fullRDM=fullRDM(reOrder,reOrder,:);
        
        % threshold RDM
        fullRDM_thresh=reshape(fullRDM,[size(fullRDM,1)*size(fullRDM,2)],[]);
        for dd=1:size(fullRDM_thresh,1),
            [t(dd),p(dd)]=ttest(fullRDM_thresh(dd,:),[],1,'onesample');
        end
        ut=t; % unthresholded distances
        
        % uncorrected p-vals
        t(p>threshold)=0; % thresholded distances
        
        % zero the nan values
        t(isnan(t))=0;
        ut(isnan(ut))=0;
        
        fprintf('%2.2f%% of the pairwise distances are significantly different from zero \n',(length(t(t>0))/length(t))*100);
        
        % visualise thresholded RDM (t-values)
        squareT=tril(reshape(t,[size(fullRDM,1),size(fullRDM,2)]));
        squareUT=reshape(ut,[size(fullRDM,1),size(fullRDM,2)]);
        idxUT=find(triu(squareUT));
        squareT(idxUT)=squareUT(idxUT);
        figure();imagesc_rectangle(abs(squareT),'YDir','reverse')
        caxis([0 1]);
        g=set(gca,'Ytick',[1:numDist]','YTickLabel',condNames(reOrder),'FontSize',7);
        g.Color='white';
        colorbar
    case 'REPRESENTATION:MDS'
        taskType=varargin{1}; % 'unique' or 'all' tasks
        clustering=varargin{2}; % 'distance' or 'region'
        
        mapType='SC12_cnvf_10';
        algorithm='cnvf';
        
        % colour
        colour={[1 0 0],[0 1 0],[0 0 1],[0.3 0.3 0.3],[1 0 1],[1 1 0],[0 1 1],...
            [0.5 0 0.5],[0.8 0.8 0.8],[.07 .48 .84],[.99 .76 .21],[.11 .7 .68],...
            [.39 .74 .52],[.21 .21 .62],[0.2 0.2 0.2],[.6 .6 .6],[.3 0 .8],[.8 0 .4],...
            [0 .9 .2],[.1 .3 0],[.2 .4 0],[.63 0 .25],[0 .43 .21],[.4 0 .8]};
        
        vararginoptions({varargin{3:end}},{'CAT','colour'}); % option if doing individual map analysis
        
        % load in fullRDM
        [fullRDM,condNames,X,taskType]=sc1_sc2_functionalAtlas('REPRESENTATION:get_distances','cerebellum','all',taskType); % remove all motorFeats
        condIndx=1:length(condNames);
        
        % load in condName info
        T=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        
        avrgFullRDM=ssqrt(nanmean(fullRDM,3));
        
        vecRDM = rsa.rdm.vectorizeRDM(avrgFullRDM);
        [Y,~] = rsa_classicalMDS(vecRDM,'mode','RDM');
        B = (X'*X+eye(size(X,2))*0.0001)\(X'*Y); % ridge regression
        Yr    = Y  - X(:,1:3)*B(1:3,:); % remove motor features
        
        % define cluster colour
        [V,L]   = eig(Yr*Yr');
        [l,i]   = sort(diag(L),1,'descend'); % Sort the eigenvalues
        V       = V(:,i);
        X       = bsxfun(@times,V,sqrt(l'));
        X = real(X);
        
        switch clustering,
            case 'distance'
                clustTree = linkage(Yr,'average');
                indx = cluster(clustTree,'cutoff',1);
            case 'region'
                load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapType),sprintf('%s.mat',algorithm)));
                cmap=load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapType),'colourMap.txt'));
                
                % assign each task to a cluster
                if strcmp(taskType,'unique'),
                    bestF=pivottablerow(T.condNumUni,bestF,'mean(x,1)');
                end
                
                [x,indx]=max(bestF,[],2);
                
                % set threshold for tasks close to zero
                indx(x<.155)=11;
                
                colour=num2cell(cmap(:,2:4)/255,2)';
                colour{11}=[.8275 .8275 .8275]; % set grey
        end
        
        CAT.markercolor= {colour{indx}};
        CAT.markerfill = {colour{indx}};
        CAT.labelcolor = {colour{indx}};
        
        X1=X(condIndx,condIndx);
        figure()
        %         scatterplot3(X1(:,1),X1(:,2),X1(:,3),'split',condIndx','CAT',CAT,'label',condNames);
        %         set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[],'Box','on');
        
        %         scatterplot3(X1(:,1),X1(:,2),X1(:,3),'split',condIndx','CAT',CAT,...
        %             'labelcolor',CAT.labelcolor,'label',condNames,'markersize',6,'labelsize',14);
        %         set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[],'Box','on');
        
        
        scatterplot3(X1(:,1),X1(:,2),X1(:,3),'split',condIndx','CAT',CAT,'markersize',6);
        set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[],'Box','on');
        
        hold on;
        plot3(0,0,0,'+');
        % Draw connecting lines
        %         for i=1:15,
        %             ind=clustTree(i,1:2);
        %             X(end+1,:)=(X(ind(1),:)+X(ind(2),:))/2;
        %             line(X(ind,1),X(ind,2),X(ind,3));
        %         end;
        hold off;
        clear X1  indxShort
    case 'PLOT:reliabilityD'
        % load relability
        load(fullfile(studyDir{2},regDir,'glm4','distanceReliability_cerebellum.mat'));
        
        % within & between-subj reliability
        myboxplot([],[T.within1 T.within2 T.across],'style_twoblock','plotall',1);
        ttest(sqrt(T.within1.*T.within2),T.across,2,'paired');
        
    case 'CONVERT:mni2suit'    % converts from mni image to SUIT (there's also a cifti2nii if image is coming from HCP)
        inputImages={'N2C_subcortex_atlas_subcortexGSR.nii',...
            'Buckner2011_7Networks_MNI152_FreeSurferConformed1mm_TightMask.nii'};
        
        inputDir=which(inputImages{2});
        cd(fileparts(inputDir))
        suit_mni2suit(inputImages{2})
    case 'CONVERT:cifti2suit'  % puts cifti files into nii format (for cerebellum)
        %         inputImages={'subcortex_atlas_subcortexGSR.dlabel.nii'};
        
        %         inputImages={'final_LR_subcortex_atlas_subcortexGSR.dlabel.nii'};
        ciftiImage={'subcortex_atlas_ConjunctionGSRnoGSR_n.dlabel.nii'};
        %         mniImage={'Cole_Anticevic_2018C2N_final_LR_subcortex_atlas_subcortexGSR.nii'};
        mniImage={'Cole_Anticevic_2018C2N_subcortex_atlas_ConjunctionGSRnoGSR_n.nii'};
        
        inputImage=which(ciftiImage{1});
        cd(fileparts(inputImage))
        
        % convert from cifti 2 nifti
        cifti2nifti(inputImage);
        
        % normalise into suit space
        suit_mni2suit(mniImage{1});
    case 'CONVERT:makelob10'   % this makes lob10 map out of lob26 map
        V=spm_vol(fullfile(studyDir{2},'encoding','glm4','groupEval_lob26','map.nii'));
        Vi=spm_read_vols(V);
        
        % consolidate lob26 into lob10 (clunky but works)
        labelsOld=[0:34];
        labelsNew=[0,1,1,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,0,0,0,0,0,0];
        
        tmp=Vi(:);
        for l=1:length(labelsOld),
            tmp(tmp==labelsOld(l))=labelsNew(l);
        end
        
        % reconstruct and write out to volume
        Vi=reshape(tmp,[V.dim]);
        outName=(fullfile(studyDir{2},'encoding','glm4','groupEval_lob10')); dircheck(outName)
        V.fname=fullfile(outName,'map.nii');
        spm_write_vol(V,Vi);
    case 'CONVERT:toGifti'
        inputMap=varargin{1};
        
        % load in any nifti file
        inputDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',inputMap));
        mapName='map.nii';
        
        % rename 10cluster to MDTB
        if strcmp(inputMap,'SC12_10cluster'),
            outName='MDTB';
        end
        
        Vo=spm_vol(fullfile(inputDir,mapName));
        Vi=spm_read_vols(Vo);
        Vv{1}.dat=Vi;
        Vv{1}.dim=Vo.dim;
        Vv{1}.mat=Vo.mat;
        
        % get surface info
        M=caret_suit_map2surf(Vv,'space','SUIT','stats','none','depths',[0 .2 .4 .6 .8 1],'column_names',{'MDTB'});
        M.data=round(M.data);
        S=caret_suit_map2surf(Vv,'space','SUIT','stats','mode','column_names',{'MDTB'});
        
        % colours
        cd(inputDir);
        cmap=load('colourMap.txt');
        cmap=cmap(:,2:4);
        cmapF=cmap/255;
        cmapF(:,4)=1;
        
        % convert to gifti
        G.cdata=[M.data S.data];
        G.cdata=int32(G.cdata);
        %         G.labels.name=[M.column_name S.column_name];
        G.labels.key=[0:size(G.cdata,2)];
        G.labels.rgba=cmapF;
        G.labels.rgba(1,4)=0;
        
        % numRegions
        numReg=max(unique(G.cdata(:,1)));
        for i=1:numReg,
            G.labels.name{:,i}=sprintf('region%d',i);
        end
        G.labels.key=[0:9];
        
        S=gifti(fullfile(atlasDir,'suit_flat','Cerebellum-lobules.label.gii'));
        
        cd('/Users/maedbhking/Documents/MATLAB/imaging/Connectome_WorkBench/cifti-matlab-master/@gifti')
        save(S,'tmp.gii');
    case 'CONVERT:toMNI'
        inputMap=varargin{1};
        
        fileDir=which(sprintf('%s.nii',inputMap));
        cd(fileDir);
        
        suit_mni2suit(sprintf('%s.nii',inputMap),'def','suit2mni');
        
    case 'HCP:get_data'
        % load in HCP vol data
        HCPDir=fullfile(atlasDir,'HCP/');
        cd(HCPDir);
        HCPFiles=dir('*HCP_*');
        
        % get V and volIndx
        load(fullfile(studyDir{2},'encoding','glm4','cereb_avrgDataStruct.mat'));
        
        % get HCP contrasts
        for i=1:length(HCPFiles),
            VA{i}=spm_vol(fullfile(HCPDir,HCPFiles(i).name));
        end
        
        % now sample the contrasts into the same space
        [i,j,k]=ind2sub(V.dim,volIndx);
        [x,y,z]=spmj_affine_transform(i,j,k,V.mat);
        [i1,j1,k1]=spmj_affine_transform(x,y,z,inv(VA{1}.mat));
        for i=1:length(VA),
            map(i,:) = spm_sample_vol(VA{i},i1,j1,k1,0);
            colNames{i,1}=HCPFiles(i).name(5:end-9);
        end
        
        % normalise data
        X_C=bsxfun(@minus,map,nanmean(map));
        
        C{1}.dim=V.dim;
        C{1}.mat=V.mat;
        
        % make volume
        Vi=zeros(size(map,1), [V.dim(1)*V.dim(2)*V.dim(3)]);
        Vi(:,volIndx)=map;
        
        % map vol2surf
        for i=1:size(map,1),
            data=reshape(Vi(i,:,:,:),[C{1}.dim]);
            C{i}.dat=data;
        end
        S=caret_suit_map2surf(C,'space','SUIT','stats','nanmean','column_names',colNames);  % MK created caret_suit_map2surf to allow for output to be used as input to caret_save
        
        caret_save(fullfile(HCPDir,'HCPContrasts.metric'),S);
        varargout={X_C,colNames};
    case 'HCP:make_mask'
        HCPDir=fullfile(atlasDir,'HCP/');
        cd(HCPDir);
        HCPFiles=dir('*HCP_*');
        
        for i=1:length(HCPFiles),
            nam{i}=fullfile(fullfile(HCPDir,HCPFiles(i).name));
        end
        opt.dmtx = 1;
        spm_imcalc(nam,'average_HCP.nii','mean(X)',opt);
    case 'HCP:mapOptimal'
        algorithmString = {'snn','cnvf','ica'}; % Semi-nonengative matrix factorization
        algorithm = 2;
        K=10; % number of regions
        G0 = [];          % Starting value for weights
        
        tol_rand = 0.90;    % Tolerance on rand coefficient to call it the same solution
        maxStart=100;       % How many starts maximally?
        numCount=5;         % For how many starting values do we need to find the same solution?
        maxIter = 100;      % How many iterations per starting value
        
        % atlas dir
        HCPDir=fullfile(atlasDir,'HCP/');
        
        % get V and volIndx
        load(fullfile(studyDir{2},'encoding','glm4','cereb_avrgDataStruct.mat'));
        
        % get data
        [X_C]=sc1_sc2_functionalAtlas('HCP:get_data');
        
        outDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_HCP_%s_%d',algorithmString{algorithm},K));
        dircheck(outDir);
        outName=fullfile(outDir,sprintf('%s.mat',algorithmString{algorithm}));
        
        % Intialize iterations[G
        bestErr = inf;
        bestSol = ones(size(X_C,2),1);
        iter=1; % How many iterations
        count=0;
        while iter<=maxStart,
            switch (algorithm)
                case 1
                    [F,G,Info]=semiNonNegMatFac(X_C,K,'threshold',0.01); % get a segmentation using
                case 2 % convec
                    [F,G,Info]=cnvSemiNonNegMatFac(X_C,K,'threshold',0.01,'maxIter',maxIter,'G0',G0); % get a segmentation using
            end;
            errors(iter)=Info.error;    % record error
            [~,winner]=max(G,[],2);     % determine the highest loading cluster for each voxel
            randInd(iter)=RandIndex(bestSol,winner); %
            
            % Check if we have a similar solution
            if randInd(iter)>tol_rand % Similar solution
                count=count+1;       % count up one
                if (Info.error<bestErr)  % If we got slightly better - update
                    bestErr = Info.error;
                    bestSol = winner;
                    bestG   = G;
                    bestF   = F;
                    bestInfo = Info;
                end;
            else                     % Different (enough) solution
                if (Info.error<bestErr) % Is this a better solution
                    bestErr = Info.error;
                    bestSol = winner;
                    bestG   = G;
                    bestF   = F;
                    bestInfo = Info;
                    count = 0;         % first time we found this solution: reset counter
                end;
            end;
            fprintf('Error: %2.2f Rand:%2.2f, Best:%2.2f currently found %d times\n',errors(iter),randInd(iter),bestErr,count);
            if count>=numCount || iter>=maxIter,
                fprintf('Existing loop....\n');
                break;
            end;
            iter=iter+1;
        end;
        save(outName,'bestG','bestF','bestInfo','errors','randInd','iter','count','volIndx','V');
    case 'HCP:visualise'
        mapType=varargin{1}; % '<dataSet>_<algorithm>_<clusterNum>' example: 'SC12_cnvf_10'
        
        if strfind(mapType,'SNN'),
            algorithm='SNN';
        else
            algorithm='cnvf';
        end
        
        load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),sprintf('%s.mat',algorithm)));
        outName=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'map.nii');
        
        [x,groupFeat]=max(bestG,[],2);
        
        % map features on group
        Yy=zeros(1,V.dim(1)*V.dim(2)*V.dim(3));
        Yy(1,volIndx)=groupFeat;
        Yy=reshape(Yy,[V.dim(1),V.dim(2),V.dim(3)]);
        Yy(Yy==0)=NaN;
        Vv{1}.dat=Yy;
        Vv{1}.dim=V.dim;
        Vv{1}.mat=V.mat;
        
        % save out vol of SNN feats
        exampleVol=fullfile(studyDir{2},suitDir,'glm4','s02','wdbeta_0001.nii'); % must be better way ??
        X=spm_vol(exampleVol);
        X.fname=outName;
        X.private.dat.fname=V.fname;
        spm_write_vol(X,Vv{1}.dat);
        
        %         sc1_sc2_functionalAtlas('MAP:vol2surf',sprintf('HCP_%s',mapType),'no')
    case 'HCP:taskSpace' % assign HCP tasks to HCP parcellation
        mapType=varargin{1}; % '<dataSet>_<algorithm>_<clusterNum>' example: 'SC12_cnvf_10'
        
        sizeWeight=25;
        
        if strfind(mapType,'SNN'),
            algorithm='SNN';
        else
            algorithm='cnvf';
        end
        
        % project back to task-space
        load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),sprintf('%s.mat',algorithm)));
        W=bestF;
        L=W'*W;
        I=diag(diag(sqrt(L))); % diag not sum
        X=W/I;
        
        % get cluster colours
        cmap=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'colourMap.txt'));
        cmap=cmap/255;
        
        [~,~,condNames]=sc1_sc2_functionalAtlas('HCP:get_data');
        
        % Make word lists for word map
        DD = W;WORD=condNames;
        DD(DD<0)=0;
        DD=DD./max(DD(:));
        numClusters=size(DD,2);
        numTask=size(DD,1);
        for j=1:numClusters,
            subplot(2,6,j);
            set(gca,'Xticklabel',[],'Yticklabel',[])
            title(sprintf('Region %d',j),'Color',cmap(j,2:4))
            set(gca,'FontSize',18);
            for i=1:numTask,
                if (DD(i,j)>0)
                    siz=ceil(DD(i,j)*sizeWeight);
                    text(unifrnd(0,1,1),unifrnd(0,1,1),WORD{i},'FontSize',siz,'Color',cmap(j,2:4));
                end;
            end;
        end;
    case 'HCP:multiTask' % assign HCP tasks to multi-task parcellation
        mapType=varargin{1}; % '<dataSet>_<algorithm>_<clusterNum>' example: 'SC12_cnvf_10'
        
        sizeWeight=20;
        
        if strfind(mapType,'SNN'),
            algorithm='SNN';
        else
            algorithm='cnvf';
        end
        
        [X_C,condNames]=sc1_sc2_functionalAtlas('HCP:get_data');
        
        load(fullfile(studyDir{2},encodeDir,'glm4',mapType,sprintf('%s.mat',algorithm)));
        X_C=X_C';
        
        % figure out how HCP tasks load on multi-task regions
        T=corr(X_C,bestG);
        
        % get cluster colours
        cmap=load(fullfile(studyDir{2},encodeDir,'glm4',mapType,'colourMap.txt'));
        cmap=cmap/255;
        
        % Make word lists for word map
        DD = T;WORD=condNames;
        DD(DD<0)=0;
        DD=DD./max(DD(:));
        numClusters=size(DD,2);
        numTask=size(DD,1);
        for j=1:numClusters,
            subplot(2,5,j);
            set(gca,'Xticklabel',[],'Yticklabel',[])
            title(sprintf('Region %d',j),'Color',cmap(j,2:4))
            set(gca,'FontSize',18);
            for i=1:numTask,
                if (DD(i,j)>.2)
                    siz=ceil(DD(i,j)*sizeWeight);
                    text(unifrnd(0,1,1),unifrnd(0,1,1),WORD{i},'FontSize',siz,'Color',cmap(j,2:4));
                end;
            end;
        end;
        
    case 'MAP:vol2surf'
        % this function takes any labelled volume (already in SUIT space)
        % and plots to the surface
        mapType=varargin{1}; % '<dataSet>_<algorithm>_<clusterNum>' example: 'SC12_cnvf_10'
        metric=varargin{2}; % 'yes' or 'no'
        
        vararginoptions({varargin{3:end}},{'border','sn','weights'}); % option if doing individual map analysis
        
        if exist('sn'),
            inputDir=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn});
            mapName=sprintf('map_%s.nii',mapType);
        else
            inputDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType));
            mapName='probAtlas.nii';
        end
        cd(inputDir);
        
        Vo=spm_vol(fullfile(inputDir,mapName));
        Vi=spm_read_vols(Vo);
        Vv{1}.dat=Vi;
        Vv{1}.dim=Vo.dim;
        Vv{1}.mat=Vo.mat;
        
        if exist('weights','var'),
            M=caret_suit_map2surf(Vv,'space','SUIT');
        else
            M=caret_suit_map2surf(Vv,'space','SUIT','stats','mode');
            M.data=round(M.data);
        end
        
        % figure out colourMap
        if exist(fullfile(inputDir,'colourMap.txt'),'file'),
            cmap=load('colourMap.txt');
            cmap=cmap(:,2:4);
            cmapF=cmap/255;
        else
            cmapF=colorcube(max(M.data));
        end
        
        switch metric,
            case 'yes'
                if ~exist('weights','var'),
                    % make paint and area files
                    M=caret_struct('paint','data',M.data);
                    A=caret_struct('area','data',cmapF*255,'column_name',M.paintnames,...
                        'column_color_mapping',repmat([-5 5],M.num_paintnames),'paintnames',M.paintnames);
                    
                    % save out paint and area files
                    if exist('sn'),
                        caret_save(fullfile(studyDir{1},caretDir,'suit_flat',sprintf('%s-subj%d.paint',inputMap,sn)),M);
                    else
                        caret_save(fullfile(studyDir{1},caretDir,'suit_flat',sprintf('%s.paint',inputMap)),M);
                        caret_save(fullfile(studyDir{1},caretDir,'suit_flat',sprintf('%s.areacolor',inputMap)),A);
                    end
                else
                    M=caret_struct('metric','data',M.data);
                    if exist('sn'),
                        caret_save(fullfile(studyDir{1},caretDir,'suit_flat',sprintf('%s-subj%d.metric',inputMap,sn)),M);
                    else
                        caret_save(fullfile(studyDir{1},caretDir,'suit_flat',sprintf('%s.metric',inputMap)),M);
                    end
                end
            case 'no'
                if ~exist('weights','var'),
                    if exist('border','var'),
                        suit_plotflatmap(M.data,'type','label','cmap',cmapF,'border',[])
                    else
                        suit_plotflatmap(M.data,'type','label','cmap',cmapF) % colorcube(max(M.data))
                    end
                else
                    if exist('border','var'),
                        suit_plotflatmap(M.data,'border',[])
                    else
                        suit_plotflatmap(M.data) % colorcube(max(M.data))
                    end
                end
        end
    case 'MAP:make_paint' % Make a paint file from a set of parcellations
        type=varargin{1}; % 'SNNindivid','SNNgroup','CNVFgroup'
        
        switch (type) % Most straightforward to define both the input maps (full path) and
            % outname depending on type
            case 'SNNindivid'       % Previous 'subjs'
                inputMap='SC12_10cluster';
                for s=1:length(returnSubjs),
                    inputDir=fullfile(studyDir{2},encodeDir,'glm4',subj_name{s});
                    mapName{s}=sprintf('map_%s.nii',inputMap);
                    column_names{s}=sprinft('Subj%d',subj_name{s});
                end;
                outname='Multi-Task-indivSubjs';
            case 'SNNgroup'
                clusters=[5:24];
                for m=1:length(clusters),
                    mapName{m}=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_SC12_%dclusters',clusters(m)),'map.nii');
                    column_names{m}=sprinft('%dclusters',clusters(m));
                end
                outname='SNN_maps';
            case 'CNVFgroup'
                clusters=[7,10,17];
                for m=1:length(clusters),
                    mapName{m}=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_SC12_cnvf_%d',clusters(m)),'map.nii');
                    column_names{m}=sprintf('%dclusters',clusters(m));
                end
                outname='CNVF_maps';
        end;
        
        for s=1:length(mapName)
            Vo=spm_vol(mapName{s});
            Vi=spm_read_vols(Vo);
            Vv(s).dat=Vi;
            Vv(s).dim=Vo.dim;
            Vv(s).mat=Vo.mat;
        end
        
        M=suit_map2surf(Vv,'space','SUIT','stats','mode');
        
        % make paint and area files
        M=caret_struct('paint','data',M,'column_name',column_names);
        
        % save out paint and area files
        caret_save(fullfile(studyDir{1},caretDir,'suit_flat',sprintf('%s.paint',outname)),M);
    case 'MAP:optimal'     % figure out optimal map for multiple clusters
        % example:sc1_sc2_functionalAtlas('MAP:optimal',<subjNums>,1,6,'group')
        sn=varargin{1};     % 'group' or <subjNum>
        study=varargin{2};  % 1 or 2 or [1,2]
        
        algorithmString = {'snn','cnvf','ica'}; % Semi-nonengative matrix factorization
        algorithm = 2;
        K=10; % number of regions
        smooth = [];
        G0 = [];          % Starting value for weights
        
        tol_rand = 0.90;    % Tolerance on rand coefficient to call it the same solution
        maxStart=100;       % How many starts maximally?
        numCount=5;         % For how many starting values do we need to find the same solution?
        maxIter = 100;      % How many iterations per starting value
        
        vararginoptions({varargin{3:end}},{'sess','numCount','tol_rand','maxIter','maxStart','algorithm','K','smooth'}); % options
        
        % Set the String correctly
        if length(study)>1
            studyStr='SC12'; % both studies combined
        else
            studyStr = sprintf('SC%d',study);
        end
        
        % Set output filename: group or indiv ?
        if strcmp(sn,'group') % group
            sn=returnSubjs;
            if (~isempty(smooth))
                % Load the unsmoothed version as a starting value
                prevSol=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%s_%d',studyStr,algorithmString{algorithm},K),...
                    sprintf('%s.mat',algorithmString{algorithm})));
                G0=prevSol.bestG;
                outDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%s_%d_s%2.1f',studyStr,algorithmString{algorithm},K,smooth));
            else
                outDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%s_%d',studyStr,algorithmString{algorithm},K));
            end;
            dircheck(outDir);
            outName=fullfile(outDir,sprintf('%s.mat',algorithmString{algorithm}));
        else % indiv
            prevSol=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%s_%d',studyStr,algorithmString{algorithm},K),...
                sprintf('%s.mat',algorithmString{algorithm})));
            G0=prevSol.bestG;
            outDir=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn});
            outName=fullfile(outDir,sprintf('%s_%s_%d.mat',studyStr,algorithmString{algorithm},K));
        end
        
        % get data
        [X_C,volIndx,V] = sc1_sc2_functionalAtlas('EVAL:get_data',sn,study,'build','smooth',smooth);
        
        % Intialize iterations[G
        bestErr = inf;
        bestSol = ones(size(X_C,2),1);
        iter=1; % How many iterations
        count=0;
        while iter<=maxStart,
            switch (algorithm)
                case 1
                    [F,G,Info]=semiNonNegMatFac(X_C,K,'threshold',0.01); % get a segmentation using
                case 2 % convec
                    [F,G,Info]=cnvSemiNonNegMatFac(X_C,K,'threshold',0.01,'maxIter',maxIter,'G0',G0); % get a segmentation using
            end;
            errors(iter)=Info.error;    % record error
            [~,winner]=max(G,[],2);     % determine the highest loading cluster for each voxel
            randInd(iter)=RandIndex(bestSol,winner); %
            
            % Check if we have a similar solution
            if randInd(iter)>tol_rand % Similar solution
                count=count+1;       % count up one
                if (Info.error<bestErr)  % If we got slightly better - update
                    bestErr = Info.error;
                    bestSol = winner;
                    bestG   = G;
                    bestF   = F;
                    bestInfo = Info;
                end;
            else                     % Different (enough) solution
                if (Info.error<bestErr) % Is this a better solution
                    bestErr = Info.error;
                    bestSol = winner;
                    bestG   = G;
                    bestF   = F;
                    bestInfo = Info;
                    count = 0;         % first time we found this solution: reset counter
                end;
            end;
            fprintf('Error: %2.2f Rand:%2.2f, Best:%2.2f currently found %d times\n',errors(iter),randInd(iter),bestErr,count);
            if count>=numCount || iter>=maxIter,
                fprintf('Existing loop....\n');
                break;
            end;
            iter=iter+1;
        end;
        save(outName,'bestG','bestF','bestInfo','errors','randInd','iter','count','volIndx','V');
    case 'MAP:SNN:SSE'   % temporary function to compute SSE for SNN
        study=varargin{1}; % 1 or 2 or [1,2]
        mapType=varargin{2}; % '<algorithm>_<clusterNum>'
        
        % Set the String correctly
        studyStr = sprintf('SC%d',study);
        if length(study)>1
            studyStr='SC12'; % both studies combined
        end
        
        outDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%s',studyStr,mapType));
        outName=fullfile(outDir,'SNN.mat');
        load(outName);
        
        % get X
        X = sc1_sc2_functionalAtlas('EVAL:get_data','group',study,'build');
        
        % Provide fitting info
        % R2
        X_hat=bestF*bestG';
        R=X-X_hat;
        n=size(R,1);
        k2=size(bestG,2);
        SSR=nansum(R.*R);
        SST=nansum(X.*X);
        SSRadj=SSR./k2; % this is not correct
        SSTadj=SST;
        
        % R
        SXP=nansum(nansum(X.*X_hat,1));
        SPP=nansum(nansum(X_hat.*X_hat));
        
        bestInfo.R2_vox  = 1-nansum(R.*R)./nansum(X.*X);  % MK: R2=1-SSR/SST
        bestInfo.R2      = 1-nansum(SSR)./nansum(SST);
        bestInfo.R       = SXP./sqrt(nansum(SST).*SPP);   % MK: R=covar(X,X_hat)/var(X)*var(X_hat)
        bestInfo.R2adj   = 1-nansum(SSRadj)./nansum(SSTadj);
        bestInfo.error   = nansum(nansum(R.*R));
        
        fprintf('bestInfo recomputed for %s \n',mapType)
        save(outName,'bestG','bestF','bestInfo','errors','randInd','iter','count','volIndx','V');
    case 'MAP:ICA'     % DEPRECIATED
        % example:sc1_sc2_functionalAtlas('MAP:optimal',<subjNums>,1,6,'group')
        sn=varargin{1};     % subject numbers
        study=varargin{2};  % 1 or 2 or [1,2]
        K=varargin{3};      % K=thresh (i.e. 90)
        type=varargin{4};   % 'group' or 'indiv'
        
        %numCount=5;         % How often the "same" solution needs to be found
        %tol_rand = 0.90;    % Tolerance on rand coefficient to call it the same solution
        %maxIter=100; % if it's not finding a similar solution - force stop at 100 iters
        
        % Set the String correctly
        studyStr = sprintf('SC%d',study);
        if length(study)>1
            studyStr='SC12'; % both studies combined
        end
        
        % Set output File name
        switch type,
            case 'group'
                sn=returnSubjs;
                outDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%dPOV',studyStr,threshold));
                dircheck(outDir);
                outName=fullfile(outDir,'ICAs.mat');
            case 'indiv'
                outDir=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn});
                outName=fullfile(outDir,sprintf('ICAs_%s_%dPOV.mat',studyStr,threshold));
        end
        
        % get data
        [X_C,volIndx,V] = sc1_sc2_functionalAtlas('EVAL:get_data',sn,study,'build');
        
        threshold=threshold/100;
        [A_PW,S_PW,W_PW,winner]=pca_ica(X_C,'threshold',threshold);
        
        save(outName,'A_PW','S_PW','W_PW','volIndx','V');
    case 'MAP:visualise'
        sn=varargin{1}; % [2] or 'group'
        study=varargin{2};  % 1 or 2 or [1,2]
        
        algorithmString = {'snn','cnvf','ica'}; % Semi-nonengative matrix factorization
        algorithm = 2;
        K=10; % number of regions
        
        % Set the String correctly
        if length(study)>1
            studyStr='SC12'; % both studies combined
        else
            studyStr = sprintf('SC%d',study);
        end
        
        % figure out if individual or group
        if strcmp(sn,'group'),
            outName=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%s_%d',studyStr,algorithmString{algorithm},K),'map.nii');
            load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%s_%d',studyStr,algorithmString{algorithm},K),...
                sprintf('%s.mat',algorithmString{algorithm})));
            % individual analysis
        else
            outName=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn},sprintf('map_%s_%s_%d.nii',studyStr,algorithmString{algorithm},K));
            load(fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn},sprintf('%s_%s_%d.mat',studyStr,algorithmString{algorithm},K)));
        end
        
        % transpose matrix from ICA
        if strcmp(algorithmString,'ica'),
            bestG=S_PW';
        end
        [x,groupFeat]=max(bestG,[],2);
        
        % z-score the weights
        %         weights_z=x-mean(x)/std(x);
        
        % map features on group
        %V=spm_vol(which('Cerebellum-SUIT.nii'));
        Yy=zeros(1,V.dim(1)*V.dim(2)*V.dim(3));
        Yy(1,volIndx)=groupFeat;
        Yy=reshape(Yy,[V.dim(1),V.dim(2),V.dim(3)]);
        Yy(Yy==0)=NaN;
        Vv{1}.dat=Yy;
        Vv{1}.dim=V.dim;
        Vv{1}.mat=V.mat;
        
        % save out vol of SNN feats
        exampleVol=fullfile(studyDir{2},suitDir,'glm4','s02','wdbeta_0001.nii'); % must be better way ??
        X=spm_vol(exampleVol);
        X.fname=outName;
        X.private.dat.fname=V.fname;
        spm_write_vol(X,Vv{1}.dat);
    case 'MAP:RAND_global'  % this function will compute randindex between maps (pairwise if more than 2 maps are provided)
        compare={'groupEval_SC12_cnvf_7','groupEval_SC12_cnvf_10','groupEval_SC12_cnvf_17',...
            'groupEval_Buckner_7Networks','groupEval_Cole_10Networks','groupEval_Buckner_17Networks',...
            'groupEval_lob10'};
        numMaps = length(compare);
        load(fullfile(studyDir{2},encodeDir,'glm4','cereb_avrgDataStruct.mat'));  % Just to get V and volIndex
        clear T;
        for i=1:numMaps
            try
                T=load(fullfile(baseDir,'sc2','encoding','glm4',compare{i},'cnvf.mat'));
                [~,c(:,i)]=max(T.bestG,[],2);
            catch
                Vi=spm_vol(fullfile(baseDir,'sc2','encoding','glm4',compare{i},'map.nii'));
                [i1,j1,k1]=ind2sub(V.dim,volIndx');
                [x,y,z]=spmj_affine_transform(i1,j1,k1,V.mat);
                [i2,j2,k2]=spmj_affine_transform(x,y,z,inv(Vi.mat));
                c(:,i)=spm_sample_vol(Vi,i2,j2,k2,0);
            end;
        end;
        for i=1:numMaps-1
            for j=i+1:numMaps
                AR(i,j)=RandIndex(c(:,i),c(:,j));
                AR(j,i)=AR(i,j);
            end;
        end;
        varargout={AR};
        colormap(hot);
        imagesc(AR,[0 0.8]);
        colorbar;
        set(gca,'XTickLabel',{'C7','C10','C17','R7','R10','R17'},'YTickLabel',{'C7','C10','C17','R7','R10','R17'});
        %set(gcf,'PaperPosition',[2 2 4.7 3.8]);
        % wysiwyg;
        % axis equal
    case 'MAP:RAND_local'
        type = 'searchlight'; % 'voxelwise','searchlight', or 'searchlightvoxel'
        compare={'groupEval_SC12_cnvf_7','groupEval_SC12_cnvf_10','groupEval_SC12_cnvf_17',...
            'groupEval_Buckner_7Networks','groupEval_Cole_10Networks','groupEval_Buckner_17Networks'...
            };
        compare={'groupEval_Buckner_17Networks'};
        split = [1 1 1 2 2 2];
        radius = 10;
        vararginoptions(varargin,{'radius','compare','type','split'});
        numMaps = length(compare);
        load(fullfile(studyDir{2},encodeDir,'glm4','cereb_avrgDataStruct.mat'));  % Just to get V and volIndex
        clear T;
        
        for i=1:numMaps
            try
                T=load(fullfile(baseDir,'sc2','encoding','glm4',compare{i},'cnvf.mat'));
                [~,c(:,i)]=max(T.bestG,[],2);
            catch
                Vi=spm_vol(fullfile(baseDir,'sc2','encoding','glm4',compare{i},'map.nii'));
                [i1,j1,k1]=ind2sub(V.dim,volIndx');
                [x,y,z]=spmj_affine_transform(i1,j1,k1,V.mat);
                [i2,j2,k2]=spmj_affine_transform(x,y,z,inv(Vi.mat));
                c(:,i)=spm_sample_vol(Vi,i2,j2,k2,0);
            end;
        end;
        ar=[];
        [x,y,z]=ind2sub(V.dim,volIndx);
        [x,y,z]=spmj_affine_transform(x,y,z,T.V.mat);
        xyz=[x;y;z];
        D=surfing_eucldist(xyz,xyz);        % Eucledian distance
        pair = [];
        for i=1:numMaps-1
            for j=i+1:numMaps
                ar(:,end+1)=RandIndexLocal(type,c(:,i),c(:,j),D,radius);
                if (~isempty(split))
                    if (split(i)==split(j) && split(i)==1)
                        pair(end+1)=1;
                    elseif (split(i)==split(j) && split(i)==2)
                        pair(end+1)=2;
                    elseif (split(i)~=split(j))
                        pair(end+1)=3;
                    else
                        pair(end+1)=0;
                    end;
                end;
            end;
        end;
        numPlots = length(unique(pair));
        for i=1:numPlots
            subplot(1,numPlots,i);
            sc1sc2_spatialAnalysis('visualise_map',mean(ar(:,pair==i),2),volIndx,V,'type','func');
        end;
        Output.type= type;
        Output.compare= compare;
        Output.split= split;
        Output.ar= ar;
        Output.pair= pair;
        varargout = {Output};
    case 'MAP:PLOT:ICA' % evaluate POV (ICA) as a function of clusters
        mapDir=varargin{1}; % {'SC1','SC2','SC12'}
        mapType=varargin{2};
        POV=varargin{3}; % [50:5:95,96:100]
        
        S=[];
        for s=1:length(mapDir),
            for m=1:length(mapType),
                load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s_%s',mapDir{s},mapType{m}),'ICAs.mat'));
                T.K(m,1)=size(S_PW,1);
                T.mapName{m,1}=mapType{m};
                T.m(m,1)=m;
                T.type{m,1}=mapDir{s};
            end
            T.POV=POV';
            S=addstruct(S,T);
        end
        figure()
        lineplot(S.POV,S.K,'split',S.type,'leg','auto','style_thickline2x3','linewidth',4)
        ylabel('clusters')
        xlabel('variance')
    case 'MAP:PLOT:SNN'
        mapDir=varargin{1}; % {'SC1','SC2','SC12'}
        mapType=varargin{2};
        K=varargin{3}; % [5:24]
        
        vararginoptions({varargin{4:end}},{'CAT'}); % option if doing individual map analysis
        
        S=[];
        for s=1:length(mapDir),
            for m=1:length(mapType),
                load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s_%s',mapDir{s},mapType{m}),'SNN.mat'));
                T.R2(m,1)=bestInfo.R2;
                T.R2adj(m,1)=bestInfo.R2adj;
                T.mapName{m,1}=mapType{m};
                T.m(m,1)=m;
                T.type{m,1}=mapDir{s};
            end
            T.K=K';
            S=addstruct(S,T);
        end
        figure()
        lineplot(S.K,S.R2,'split',S.type,'CAT',CAT)
        hold on
        CAT.linecolor={'k'};
        CAT.markercolor={'k'};
        CAT.markerfill={'k'};
        lineplot(S.K,S.R2adj,'split',S.type,'CAT',CAT)
    case 'MAP:Group_Indiv' % Cluster individual data based on group Features
        % sc1_sc2_functionalAtlas('MAP:Group_Indiv','10cluster',[1 2])
        mapType=varargin{1}; % '10cluster', or '7cluster', or '17cluster'
        study  = varargin{2}; % Data used from which study?
        mapName = ['SC12_' mapType];  % Use the features that have been learned over both experiments
        subjs=returnSubjs;
        D=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        
        % load group features (these don't need to be crossvalidated)
        load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapName),'SNN.mat'));
        groupF=bestF(ismember(D.StudyNum,study),:);
        groupF=bsxfun(@minus,groupF,mean(groupF,1)); % recenter if necessary
        numConds   = size(groupF,1);
        numCluster = size(groupF,2);
        
        % load DATA from the individual
        for s=1:length(subjs)
            [X_C,volIndx,V] = sc1_sc2_functionalAtlas('EVAL:get_data',subjs(s),study,'build');
            numVox=size(X_C,2);
            individG=nan(numCluster,numVox);
            outname = fullfile(studyDir{2},'encoding','glm4',subj_name{subjs(s)},sprintf('map_%s_10clusters_group.nii',studyStr{sum(study)}));%2.2d
            
            % Now express the X_C= groupF * indivdG
            for i=1:numVox
                if (mod(i,2000)==0)
                    fprintf('.');
                end;
                individG(:,i)=lsqnonneg(groupF,X_C(:,i));
            end
            fprintf(' %d done\n',subjs(s));
            [~,ClusterI]=max(individG,[],1);
            ClusterI(sum(individG,1)==0)=nan;
            % sc1sc2_spatialAnalysis('visualise_map',ClusterI,volIndx,V);
            
            % Make file
            Yy=zeros(V.dim);
            Yy(volIndx)=ClusterI;
            Yy(isnan(Yy))=0;
            Vv.dim=V.dim;
            Vv.mat=V.mat;
            Vv.fname = outname;
            Vv.dt=[2 0];    % uint8
            Vv.pinfo = [1 0 0]'; % Set slope to 1
            spm_write_vol(Vv,Yy);
            
            fprintf('subj%d done \n',subjs(s));
        end
    case 'MAP:probabilistic'
        algorithmString = {'snn','cnvf','ica'}; % Semi-nonengative matrix factorization
        algorithm=2;
        K=10; % number of regions
        studyStr='SC12';
        
        load(fullfile(studyDir{2},'encoding','glm4','cereb_avrgDataStruct.mat'));
        
        %         % load in group map
        %         load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%s_%d',studyStr,algorithmString{algorithm},K),...
        %             sprintf('%s.mat',algorithmString{algorithm})));
        %         [x,feats_group]=max(bestG,[],2);
        %
        for s=1:length(returnSubjs),
            inDir=fullfile(studyDir{2},encodeDir,'glm4',subj_name{returnSubjs(s)});
            inName=fullfile(inDir,sprintf('%s_%s_%d.mat',studyStr,algorithmString{algorithm},K));
            outName=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s_%s_%d',studyStr,algorithmString{algorithm},K));
            load(inName);
            [x,feats]=max(bestG,[],2);
            feats_indiv(:,s)=feats;
        end
        
        % figure out probability
        assignment=mode(feats_indiv,2);
        
        % figure out probability for each subject
        for s=1:length(returnSubjs),
            for p=1:size(feats_indiv,1),
                certainty=numel(find(feats_indiv(p,:)==assignment(p)));
                prob(p,s)=certainty/size(feats_indiv,2);
            end
        end
        %
        %         for p=1:size(feats_indiv,1)
        %             assignment(p)=mode(feats_indiv(p,:));
        %             certainty=numel(find(feats_indiv(p,:)==assignment(p)));
        %             prob(p,:)=certainty/size(feats_indiv,2);
        %         end
        
        % map to volume
        for s=1:length(returnSubjs),
            Yy=zeros(1,V.dim(1)*V.dim(2)*V.dim(3));
            Yy(1,volIndx)=prob(:,s);
            
            Yy=reshape(Yy,[V.dim(1),V.dim(2),V.dim(3)]);
            Yy(Yy==0)=NaN;
            Vv{1}.dat=Yy;
            Vv{1}.dim=V.dim;
            Vv{1}.mat=V.mat;
            
            % save out vol of prob
            exampleVol=fullfile(studyDir{2},suitDir,'glm4','s02','wdbeta_0001.nii'); % must be better way ??
            X=spm_vol(exampleVol);
            X.fname=sprintf('%s/probAtlas%d.nii',outName,s);
            fileNames_SUIT{s}=X.fname;
            fileNames_MNI{s}=sprintf('%s/Ws2m_probAtlas%d.nii',outName,s);
            X.private.dat.fname=V.fname;
            spm_write_vol(X,Vv{1}.dat);
            
            cd(outName)
            % save out MNI version as well
            suit_mni2suit(sprintf('probAtlas%d.nii',s),'def','suit2mni');
        end
        
        % make 4d
        spmj_make4dnii(sprintf('%s/probAtlas.nii',outName),char(fileNames_SUIT'))
        spmj_make4dnii(sprintf('%s/Ws2m_probAtlas.nii',outName),char(fileNames_MNI'))
        
        %         % map to surface
        %         M=caret_suit_map2surf(Vv,'space','SUIT');
        %         M=caret_struct('metric','data',M.data);
        %         caret_save(fullfile(studyDir{2},caretDir,'suit_flat','glm4','probAtlas.metric'),M);
        
    case 'CORTEX:makeModel'
        study=varargin{1};
        s=varargin{2};
        
        load(fullfile(studyDir{2},encodeDir,'glm4','groupEval_SC12_10cluster','SNN.mat'));
        
        % load cerebellar betas
        encodeSubjDir = fullfile(studyDir{study},encodeDir,'glm4',subj_name{s}); % set directory
        load(fullfile(encodeSubjDir,sprintf('Y_info_glm4_grey_nan.mat')));
        Yp=getrow(Y,Y.cond~=0);
        
        % get masked betas
        X=Yp.data*bestG;
        
        varargout={X};
    case 'CORTEX:runModel'
        sn=varargin{1}; % returnSubjs
        study=varargin{2}; % 1 or 2
        
        subjs=length(sn);
        
        % loop over subjects
        for h=1:2,
            Ys=[];
            
            for s=1:subjs,
                
                encodeSubjDir = fullfile(studyDir{study},encodeDir,'glm4',subj_name{sn(s)}); % set directory
                
                % load X (per subj)
                X=sc1_sc2_functionalAtlas('CORTEX:makeModel',study,sn(s));
                
                % load Y (per subj)
                load(fullfile(encodeSubjDir,sprintf('Y_info_glm4_cortex_%s.mat',hem{h})));
                
                nonZeroInd=Y.nonZeroInd;
                Y=rmfield(Y,'nonZeroInd');
                Yp=getrow(Y,Y.cond~=0);
                
                numConds=length(unique(Yp.cond));
                
                part=Yp.run;
                block=run;
                
                % normalise (either by run or by session)
                N = (numConds)*numel(run);
                B = indicatorMatrix('identity',part);
                R  = eye(N)-B*pinv(B);
                X = R*X;            % Subtract block mean (from X)
                X=bsxfun(@rdivide,X,sqrt(sum(X.*X)/(size(X,1)-numel(block))));
                Yact = R*Yp.data;    % Subtract block mean (from Y)
                Yact=bsxfun(@rdivide,Yact,sqrt(sum(Yact.*Yact)/(size(Yact,1)-numel(block))));
                
                % run encoding model (with ridge regress)
                [~,~,~,~,~,winner]=encode_fit(Yact,X,'winnerTakeAll');
                
                M.SN=sn(s);
                M.winner=winner;
                M.idx=nonZeroInd;
                Ys=addstruct(Ys,M);
                
                fprintf('subj%d:model done for %s ...\n',sn(s),hem{h})
                
            end
            % save out results
            save(fullfile(studyDir{study},encodeDir,'glm4',sprintf('encode_cerebModel_%s.mat',hem{h})),'Ys','-v7.3');
            clear Ys
        end
    case 'CORTEX:visualiseModel'
        
        caretFSDir=fullfile(studyDir{1},caretDir,'fsaverage_sym');
        
        % loop over subjects
        for h=1:2,
            for study=1:2,
                % load cortical labels per subject
                load(fullfile(studyDir{study},encodeDir,'glm4',sprintf('encode_cerebModel_%s.mat',hem{h})));
                
                % get average across subjects
                modeSubjs(study,:)=mode(Ys.winner,1);
                
            end
            % get average across studies
            modeStudy=mode(modeSubjs,1);
            
            % load in medial wall
            M=caret_load(fullfile(caretFSDir,hemName{h},sprintf('%s.medialWall.paint',hem{h})));
            
            % black out medial wall
            modeStudy(M.data==1)=0;
            
            % make paint file for cortex
            S=caret_struct('paint','data',modeStudy');
            
            caret_save(fullfile(caretFSDir,hemName{h},sprintf('%s.cerebModel.paint',hem{h})),S);
        end
        
    case 'EVAL:get_data'  % always use this case to get task-evoked activity patterns (remove mean of shared tasks + center)
        sn=varargin{1}; % Subj numbers to include or 'group'
        study=varargin{2}; % 1 or 2 or [1,2]
        type=varargin{3}; % 'build' or 'eval'. For build - we get group data. For eval - we get indiv data
        smooth = []; %
        vararginoptions({varargin{4:end}},{'sess','smooth'}); % fracture further into sessions [either 1 or 2]
        
        D=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        
        % input could be 'group' or <subjNums>
        if strcmp(sn,'group'),
            sn=returnSubjs;
        end
        
        % load data
        UFullAvrgAll=[];
        for f=1:length(study),
            load(fullfile(studyDir{study(f)},encodeDir,'glm4','cereb_avrgDataStruct.mat'));
            
            D1=getrow(D,D.StudyNum==f);
            idx=D1.condNum(D1.overlap==1); % get index for unique tasks
            % format data
            for s=1:length(sn),
                if exist('sess'),
                    indx=T.SN==sn(s) & T.sess==sess;
                    UFullAvrg=T.data(indx,:);
                else
                    indx=T.SN==sn(s);
                    UFull=T.data(indx,:);
                    [numConds,numVox]=size(UFull);
                    % get average across sessions
                    numConds=numConds/2;
                    for c=1:numConds,
                        UFullAvrg(c,:,s)=nanmean(UFull([c,c+numConds],:),1);
                    end
                end
            end
            
            switch type,
                case 'build'
                    % if group - get mean
                    UFull=nanmean(UFullAvrg,3);
                    % remove mean of shared tasks
                    UFullAvrg_C=bsxfun(@minus,UFull,mean(UFull(idx,:)));
                case 'eval'
                    % remove mean of shared tasks
                    UFullAvrg_C=bsxfun(@minus,UFullAvrg,mean(UFullAvrg(idx,:,:)));
            end
            
            % if func1+func2 - concatenate
            if length(study)>1,
                UFullAvrgAll=[UFullAvrgAll;UFullAvrg_C];
            else
                UFullAvrgAll=UFullAvrg_C;
            end
        end
        
        % center the data (remove overall mean)
        X_C=bsxfun(@minus,UFullAvrgAll,mean(UFullAvrgAll));
        
        % Implement smoothing on functional profiles if required
        if (~isempty(smooth))
            fprintf('Smoothing data\n');
            clear UFull UFullAvrg UFullAvrgAll UFullAvrg_C; % Free unnecessary things in memory
            % Get voxel coordinates
            [i,j,k]=ind2sub(V.dim,volIndx);
            [x,y,z]=spmj_affine_transform(i,j,k,V.mat);
            XYZ= [x;y;z];
            W=surfing_eucldist(XYZ,XYZ);        % Euclidean distance
            W=exp(-0.5*W.^2/smooth.^2);         % Gaussian smooth kernel on this
            X_C(isnan(X_C))=0;
            ignore = sum(abs(X_C),1)==0; % Ignore voxels without data or with nans in the smoothing operations
            W(ignore,:)=0; % Set all the weights on empty voxels to zero
            W=bsxfun(@rdivide,W,sum(W,1)); % Make the overall kernel sum to 1
            X_C=X_C*W; % Smooth the data
        end;
        varargout={X_C,volIndx,V,sn};
    case 'EVAL:crossval'% Evaluate group Map
        sn=varargin{1}; % 'group' or <subjNum>
        mapType=varargin{2}; % options are 'lob10','lob26','Buckner_17Networks','Buckner_7Networks', 'Cole_10Networks','SC<studyNum>_<num>cluster'
        data=varargin{3}; % evaluating data from study [1] or [2] ?
        condType=varargin{4}; % 'unique' or 'all'. Are we evaluating on all taskConds or just those unique to either sc1 or sc2 ?
        
        % example: sc1_sc2_functionalAtlas('EVAL:crossval',2,'SC12_10cluster_group',1,'unique')
        
        % load in func data to test (e.g. if map is sc1; func data should
        % be sc2)
        load(fullfile(studyDir{data},'encoding','glm4','cereb_avrgDataStruct.mat'));
        
        D=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        D1=getrow(D,D.StudyNum==data);
        
        % evaluating the group or the individual ?
        if strcmp(sn,'group'),
            % load in map
            mapName=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'map.nii');
            outName=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),sprintf('spatialBoundfunc%d_%s.mat',data,condType));
            sn=unique(T.SN)';
        else
            mapName=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn},sprintf('map_%s.nii',mapType));
            outName=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn},sprintf('%s_spatialBoundfunc%d_%s.mat',mapType,data,condType));
        end
        
        switch condType,
            case 'unique'
                % if funcMap - only evaluate unique tasks in sc1 or sc2
                idx=D1.condNum(D1.overlap==0); % get index for unique tasks
            case 'all'
                idx=D1.condNum;
        end
        
        % Now get the parcellation sampled into the same space
        [i,j,k]=ind2sub(V.dim,volIndx);
        [x,y,z]=spmj_affine_transform(i,j,k,V.mat);
        VA= spm_vol(mapName);
        [i1,j1,k1]=spmj_affine_transform(x,y,z,inv(VA.mat));
        Parcel = spm_sample_vol(VA,i1,j1,k1,0);
        % Divide the voxel pairs into all the spatial bins that we want
        fprintf('parcels\n');
        voxIn = Parcel>0;
        XYZ= [x;y;z];
        RR=[];
        [BIN,R]=mva_spatialCorrBin(XYZ(:,voxIn),'Parcel',Parcel(1,voxIn));
        clear XYZ i k l x y z i1 j1 k1 VA Parcel; % Free memory
        % Now calculate the uncrossvalidated and crossvalidated
        % Estimation of the correlation for each subject
        for s=sn,
            for c=1:length(idx),
                i1(c) = find(T.SN==s & T.sess==1 & T.cond==idx(c));
                i2(c) = find(T.SN==s & T.sess==2 & T.cond==idx(c));
            end
            D=(T.data(i1,voxIn)+T.data(i2,voxIn))/2;
            
            fprintf('%d cross\n',s);
            R.SN = ones(length(R.N),1)*s;
            R.corr = mva_spatialCorr(T.data([i1;i2],voxIn),BIN,...
                'CrossvalPart',T.sess([i1;i2],1),'excludeNegVoxels',1);
            R.crossval = ones(length(R.corr),1);
            RR = addstruct(RR,R);
            fprintf('%d correl\n',s);
            R.corr=mva_spatialCorr(D,BIN);
            R.crossval = zeros(length(R.corr),1);
            RR = addstruct(RR,R);
        end;
        save(outName,'-struct','RR');
    case 'EVAL:crossval_individ' % DEPRECIATED ?
        % T1=sc1_sc2_functionalAtlas('EVAL:crossval_individ','SC1_10cluster',2,'unique');
        % T2=sc1_sc2_functionalAtlas('EVAL:crossval_individ','SC2_10cluster',1,'unique');
        % T3=sc1_sc2_functionalAtlas('EVAL:crossval_individ','SC12_10cluster',1,'unique');
        % T4=sc1_sc2_functionalAtlas('EVAL:crossval_individ','SC12_10cluster',2,'unique');
        %         T1.generalisation = ones(length(T1.SN),1);
        %         T2.generalisation = ones(length(T2.SN),1);
        %         T3.generalisation = zeros(length(T3.SN),1);
        %         T4.generalisation = zeros(length(T4.SN),1);
        %         T=addstruct(T1,T2);
        %         T=addstruct(T,T3);
        %         T=addstruct(T,T4);
        %         save(fullfile('spatialBoundfunc_10Cluster_unique.mat'),'-struct','T'));
        sn = returnSubjs;
        mapType=varargin{1}; % options 'SC1_10cluster'
        study=varargin{2}; % evaluating data from study [1] or [2] ?
        condType=varargin{3}; % 'unique' or 'all'. Are we evaluating on all taskConds or just those unique to either sc1 or sc2 ?
        
        load(fullfile(studyDir{study},'encoding','glm4','cereb_avrgDataStruct.mat'));
        D=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        D1=getrow(D,D.StudyNum==study);
        
        switch condType,
            case 'unique'
                % if funcMap - only evaluate unique tasks in sc1 or sc2
                idx=D1.condNum(D1.overlap==0); % get index for unique tasks
            case 'all'
                idx=D1.condNum;
        end
        RR=[];
        for s=sn
            % Now get the parcellation sampled into the same space
            fprintf('%d :Bin',s);
            mapName=fullfile(studyDir{2},encodeDir,'glm4',subj_name{s},sprintf('map_%s.nii',mapType));
            [i,j,k]=ind2sub(V.dim,volIndx);
            [x,y,z]=spmj_affine_transform(i,j,k,V.mat);
            VA= spm_vol(mapName);
            [i1,j1,k1]=spmj_affine_transform(x,y,z,inv(VA.mat));
            Parcel = spm_sample_vol(VA,i1,j1,k1,0);
            % Divide the voxel pairs into all the spatial bins that we want
            fprintf('parcels\n');
            voxIn = Parcel>0;
            XYZ= [x;y;z];
            [BIN,R]=mva_spatialCorrBin(XYZ(:,voxIn),'Parcel',Parcel(1,voxIn));
            clear XYZ i k l x y z i1 j1 k1 VA Parcel; % Free memory
            
            % Now calculate the uncrossvalidated and crossvalidated
            % Estimation of the correlation for each subject
            for c=1:length(idx),
                i1(c) = find(T.SN==s & T.sess==1 & T.cond==idx(c));
                i2(c) = find(T.SN==s & T.sess==2 & T.cond==idx(c));
            end
            D=(T.data(i1,voxIn)+T.data(i2,voxIn))/2;
            
            fprintf('- cross');
            N=length(R.N);
            R.SN = ones(N,1)*s;
            R.map=repmat({mapType},N,1);
            R.study = ones(N,1)*study;
            R.corr = mva_spatialCorr(T.data([i1;i2],voxIn),BIN,...
                'CrossvalPart',T.sess([i1;i2],1),'excludeNegVoxels',1);
            R.crossval = ones(N,1);
            RR = addstruct(RR,R);
            
            fprintf('- correl\n');
            R.corr=mva_spatialCorr(D,BIN);
            R.crossval = zeros(N,1);
            RR = addstruct(RR,R);
        end;
        varargout={RR};
    case 'EVAL:get_subsets'
        step=varargin{1}; % what do you want ? 'dissimilar','makeRandom','evalRandom'
        numTasks=varargin{2}; % how many task conditions in each subset ?
        
        % load in RDM
        [fullRDM,condNames,X,taskType]=sc1_sc2_functionalAtlas('REPRESENTATION:get_distances','cerebellum','all','all');
        
        % load in task indices
        D=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        
        % get avrg RDM
        fullRDM_avrg=nanmean(fullRDM,3);
        
        switch step
            case 'dissimilar' % get most dissimilar task conditions from each task set
                % now figure out task subsets (min and max)
                sessN=[2 1];
                RR=[];
                for ss=1:2,
                    taskB=sum(D.StudyNum==ss);
                    taskE=sessN(ss);
                    for c=1:taskB,
                        [x y]=sort(fullRDM_avrg(D.StudyNum==ss & D.condNum==c,D.StudyNum==taskE));
                        R.nameT=D.condNames(D.StudyNum==ss & D.condNum==c);
                        R.numT=D.condNum(D.StudyNum==ss & D.condNum==c);
                        nameB=D.condNames(D.StudyNum==taskE);
                        R.minT=nameB(y(1)); % min task
                        R.maxT=nameB(y(end)); % max task
                        R.minD=x(1);
                        R.maxD=x(end);
                        R.studyNum=ss;
                        RR=addstruct(RR,R);
                    end
                end
                
                % sort the tasks in A by the size of the minimal distance
                % to B (and vice versa)
                for i=1:2,
                    A=getrow(RR,RR.studyNum==i);
                    [x y]=sort(A.minD);
                    Ss.sortedName=A.nameT(y);
                    Ss.sortedNum=A.numT(y);
                    tmp=[1 Ss.sortedNum(end-numTasks+1:end)'];
                    dlmwrite(fullfile(studyDir{2},encodeDir,'glm4',sprintf('subsets_SC%d_%ddissimilar.txt',i,numTasks)),tmp,'\t')
                    
                    char(A.nameT(tmp(2:end)))
                end
            case 'makeRandom' % get subsets of random tasks to evalute - run once !
                numSets=20;
                for i=1:2,
                    % choose random sets of n tasks
                    D=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
                    D1=getrow(D,D.StudyNum==data);
                    uniqueIdx=D1.condNum(D1.overlap==0); % get index for unique tasks
                    for ii=1:numSets,
                        subsetIdx(ii,:)=datasample(uniqueIdx',numTasks,'Replace',false);
                    end
                end
                keyboard;
            case 'evalRandom' % figure out most dissimilar subsets of random sets
                % now figure out task subsets (min and max)
                sessN=[2 1];
                RR=[];
                for ss=1:2,
                    taskB=sum(D.StudyNum==ss);
                    taskE=sessN(ss);
                    for c=1:taskB,
                        [x y]=sort(fullRDM_avrg(D.StudyNum==ss & D.condNum==c,D.StudyNum==taskE));
                        R.nameT=D.condNames(D.StudyNum==ss & D.condNum==c);
                        R.numT=D.condNum(D.StudyNum==ss & D.condNum==c);
                        nameB=D.condNames(D.StudyNum==taskE);
                        R.minT=nameB(y(1)); % min task
                        R.maxT=nameB(y(end)); % max task
                        R.minD=x(1);
                        R.maxD=x(end);
                        R.studyNum=ss;
                        RR=addstruct(RR,R);
                    end
                end
                
                % sort the tasks in subsets A by the size of the minimal distance
                % to B (and vice versa)
                for i=1:2
                    D=load(fullfile(studyDir{2},'encoding','glm4',sprintf('subsets_SC%d_%drandom.txt',i,numTasks)));
                    D=D(:,2:end);
                    for c=1:size(D,1)
                        A=getrow(RR,RR.studyNum==i);
                        subsetN=D(c,:);
                        [x y]=sort(A.minD(subsetN));
                        avrgMinD(c,i)=nanmean(x);
                        %                         Ss.sortedName=A.nameT(y);
                        %                         Ss.sortedNum=A.numT(y);
                    end
                end
                [x y]=sort(avrgMinD);
                varargout={y};
        end
    case 'EVAL:subsets'
        mapType=varargin{1}; % options are 'lob10','lob26','Buckner_17Networks','Buckner_7Networks','Cole_10Networks','SC<studyNum>_<num>cluster'
        data=varargin{2}; % evaluating data from study [1] or [2] ?
        subsetType=varargin{3}; % 'random' or 'movies' or 'dissimilar'
        numTasks=varargin{4}; % # of random tasks to choose.
        
        % example: sc1_sc2_functionalAtlas('EVAL:crossval',2,'SC12_10cluster_group',1,'unique')
        
        % load in func data to test (e.g. if map is sc1; func data should
        % be sc2)
        load(fullfile(studyDir{data},'encoding','glm4','cereb_avrgDataStruct.mat'));
        
        % evaluating on what ?
        % load in map
        mapName=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'map.nii');
        sn=unique(T.SN)';
        
        % eval on set of n tasks
        D=load(fullfile(studyDir{2},'encoding','glm4',sprintf('subsets_SC%d_%d%s.txt',data,numTasks,subsetType)));
        D=D(:,2:end);
        
        % Now get the parcellation sampled into the same space
        [i,j,k]=ind2sub(V.dim,volIndx);
        [x,y,z]=spmj_affine_transform(i,j,k,V.mat);
        VA= spm_vol(mapName);
        [i1,j1,k1]=spmj_affine_transform(x,y,z,inv(VA.mat));
        Parcel = spm_sample_vol(VA,i1,j1,k1,0);
        % Divide the voxel pairs into all the spatial bins that we want
        fprintf('parcels\n');
        voxIn = Parcel>0;
        XYZ= [x;y;z];
        RR=[];
        [BIN,R]=mva_spatialCorrBin(XYZ(:,voxIn),'Parcel',Parcel(1,voxIn));
        clear XYZ i k l x y z i1 j1 k1 VA Parcel; % Free memory
        
        % loop over number of subsets
        for ns=1:size(D,1),
            
            subsets=D(ns,:);
            
            % Now calculate the uncrossvalidated and crossvalidated
            % Estimation of the correlation for each subject
            for s=sn,
                for c=1:length(subsets),
                    i1(c) = find(T.SN==s & T.sess==1 & T.cond==subsets(c));
                    i2(c) = find(T.SN==s & T.sess==2 & T.cond==subsets(c));
                end
                SS=(T.data(i1,voxIn)+T.data(i2,voxIn))/2;
                
                fprintf('%d cross\n',s);
                R.SN = ones(length(R.N),1)*s;
                R.subset=repmat(subsets,size(R.SN),1);
                R.corr = mva_spatialCorr(T.data([i1;i2],voxIn),BIN,...
                    'CrossvalPart',T.sess([i1;i2],1),'excludeNegVoxels',1);
                R.crossval = ones(length(R.corr),1);
                R.numSets=ones(length(R.N),1)*ns;
                RR = addstruct(RR,R);
                fprintf('%d correl\n',s);
                R.corr=mva_spatialCorr(SS,BIN);
                R.crossval = zeros(length(R.corr),1);
                RR = addstruct(RR,R);
            end;
        end
        outName=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),sprintf('spatialBoundfunc%d_subsets_%s%d.mat',data,subsetType,numTasks));
        save(outName,'-struct','RR');
    case 'EVAL:average' % make new 'spatialBoundfunc4.mat' struct. [4] - average eval corr across studies
        mapType=varargin{1}; % either 'cnvf_10' or 'Buckner_17Networks'
        condType=varargin{2}; % evaluating on 'unique','all','subsets_random7' etc
        level=varargin{3}; % 'group' or 'indiv' ?
        
        studyType=[1,2]; % test on one dataset
        evalType=[2,1]; % evaluate on the other
        R=[];
        
        vararginoptions({varargin{4:end}},{'sn'}); % option if doing individual map analysis
        
        encodeGLM=fullfile(studyDir{2},'encoding','glm4');
        
        switch level
            case 'group'
                for i=1:2
                    if ~isempty(strfind(mapType,'cnvf')) || ~isempty(strfind(mapType,'snn')),
                        if ~isempty(strfind(mapType,'SC12_cnvf'))
                            T=load(fullfile(encodeGLM,sprintf('groupEval_%s',mapType),sprintf('spatialBoundfunc%d_%s.mat',evalType(i),condType)));
                            outDir=fullfile(encodeGLM,sprintf('groupEval_%s',mapType),sprintf('spatialBoundfunc4_%s.mat',condType));
                        else
                            T=load(fullfile(encodeGLM,sprintf('groupEval_SC%d_%s',studyType(i),mapType),sprintf('spatialBoundfunc%d_%s.mat',evalType(i),condType)));
                            outDir=fullfile(encodeGLM,sprintf('groupEval_SC2_%s',mapType),sprintf('spatialBoundfunc4_%s.mat',condType));
                        end
                    else
                        T=load(fullfile(encodeGLM,sprintf('groupEval_%s',mapType),sprintf('spatialBoundfunc%d_%s.mat',evalType(i),condType)));
                        outDir=fullfile(encodeGLM,sprintf('groupEval_%s',mapType),sprintf('spatialBoundfunc4_%s.mat',condType));
                    end
                    T.studyNum=repmat([i],length(T.SN),1);
                    R=addstruct(R,T);
                end
            case 'indiv'
                for i=1:2,
                    if ~isempty(strfind(mapType,'cnvf')) || ~isempty(strfind(mapType,'snn')),
                        if ~isempty(strfind(mapType,'SC12_cnvf'))
                            T=load(fullfile(encodeGLM,subj_name{sn},sprintf('%s_spatialBoundfunc%d_%s.mat',mapType,evalType(i),mapType,i,condType)));
                            outDir=fullfile(encodeGLM,subj_name{sn},sprintf('%s_spatialBoundfunc4_%s.mat',mapType,condType));
                        else
                            T=load(fullfile(encodeGLM,subj_name{sn},sprintf('SC%d_%s_spatialBoundfunc%d_%s.mat',evalType(i),mapType,i,condType)));
                            outDir=fullfile(encodeGLM,subj_name{sn},sprintf('SC2_%s_spatialBoundfunc4_%s.mat',mapType,condType));
                        end
                    else
                        T=load(fullfile(encodeGLM,subj_name{sn},sprintf('%s_spatialBoundfunc%d_%s.mat',mapType,i,condType)));
                        outDir=fullfile(encodeGLM,subj_name{sn},sprintf('%s_spatialBoundfunc4_%s.mat',mapType,condType));
                    end
                    T.studyNum=repmat([i],length(T.SN),1);
                    R=addstruct(R,T);
                end
        end
        
        % remove subsets if 'random'
        if strfind(condType,'subsets')
            R=rmfield(R,{'distmin','distmax','N','subset'});
            % get average of both structures here
            A=tapply(R,{'bin','SN','bwParcel','crossval','numSets'},{'corr'});
        else
            R=rmfield(R,{'distmin','distmax','N'});
            % get average of both structures here
            A=tapply(R,{'bin','SN','bwParcel','crossval'},{'corr'});
        end
        
        % distances are diff across evals so need to get dist per bin:
        for b=1:length(unique(R.bin)),
            dist=mode(round(R.dist(R.bin==b)));
            idx=find(A.bin==b);
            A.dist(idx,1)=dist;
        end
        
        save(outDir,'-struct','A');
    case 'EVAL:PLOT:CURVES'
        mapType=varargin{1}; % options are 'lob10','lob26','bucknerRest','SC<studyNum>_<num>cluster', or 'SC<studyNum>_POV<num>'
        data=varargin{2}; % evaluating data from study [1] or [2], both [3] or average of [1] and [2] after eval [4]
        type=varargin{3}; % 'group' or 'leaveOneOut' or 'indiv'
        crossval=varargin{4}; % [0] - no crossval; [1] - crossval
        condType=varargin{5}; % evaluating on 'all' or 'unique' taskConds ??
        
        vararginoptions({varargin{6:end}},{'CAT','sn'}); % option if doing individual map analysis
        
        switch type,
            case 'group'
                T=load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapType),sprintf('spatialBoundfunc%d_%s.mat',data,condType)));
            case 'indiv'
                T=[];
                for s=1:length(sn)
                    tmp=load(fullfile(studyDir{2},'encoding','glm4',subj_name{sn(s)},sprintf('%s_spatialBoundfunc%d_%s.mat',mapType,data,condType)));
                    S=getrow(tmp,tmp.SN==sn(s)); % only predicting the same subject !
                    T=addstruct(T,S);
                end
            otherwise
                fprintf('no such case')
        end
        
        xyplot(T.dist,T.corr,T.dist,'split',T.bwParcel,'subset',T.crossval==crossval & T.dist<=35,'CAT',CAT,'leg',{'within','between'},'leglocation','SouthEast');
    case 'EVAL:PLOT:SUBSETS'
        mapType=varargin{1}; % 'SC2_cnvf_10' or 'SC2_snn_10'
        data=varargin{2}; % 1, 2, 4 . [1: eval on sc1; 2: eval on sc2; 4: eval on sc1+sc2]
        subset=varargin{3}; % 'random' or 'movies' or 'dissimilar' or 'all'
        numTasks=varargin{4}; % how many random tasks are we taking ? 7,5,3 ?
        crossval=varargin{5}; % 0 or 1
        
        vararginoptions({varargin{6:end}},{'CAT'}); % option if doing individual map analysis
        
        TT=[];
        % how many maps are we dealing with ?
        if size(mapType,2)>1
            for m=1:size(mapType,2)
                T=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType{m}),sprintf('spatialBoundfunc%d_subsets_%s%d.mat',data,subset,numTasks)));
                T.mapType=repmat(mapType(m),length(T.SN),1);
                T.mapNum=repmat(m,length(T.SN),1);
                TT=addstruct(TT,T);
            end
        else
            TT=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType{1}),sprintf('spatialBoundfunc%d_subsets_%s%d.mat',data,subset,numTasks)));
        end
        
        % distances are diff across evals so need to get dist per bin:
        for b=1:length(unique(TT.bin))
            dist=mode(round(TT.dist(TT.bin==b)));
            idx=find(TT.bin==b);
            TT.dist(idx,1)=dist;
        end
        
        switch subset
            case 'movies'
                P=getrow(TT,TT.crossval==crossval);
                % plot boxplot of different clusters
                W=getrow(P,P.bwParcel==0); % within
                B=getrow(P,P.bwParcel==1); % between
                W.diff=W.corr-B.corr;
                W=rmfield(W,{'bwParcel','crossval','corr'});
                
                % figure out plotting here
                if exist('CAT'),
                    lineplot(W.dist,W.diff,'subset',W.dist<=35,'CAT',CAT);
                else
                    lineplot(W.dist,W.diff,'subset',W.dist<=35);
                end
            case 'dissimilar'
                P=getrow(TT,TT.crossval==crossval);
                % plot boxplot of different clusters
                W=getrow(P,P.bwParcel==0); % within
                B=getrow(P,P.bwParcel==1); % between
                W.diff=W.corr-B.corr;
                W=rmfield(W,{'bwParcel','crossval','corr'});
                
                % figure out plotting here
                if exist('CAT')
                    lineplot(W.dist,W.diff,'subset',W.dist<=35,'CAT',CAT);
                else
                    lineplot(W.dist,W.diff,'subset',W.dist<=35);
                end
            case 'random'
                P=getrow(TT,TT.crossval==crossval);
                mapN=unique(TT.mapNum);
                
                for ii=1:length(mapN),
                    A=getrow(P,P.mapNum==ii);
                    % plot boxplot of different clusters
                    W{ii}=getrow(A,A.bwParcel==0); % within
                    B=getrow(A,A.bwParcel==1); % between
                    W{ii}.diff=W{ii}.corr-B.corr;
                    W{ii}=rmfield(W{ii},{'bwParcel','crossval','corr'});
                end
                W{1}=addstruct(W{1},W{2});
                
                % try this
                [x y]=sort(W{1}.diff);
                
                % plot diff between maps for each subset
                lineplot(W{1}.numSets,W{1}.diff,'subset',W{1}.dist<=35 & W{1}.numSets,'split',W{1}.mapNum,'CAT',CAT);
                
                %                  results=anovaMixed(W{1}.diff,W{1}.SN,'between',X,'betweenNames',{'a','b','c','d','e','f','g','h','i','j','k','l',...
                %                     'm','n','o','p','q','r','s','t'});
            otherwise
                disp('You need to give two maps as input to compare random task subsets \n')
        end
    case 'EVAL:PLOT:SUBSETS_DIFF'
        mapType=varargin{1}; % 'SC2_cnvf_10' or 'SC2_snn_10'
        data=varargin{2}; % 1, 2, 4 . [1: eval on sc1; 2: eval on sc2; 4: eval on sc1+sc2]
        subset=varargin{3}; % {'random'}
        numTasks=varargin{4}; % 7 or 5
        crossval=varargin{5}; % 1
        
        vararginoptions({varargin{6:end}},{'CAT'}); % option if doing individual map analysis
        
        TT=[];
        % how many maps are we dealing with ?
        for m=1:size(mapType,2)
            for s=1:length(subset)
                T=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType{m}),sprintf('spatialBoundfunc%d_subsets_%s%d.mat',data,subset{s},numTasks)));
                T.mapType=repmat(mapType(m),length(T.SN),1);
                T.mapNum=repmat(m,length(T.SN),1);
                T.subType=repmat(subset(s),length(T.SN),1);
                T.subset=repmat(s,length(T.SN),1);
                
                % distances are diff across evals so need to get dist per bin:
                for b=1:length(unique(T.bin))
                    dist=mode(round(T.dist(T.bin==b)));
                    idx=find(T.bin==b);
                    T.dist(idx,1)=dist;
                end
                
                A=getrow(T,T.crossval==crossval);
                % plot boxplot of different clusters
                W=getrow(A,A.bwParcel==0); % within
                B=getrow(A,A.bwParcel==1); % between
                W.diff=W.corr-B.corr;
                W=rmfield(W,{'bwParcel','crossval','corr'});
                
                TT=addstruct(TT,W);
            end
        end
        
        % load ordering of random subsets
        y=sc1_sc2_functionalAtlas('EVAL:get_subsets','evalRandom',numTasks);
        reOrderIdx=[y(:,data)];
        
        % plot diff maps
        indx=[];
        toPlot=[];
        for m=1:length(mapType),
            A=getrow(TT,strcmp(TT.mapType,mapType{m}));
            numRep=length(A.numSets)/length(reOrderIdx);
            reOrder=repelem(reOrderIdx,numRep);
            indx=[indx;reOrder];
            toPlot=[toPlot;A.diff];
        end
        lineplot(indx, toPlot,'style_shade','split',TT.mapType,'leg','auto')
    case 'EVAL:STATS:CURVES'
        mapType=varargin{1}; % options <
        data=varargin{2}; % evaluating data from study [1] or [2], both [3] or average of [1] and [2] after eval [4]
        type=varargin{3}; % 'group' or 'leaveOneOut' or 'indiv'
        crossval=varargin{4}; % [0] - no crossval; [1] - crossval
        condType=varargin{5}; % evaluating on 'all' or 'unique' taskConds ??
        
        vararginoptions({varargin{6:end}},{'sn'}); % option if doing individual map analysis
        
        switch type
            case 'group'
                T=load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapType),sprintf('spatialBoundfunc%d_%s.mat',data,condType)));
            case 'indiv'
                T=[];
                for s=1:length(sn)
                    tmp=load(fullfile(studyDir{2},'encoding','glm4',subj_name{sn(s)},sprintf('%s_spatialBoundfunc%d_%s.mat',mapType,data,condType)));
                    S=getrow(tmp,tmp.SN==sn(s)); % only predicting the same subject !
                    T=addstruct(T,S);
                end
            otherwise
                fprintf('no such case')
        end
        
        if ~exist('sn'),
            % do stats (over all bins) for group only
            C=getrow(T,T.crossval==crossval & T.dist<=35); % only crossval and dist<35
            S=tapply(C,{'bwParcel','SN'},{'corr'});
            fprintf('overall \n')
            ttest(S.corr(S.bwParcel==0), S.corr(S.bwParcel==1),2,'paired');
            
            % calculate effect size
            Group1=S.corr(S.bwParcel==0);
            Group2=S.corr(S.bwParcel==1);
            
            num=((Group1-1)*std(Group1)^2 + (Group2-1)*std(Group2)^2);
            denom=Group1+Group2-2;
            
            pooledSTD= sqrt(mean(num)/mean(denom));
            
            ES_pooled=(mean(Group1)-mean(Group2))/pooledSTD;
            
            fprintf('Effect size for within and between for %s is %2.2f when denom is pooled std  \n',mapType,ES_pooled);
            
            % summary stats
            x1=nanmean(S.corr(S.bwParcel==0));x2=nanmean(S.corr(S.bwParcel==1));
            SEM1=std(S.corr(S.bwParcel==0))/sqrt(length(returnSubjs));SEM2=std(S.bwParcel==1)/sqrt(length(returnSubjs));
            fprintf('average within corr is %2.2f; CI:%2.2f-%2.2f \n average between corr is %2.2f; CI:%2.2f-%2.2f \n',...
                nanmean(S.corr(S.bwParcel==0)),x1-(1.96*SEM1),x1+(1.96*SEM1),nanmean(S.corr(S.bwParcel==1)),...
                x2-(1.96*SEM2),x2+(1.96*SEM2));
        end
    case 'EVAL:PLOT:DIFF'
        mapType=varargin{1}; % {'lob10','bucknerRest','atlasFinal9'}
        data=varargin{2}; % evaluating data from study [1] or [2] or [4]?
        type=varargin{3}; % 'group' or 'indiv'
        crossval=varargin{4}; % [0]-no crossval; [1]-crossval
        condType=varargin{5}; % evaluating on 'unique' or 'all' taskConds ??
        
        vararginoptions({varargin{6:end}},{'CAT','sn','snToPred'}); % option if plotting individual map analysis.
        % 'sn' option - which indiv subject map ? 'snToPred', which
        % subjects do you want to predict ?
        
        switch type
            case 'group'
                T=[];
                if ~exist('snToPred'),
                    sn=returnSubjs;
                else
                    sn=snToPred;
                end
                for s=1:length(sn)
                    tmp=load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapType),sprintf('spatialBoundfunc%d_%s.mat',data,condType)));
                    S=getrow(tmp,tmp.SN==sn(s)); % which subjs to predict ?
                    T=addstruct(T,S);
                end
            case 'indiv'
                T=[];
                if ~exist('sn'),
                    sn=returnSubjs;
                end
                for s=1:length(sn)
                    tmp=load(fullfile(studyDir{2},'encoding','glm4',subj_name{sn(s)},sprintf('%s_spatialBoundfunc%d_%s.mat',mapType,data,condType)));
                    S=getrow(tmp,tmp.SN==sn(s)); % only predicting the same subject !
                    T=addstruct(T,S);
                end
        end
        P=getrow(T,T.crossval==crossval);
        
        % plot boxplot of different clusters
        W=getrow(P,P.bwParcel==0); % within
        B=getrow(P,P.bwParcel==1); % between
        W.diff=W.corr-B.corr;
        W=rmfield(W,{'bwParcel','crossval','corr'});
        
        if exist('CAT'),
            lineplot(W.dist,W.diff,'subset',W.dist<=35,'CAT',CAT,'leg','auto');
        else
            lineplot(W.dist,W.diff,'subset',W.dist<=35);
        end
    case 'EVAL:STATS:DIFF'
        mapType=varargin{1}; % {'lob10','bucknerRest','SC2_<algorithm>_<numCluster>'}
        data=varargin{2}; % evaluating data from study [1] or [2] or [4]?
        type=varargin{3}; % 'group' or 'indiv'
        crossval=varargin{4}; % [0]-no crossval; [1]-crossval
        condType=varargin{5}; % evaluating on 'unique' or 'all' or 'subsets_movies3'
        
        % if getting diff between indiv lob and group lob:
        % sc1_sc2_functionalAtlas('EVAL:STATS:DIFF',{'lob10','averageLob'},4,'group',1,'unique','snToPred',[26:31])
        
        % example: sc1_sc2_functionalAtlas('EVAL:STATS:DIFF',{'SC1_cnvf_10','Buckner_17Networks'},[2 2],'group',1,'subsets_movies3')
        vararginoptions({varargin{6:end}},{'CAT','sn','snToPred'}); % option if plotting individual map analysis.
        
        % do stats
        P=[];
        for m=1:length(mapType),
            switch type,
                case 'group'
                    T=[];
                    if ~exist('snToPred'),
                        sn=returnSubjs;
                    else
                        sn=snToPred;
                    end
                    for s=1:length(sn)
                        tmp=load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapType{m}),sprintf('spatialBoundfunc%d_%s.mat',data,condType)));
                        S=getrow(tmp,tmp.SN==sn(s)); % which subjs to predict ?
                        T=addstruct(T,S);
                    end
                case 'indiv'
                    T=[];
                    if ~exist('sn'),
                        sn=returnSubjs;
                    end
                    for s=1:length(sn)
                        tmp=load(fullfile(studyDir{2},'encoding','glm4',subj_name{sn(s)},sprintf('%s_spatialBoundfunc%d_%s.mat',mapType{m},data(m),condType)));
                        S=getrow(tmp,tmp.SN==sn(s)); % only predicting the same subject !
                        T=addstruct(T,S);
                    end
            end
            A=getrow(T,T.crossval==crossval);
            A.type=repmat({sprintf('%d.%s',m,mapType{m})},length(A.bin),1);
            A.m=repmat(m,length(A.bin),1);
            P=addstruct(P,A);
            clear A
        end
        
        W=getrow(P,P.bwParcel==0); % within
        B=getrow(P,P.bwParcel==1); % between
        W.diff=W.corr-B.corr;
        % do stats (integrate over spatial bins)
        W=rmfield(W,{'bwParcel','crossval','corr'});
        C=getrow(W,W.dist<=35);
        S=tapply(C,{'m','SN','type'},{'diff'});
        
        % do F test (or t test if just two groups)
        if length(unique(S.m))>2,
            X=[S.diff(S.m==1),S.diff(S.m==2),S.diff(S.m==3)];
            results=anovaMixed(S.diff,S.SN,'between',S.m,'betweenNames',{'a','b','c'});
            
        else
            ttest(S.diff(S.m==1), S.diff(S.m==2),2,'paired');
            
            % calculate effect size
            Group1=S.diff(S.m==1);
            Group2=S.diff(S.m==2);
            
            ES_group1=(mean(Group1)-mean(Group2))/std(Group1); % uses the std of one of the groups
            ES_group2=(mean(Group1)-mean(Group2))/std(Group2); % uses the std of one of the groups
            % this is biased as the effect size changes depending on which
            % group you choose. Therefore, pooled estimate is better.
            
            num=((Group1-1)*std(Group1)^2 + (Group2-1)*std(Group2)^2);
            denom=Group1+Group2-2;
            
            pooledSTD= sqrt(mean(num)/mean(denom));
            
            ES_pooled=(mean(Group1)-mean(Group2))/pooledSTD;
            
            fprintf('Effect size between %s and %s is %2.2f when denom is std(Group1) \n',mapType{1},mapType{2},ES_group1);
            fprintf('Effect size between %s and %s is %2.2f when denom is std(Group2) \n',mapType{1},mapType{2},ES_group2);
            fprintf('Effect size between %s and %s is %2.2f when denom is pooled std  \n',mapType{1},mapType{2},ES_pooled);
            
        end
    case 'EVAL:PLOT_allMaps'
        mapType={'SC12_cnvf_7','SC12_cnvf_8','SC12_cnvf_9','SC12_cnvf_10','SC12_cnvf_11','SC12_cnvf_12','SC12_cnvf_15','SC12_cnvf_17'};
        data=4;
        crossval=1;
        condType='unique';
        
        T=[];
        for m=1:length(mapType),
            RR=load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapType{m}),sprintf('spatialBoundfunc%d_%s.mat',data,condType)));
            RR.mapType=repmat(mapType(m),length(RR.SN),1);
            RR.mapNum=repmat(m,length(RR.SN),1);
            T=addstruct(T,RR);
        end
        
        P=getrow(T,T.crossval==crossval);
        
        % plot boxplot of different clusters
        W=getrow(P,P.bwParcel==0); % within
        B=getrow(P,P.bwParcel==1); % between
        W.diff=W.corr-B.corr;
        W=rmfield(W,{'bwParcel','crossval','corr'});
        
        lineplot(W.mapNum,W.diff,'subset',W.dist<=35,'style_shade');
        
        % Labelling
        set(gca,'YLim',[0.14 0.17],'YLim',[0.14 .17],'ytick',[0.14:.01:.17],'FontSize',12,...
            'xtick',[1:length(mapType)],'XTickLabel',{'7','8','9','10','11','12','15','17'});
        xlabel('Maps');
        ylabel('DCBC');
        set(gcf,'units','centimeters','position',[5,5,9,12])
        
    case 'reformat:average_maps'
        mapTypes=varargin{1}; % {'Buckner_17Networks,'Buckner_7Networks'};
        outName=varargin{2}; % ex. 'averageRest'
        
        S=[];
        for m=1:length(mapTypes),
            
            T=load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapTypes{m}),sprintf('spatialBoundfunc%d_%s.mat',4,'unique')));
            T.map=repmat(m,length(T.SN),1);
            S=addstruct(S,T);
            clear T
        end
        
        % get average struct
        R=tapply(S,{'bin','SN','bwParcel','dist','crossval'},{'corr'});
        
        dircheck(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',outName)));
        save(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',outName),sprintf('spatialBoundfunc%d_%s.mat',4,'unique')),'-struct','R');
    case 'reformat_indivEval' % reformat indivEval into original format
        generalisation=varargin{1}; % 0 or 1
        
        mapTypes={'SC12_10cluster_group_spatialBoundfunc4_unique.mat','SC2_10cluster_group_spatialBoundfunc4_unique.mat'};
        
        
        T=load(fullfile(studyDir{2},'encoding','glm4','individEval_10cluster','spatialBoundfunc_10cluster_unique.mat'));
        
        A=getrow(T,T.generalisation==generalisation);
        A=rmfield(A,{'distmin','distmax','N','generalisation'});
        % get average of both structures here
        B=tapply(A,{'bin','SN','bwParcel','crossval'},{'corr'});
        
        
        % distances are diff across evals so need to get dist per bin:
        for b=1:length(unique(A.bin)),
            dist=mode(round(A.dist(A.bin==b)));
            idx=find(B.bin==b);
            B.dist(idx,1)=dist;
        end
        
        subjs=unique(T.SN);
        
        for s=1:length(subjs),
            S=getrow(B,B.SN==subjs(s));
            save(fullfile(studyDir{2},'encoding','glm4',subj_name{subjs(s)},mapTypes{generalisation+1}),'-struct','S');
            fprintf('subj %s done \n',subj_name{subjs(s)});
        end
    case 'reformat:average_indivLob'
        
        outName='averageLob';
        mapType='lob10';
        data=4;
        condType='unique';
        
        sn=[26:31]; % indiv lobular parcellations were made for these subjs
        %         for m=1:length(mapTypes),
        %
        %             T=load(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapTypes{m}),sprintf('spatialBoundfunc%d_%s.mat',4,'unique')));
        %             T.map=repmat(m,length(T.SN),1);
        %             S=addstruct(S,T);
        %             clear T
        %         end
        T=[];
        for s=1:length(sn)
            tmp=load(fullfile(studyDir{2},'encoding','glm4',subj_name{sn(s)},sprintf('%s_spatialBoundfunc%d_%s.mat',mapType,data,condType)));
            S=getrow(tmp,tmp.SN==sn(s)); % only predicting the same subject !
            T=addstruct(T,S);
        end
        
        % get average struct
        R=tapply(T,{'bin','SN','bwParcel','dist','crossval'},{'corr'});
        
        dircheck(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',outName)));
        save(fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',outName),sprintf('spatialBoundfunc%d_%s.mat',4,'unique')),'-struct','R');
        
    case 'STRENGTH:get_bound'
        % This goes from a group parcellation map and generates a
        % structure of clusters and boundaries from the volume
        mapType = varargin{1}; % SC12_cnvf_10
        sn=varargin{2}; % [2] or 'group'
        
        bDir    = fullfile(studyDir{2},'encoding','glm4');
        load(fullfile(bDir,'cereb_avrgDataStruct.mat'));
        
        % figure out if individual or group
        if strcmp(sn,'group'),
            mapName=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'map.nii');
            EvalDir = fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapType),'boundaries.mat');
            % individual analysis
        else
            mapName=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn},sprintf('map_%s.nii',mapType));
            EvalDir = fullfile(studyDir{2},'encoding','glm4',subj_name{sn},sprintf('boundaries_%s.mat',mapType));
        end
        
        % Get the parcellation data
        [i,j,k]=ind2sub(V.dim,volIndx);
        [x,y,z]=spmj_affine_transform(i,j,k,V.mat);
        VA= spm_vol(mapName);
        [i1,j1,k1]=spmj_affine_transform(x,y,z,inv(VA.mat));
        Parcel = spm_sample_vol(VA,i1,j1,k1,0);
        
        % Find unique clusters for each parcel
        numParcel = max(Parcel); % was 28 (from Joern's code)
        Cluster = nan(size(Parcel));
        n=1;
        coords=[i;j;k];     % Voxel coordinates in original image
        for p=1:numParcel
            indx = find(Parcel==p);
            A= spm_clusters(coords(:,indx));
            numCluster=max(A);
            for c=1:numCluster
                clInd = (A==c);
                N=sum(clInd);
                if N>=5  % ignore clusters of smaller than 5
                    Cluster(indx(clInd))=n;
                    n=n+1;
                end;
            end;
        end;
        
        % Check how assignment went
        pivottable(Cluster',Parcel',Cluster','length','subset',~isnan(Cluster'));
        
        % Now detect boundaries between adjacent parcels
        numCluster = max(Cluster);
        n=1;
        for i=1:numCluster
            for j=i+1:numCluster
                D=surfing_eucldist(coords(:,Cluster==i),coords(:,Cluster==j));
                if min(D(:))< 1.4 % direct connectivity scheme
                    Edge(n,:) = [i j];
                    n=n+1;
                end;
            end;
        end;
        
        % Visualise using graph toolbox
        G = graph(Edge(:,1),Edge(:,2));
        plot(G)
        save(EvalDir,'V','volIndx','Parcel','Cluster','coords','Edge');
    case 'STRENGTH:fullEval'
        mapType = varargin{1};
        sn      = varargin{2};
        
        % figure out if individual or group
        if strcmp(sn,'group'),
            EvalDir = fullfile(studyDir{2},'encoding','glm4',sprintf('groupEval_%s',mapType),'BoundariesFun3_all.mat');
            % individual analysis
        else
            EvalDir = fullfile(studyDir{2},'encoding','glm4',subj_name{sn},sprintf('BoundariesFun3_all_%s.mat',mapType));
        end
        
        T1=sc1_sc2_functionalAtlas('STRENGTH:eval_bound',mapType,1,'unique',sn);
        T2=sc1_sc2_functionalAtlas('STRENGTH:eval_bound',mapType,2,'unique',sn);
        T1.study = ones(length(T1.SN),1)*1;
        T2.study = ones(length(T1.SN),1)*2;
        T=addstruct(T1,T2);
        save(EvalDir,'-struct','T');
        varargout={T};
    case 'STRENGTH:eval_bound'
        mapType = varargin{1}; % 'SC12_10cluster','Buckner_7Networks'
        study   = varargin{2}; % evaluating data from study [1] or [2] ?
        condType = varargin{3}; % 'unique' or 'all'
        sn=varargin{4};
        
        spatialBins = [0:3:35];
        
        bDir    = fullfile(studyDir{2},'encoding','glm4');
        
        % figure out if individual or group
        if strcmp(sn,'group'),
            EvalDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'boundaries.mat');
            % individual analysis
        else
            EvalDir=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn},sprintf('boundaries_%s.mat',mapType));
        end
        
        load(EvalDir);
        numBins = length(spatialBins)-1;
        
        % Get the condition numbers
        D=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt'));
        D1=getrow(D,D.StudyNum==study);
        switch condType,
            case 'unique'
                % if funcMap - only evaluate unique tasks in sc1 or sc2
                idx=D1.condNum(D1.overlap==0); % get index for unique tasks
            case 'all'
                idx=D1.condNum;
        end;
        
        % Load activity data
        load(fullfile(studyDir{study},encodeDir,'glm4','cereb_avrgDataStruct.mat'));
        RR=[];    % Output structure.
        
        % Now build a structure all boundaries
        for i=1:size(Edge,1)
            indx = Cluster==Edge(i,1) | Cluster==Edge(i,2);  % Get all the involved voxels
            fprintf('Edge %d %d\n',Edge(i,1),Edge(i,2));
            
            % Determine the spatial bins for this pair of regions
            [BIN,R]=mva_spatialCorrBin(coords(:,indx),'Parcel',Cluster(indx)','spatialBins',spatialBins);
            N=length(R.N);
            
            % Now determine the correlation for each subject
            for s=unique(T.SN)';
                fprintf('Subj:%d\n',s);
                for c=1:length(idx),
                    i1(c) = find(T.SN==s & T.sess==1 & T.cond==idx(c));
                    i2(c) = find(T.SN==s & T.sess==2 & T.cond==idx(c));
                end
                D=(T.data(i1,indx)+T.data(i2,indx))/2; % average data
                fprintf('%d cross\n',s);
                R.Edge = repmat(Edge(i,:),N,1);
                R.SN = ones(N,1)*s;
                R.corr = mva_spatialCorr(T.data([i1;i2],indx),BIN,...
                    'CrossvalPart',T.sess([i1;i2],1),'excludeNegVoxels',1,'numBins',N);
                R.crossval = ones(N,1);
                if (length(R.corr)~=N)
                    keyboard;
                end;
                RR = addstruct(RR,R);
                fprintf('%d correl\n',s);
                R.corr=mva_spatialCorr(D,BIN,'numBins',N);
                R.crossval = zeros(N,1);
                if (length(R.corr)~=N)
                    keyboard;
                end;
                RR = addstruct(RR,R);
            end;
        end;
        varargout={RR};
    case 'STRENGTH:visualise_bound'
        mapType = varargin{1};
        
        bcolor ='k';
        opacacy = 0.5;
        bscale = 180;
        bmax=20;
        vararginoptions(varargin(2:end),{'bcolor','opacacy','bscale','bmax','sn'});
        
        % group or individual
        if exist('sn')==0,
            EvalDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'boundaries.mat');
            T=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'BoundariesFunc3_all.mat')); % Evaluate the strength of each border
            colourDir=fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType));
            % individual analysis
        else
            EvalDir=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn},sprintf('boundaries_%s.mat',mapType));
            T=load(fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn},sprintf('BoundariesFun3_all_%s.mat',mapType))); % Evaluate the strength of each border
            colourDir=fullfile(studyDir{2},encodeDir,'glm4',subj_name{sn});
        end
        load(EvalDir)
        
        % Map the clusters
        V.dat=zeros([V.dim(1) V.dim(2) V.dim(3)]);
        V.dat(volIndx)=Cluster;
        C{1}=V;
        C{1}=rmfield(C{1},{'fname','dt','pinfo','n','descrip','private'});
        Mcl=caret_suit_map2surf(C,'space','SUIT','stats','mode','stats',@mode);
        Mcl=Mcl.data;
        
        % Map the parcel
        C{1}.dat(volIndx)=Parcel;
        Mpa=caret_suit_map2surf(C,'space','SUIT','stats','mode','stats',@mode);
        Mpa=Mpa.data;
        
        % Determine the border points
        COORD=gifti(fullfile('FLAT.coord.gii'));
        TOPO=gifti(fullfile('CUT.topo.gii'));
        
        % Make matrix of all the unique edges of the flatmap
        Tedges=[TOPO.faces(:,[1 2]);TOPO.faces(:,[2 3]);TOPO.faces(:,[1 3])]; % Take 3 edges from the faces
        Tedges= [min(Tedges,[],2) max(Tedges,[],2)];     % Sort in ascending order
        Tedges = unique(Tedges,'rows');                  % Only retain each edge ones
        EdgeCl=Mcl(Tedges);                              % Which cluster does each node belong to?
        EdgeCl= [min(EdgeCl,[],2) max(EdgeCl,[],2)];     % Sort in ascending order
        
        % Assemble the edges that lie on the boundary between clusters
        for  i=1:size(Edge,1)
            indxEdge = find(EdgeCl(:,1)==Edge(i,1) & EdgeCl(:,2)==Edge(i,2));
            Border(i).numpoints=length(indxEdge);
            for e=1:length(indxEdge)
                % find the boundary point: In the middle of the edge
                Border(i).data(e,:)=(COORD.vertices(Tedges(indxEdge(e),1),:)+...
                    COORD.vertices(Tedges(indxEdge(e),2),:))/2; % Average of coordinates
            end;
        end;
        
        for  i=1:size(Edge,1)
            % Make sure that the bin is calcualted both for within and
            % between
            A=pivottable(T.bin,T.bwParcel,T.corr,'nanmean','subset',T.crossval==1 & ...
                T.Edge(:,1)==Edge(i,1) & T.Edge(:,2)==Edge(i,2));
            EdgeWeight(i,1)=nanmean(A(:,1)-A(:,2));  % Difference within - between
        end;
        
        % check if a color map is provided
        if exist(fullfile(colourDir,'colourMap.txt'),'file'),
            cmap=load(fullfile(colourDir,'colourMap.txt'));
            cmap=cmap(:,2:4);
            cmapF=cmap/255;
        else
            cmapF=colorcube(max(Parcel));
        end
        %         cmapF = bsxfun(@plus,cmapF*opacacy,[1 1 1]*(1-opacacy));
        
        % Make the plot
        whitebg
        suit_plotflatmap(Mpa,'type','label','border',[],'cmap',cmapF);
        whitebg
        hold on;
        LineWeight=EdgeWeight*bscale;
        LineWeight(LineWeight>bmax)=bmax;
        for  b=1:length(Border)
            if (Border(b).numpoints>0 & EdgeWeight(b)>0),
                p=plot(Border(b).data(:,1),Border(b).data(:,2),'k.');
                set(p,'MarkerSize',LineWeight(b));
                weights(b)=EdgeWeight(b);
                % plot DCBC of each functional boundary ?
                %                 p=text(double(Border(b).data(1,1)),double(Border(b).data(1,2)),sprintf('%2.3f',weights(b)));
                %                 set(p,'FontSize',20);
            end;
        end
        hold off;
        tmp=weights(weights~=0);
        
        fprintf('min diff is %2.5f and max diff is %2.2f \n', min(tmp),max(tmp));
        
    case 'ENCODE:get_features'
        mapType=varargin{1};
        
        D=dload(fullfile(baseDir,'featureTable_functionalAtlas.txt'));
        
        %         D=dload(fullfile(baseDir,'featureTable_jd_updated.txt')); % Read feature table - updated with new features "naturalistic bio motion" and "naturalistic scenes"
        S=dload(fullfile(baseDir,'sc1_sc2_taskConds.txt')); % List of task conditions
        
        load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'cnvf.mat'));
        W=pivottablerow(S.condNumUni,bestF,'mean(x,1)'); % we only want unique taskConds
        
        % get new condNames (unique only)
        condNames=[S.condNames(S.StudyNum==1);S.condNames(S.StudyNum==2 & S.overlap==0)];
        
        % Make the feature matrix
        D.LeftHand    = D.leftHandPresses ./D.duration;
        D.RightHand   = D.rightHandPresses ./D.duration;
        D.Saccade    = D.saccades./D.duration;
        
        % remove superfluous
        D=rmfield(D,{'leftHandPresses','rightHandPresses','saccades','Imagination','LongtermMemory','SceneRecog'});
        %         D=rmfield(D,{'leftHandPresses','rightHandPresses','saccades'});
        
        f=fieldnames(D);
        FeatureNames = f(5:end);
        F=[];
        for d=1:length(FeatureNames)
            F = [F D.(FeatureNames{d})];
        end;
        F= bsxfun(@rdivide,F,sum(F.^2,1));
        numCond = length(D.conditionName);
        numFeat = length(FeatureNames);
        numClusters = size(W,2);
        
        lambda = [0.01 0.001];
        X=bsxfun(@minus,F,mean(F,1));
        
        Y=bsxfun(@minus,W,mean(W,1));
        X=bsxfun(@rdivide,X,sqrt(mean(X.^2)));
        Y=bsxfun(@rdivide,Y,sqrt(mean(Y.^2)));
        XX=X'*X;
        XY=X'*Y;
        A = -eye(numFeat);
        b = zeros(numFeat,1);
        
        for p=1:numClusters,
            %             u(:,p) = cplexqp(XX+lambda(2)*eye(numFeat),ones(numFeat,1)*lambda(1)-XY(:,p),A,b);
            u(:,p) = lsqnonneg(X,double(Y(:,p)));
        end;
        
        % Get corr between feature weights
        C=corr(F,W);
        
        % Present the list of the largest three weights for each
        % cluster
        for i=1:numClusters,
            [a,b]=sort(u(:,i),'descend');
            B.clusters(i,1)=i;
            % get 3 highest corrs
            for f=1:3,
                B.featNames{i,f}=FeatureNames{b(f)};
                B.featIdx(i,f)=b(f);
                B.featCorrs(i,f)=a(f);
            end
            % what % do top 3 make up of overall features ?
            B.relSum(i,1)=(a(1)+a(2)+a(3))/sum(a)*100;
            B.relSuma(i,1)=(a(1))/sum(a)*100;
        end;
        
        %         fprintf('on average, %2.2f%% of all feature weights are accounted by the top 3 features \n with the top feature accounting for %2.2f %% \n',mean(B.relSum),mean(B.relSuma));
        fprintf('on average, %2.2f%% of all feature weights are accounted by the top 3 features \n with the top feature accounting for %2.2f %% \n',mean(B.relSum),mean(B.relSuma));
        
        varargout={B,F,W,u,condNames,FeatureNames,X,Y};
    case 'ENCODE:project_featSpace'
        mapType=varargin{1};
        toPlot=varargin{2}; % 'winner' or 'all' or 'featMatrix'
        
        sizeWeight=40;
        
        % get features
        [B,F,~,C,condNames,FeatureNames]=sc1_sc2_functionalAtlas('ENCODE:get_features',mapType);
        
        % get cluster colours
        cmap=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'colourMap.txt'));
        cmap=cmap/255;
        
        switch toPlot,
            case 'featList_all'
                % Make word lists for word map
                DD = C;WORD=FeatureNames;
                DD(DD<0)=0;
                DD=DD./max(DD(:));
                numClusters=size(C,2);
                numFeat=size(C,1);
                for j=1:numClusters,
                    subplot(2,5,j);
                    title(sprintf('Region %d',j),'Color',cmap(j,2:4),'FontSize',18)
                    set(gca,'Xticklabel',[],'Yticklabel',[])
                    for i=1:numFeat
                        if (DD(i,j)>.25)
                            siz=ceil(DD(i,j)*sizeWeight);
                            text(unifrnd(0,1,1),unifrnd(0,1,1),WORD{i},'FontSize',siz,'Color',cmap(j,2:4));
                        end;
                    end;
                end;
                %                 imagesc_rectangle(C);
                %                 caxis([0 1]);
                %                 t=set(gca,'Ytick',[1:length(FeatureNames)]','YTickLabel',FeatureNames');
                %                 t.Color='white';
                %                 colorbar
            case 'featList_winner'
                % figure out where to position features
                for i=1:size(B.featNames,1),
                    subplot(2,5,i);
                    set(gca,'XLim',[0 2.5],'YLim',[-0.2 1.2]);
                    text(0,1.2,sprintf('Region %d',i),'FontSize',20,'Color',cmap(i,2:4));
                    for j=1:size(B.featNames,2),
                        siz=ceil(B.featCorrs(i,j)*20);
                        text(unifrnd(0,1,1),unifrnd(0,1,1),B.featNames{i,j},'FontSize',siz,'Color',cmap(i,2:4));
                    end
                end
            case 'featMatrix'
                imagesc_rectangle(F');
                caxis([0 1]);
                t=set(gca,'Ytick',[1:length(FeatureNames)]','YTickLabel',FeatureNames',...
                    'Xtick',[1:length(condNames)]');
                t.Color='white';
        end
    case 'ENCODE:project_taskSpace'
        mapType=varargin{1};
        toPlot=varargin{2}; % 'taskList_all' or 'taskMatrix'
        
        sizeWeight=35;
        
        % get features
        [B,~,W,~,condNames]=sc1_sc2_functionalAtlas('ENCODE:get_features',mapType);
        
        % project back to task-space
        load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'SNN.mat'));
        %         W=bestF;
        L=W'*W;
        I=diag(diag(sqrt(L))); % diag not sum
        X=W/I;
        
        % get cluster colours
        cmap=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'colourMap.txt'));
        cmap=cmap/255;
        
        switch toPlot,
            case 'taskList_all'
                % Make word lists for word map
                DD = W;WORD=condNames;
                DD(DD<0)=0;
                DD=DD./max(DD(:));
                numClusters=size(DD,2);
                numFeat=size(DD,1);
                for j=1:numClusters,
                    subplot(2,5,j);
                    set(gca,'Xticklabel',[],'Yticklabel',[])
                    title(sprintf('Network %d',j),'Color',cmap(j,2:4))
                    set(gca,'FontSize',18);
                    for i=1:numFeat
                        if (DD(i,j)>0.25)
                            siz=ceil(DD(i,j)*sizeWeight);
                            text(unifrnd(0,1,1),unifrnd(0,1,1),WORD{i},'FontSize',siz,'Color',cmap(j,2:4));
                        end;
                    end;
                end;
            case 'taskMatrix'
                imagesc_rectangle(X);
                caxis([0 1]);
                t=set(gca,'Ytick',[1:length(condNames)]','YTickLabel',condNames');
                t.Color='white';
                colorbar
        end
    case 'ENCODE:scatterplot'
        mapType=varargin{1};
        type=varargin{2};
        toPlot=varargin{3}; % 1 is [4,10] - left & right hand tasks etc
        
        CAT.markersize=12;
        CAT.labelsize=18;
        sizeWeight=50;
        %         vararginoptions({varargin{3:end}},{'CAT'});
        
        % get features
        [B,F,W,C,condNames,FeatureNames]=sc1_sc2_functionalAtlas('ENCODE:get_features',mapType);
        
        % project back to task-space
        load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'SNN.mat'));
        %         W=bestF;
        L=W'*W;
        I=diag(diag(sqrt(L))); % diag not sum
        X=W/I;
        
        % load in colourMap
        cmap=load(fullfile(studyDir{2},encodeDir,'glm4',sprintf('groupEval_%s',mapType),'colourMap.txt'));
        cmap=cmap(:,2:4)/255;
        
        switch type,
            case 'features'
                net1=C(:,toPlot(1));
                net2=C(:,toPlot(2));
                
                for i=1:size(C,1),
                    if net1(i)>0 & net2(i)<0,
                        colourIdx{i,:}=cmap(toPlot(1),:);
                        siz{i,1}=ceil(net1(i)*sizeWeight);
                    elseif net2(i)>0 & net1(i)<0,
                        colourIdx{i,:}=cmap(toPlot(2),:);
                        siz{i,1}=ceil(net2(i)*sizeWeight);
                    elseif net1(i)>0 & net2(i)>0,
                        colourIdx{i,:}=[0 0 0];
                        siz{i,1}=ceil((net1(i)+net2(i))/2*sizeWeight);
                    elseif net1(i)<0 & net2(i)<0,
                        colourIdx{i,:}=[.7 .7 .7];
                        siz{i,1}=ceil((abs(net1(i)+net2(i)/2))*sizeWeight);
                    else
                        colourIdx{i,:}=[.7 .7 .7];
                        siz{i,1}=ceil((abs(net1(i)+net2(i)/2))*sizeWeight);
                    end
                end
                XY=C;
                names=FeatureNames;
            case 'tasks'
                net1=B.featIdx(toPlot(1),1);
                net2=B.featIdx(toPlot(2),1);
                % assign tasks to features (to colour-code)
                for i=1:size(X,1),
                    if F(i,net1)>0 & F(i,net2)==0, % assign to network1
                        colourIdx{i,:}=cmap(toPlot(1),:);
                    elseif F(i,net2)>0 & F(i,net1)==0, % assign to network2
                        colourIdx{i,:}=cmap(toPlot(2),:);
                    elseif F(i,net1)>0 & F(i,net2)>0,
                        colourIdx{i,:}=[0 0 0]; % tasks that load onto both features
                    elseif F(i,net1)==0 & F(i,net2)==0,
                        colourIdx{i,:}=[.7 .7 .7]; % tasks that don't load onto features - grey out
                    else
                        colourIdx{i,:}=[.7 .7 .7];
                    end
                end
                XY=X;
                names=condNames;
        end
        CAT.markercolor=colourIdx;
        CAT.markerfill=colourIdx;
        CAT.labelcolor=colourIdx;
        CAT.labelsize=siz;
        
        scatterplot(XY(:,toPlot(1)),XY(:,toPlot(2)),'label',names,'intercept',0,'draworig','CAT',CAT);
        xlabel(sprintf('Network%d',toPlot(1)));ylabel(sprintf('Network%d',toPlot(2)));
        
    case 'AXES:BEHAVIOURAL'
        % aesthetics
        CAT.errorwidth=.5;
        CAT.markertype='none';
        CAT.linestyle={'-'};
        CAT.linewidth={3};
        CAT.errorcolor={'k'};
        CAT.linecolor={'k'};
        
        sc1_sc2_functionalAtlas('PLOT:behavioural','scanning','run','CAT',CAT)
        
        % Labelling
        set(gca,'YLim',[.8 1],'ytick',[.8 .85 .9 .95 1],'FontSize',12,'xticklabel',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16'});
        xlabel('Runs')
        ylabel('Accuracy (%)')
        set(gcf,'units','centimeters','position',[5,5,6,6])
    case 'AXES:eigenValues'
        % Aesthetics
        CAT.markersize=8;
        CAT.markertype='^';
        CAT.linewidth=4;
        CAT.linecolor={'r','k'};
        CAT.markercolor={'r','k'};
        CAT.markerfill={'r','k'};
        
        sc1_sc2_functionalAtlas('REPRESENTATION:eigDecomp',CAT)
        set(gcf,'units','points','position',[5,5,1000,1000])
        set(gca,'FontSize',14);
        ylabel('Eigenvalues')
        xlabel('# of dimensions')
    case 'AXES:reliability'
        toPlot=varargin{1}; % 'D' (for distance) or 'A' (for activity)
        toPlotName=varargin{2}; % 'distance reliability' or 'activity reliability'
        
        sc1_sc2_functionalAtlas(sprintf('PLOT:reliability%s',toPlot))
        
        % Labelling
        set(gca,'FontSize',18);
        set(gca,'XTickLabel',{'SC1','SC2','across'})
        ylabel('Activity Correlation (R)');
        title(toPlotName)
        set(gcf,'units','points','position',[5,5,1000,1000])
    case 'AXES:RDM'
        type=varargin{1}; % 'all' or 'unique' tasks
        
        % aesthetics
        sc1_sc2_functionalAtlas('REPRESENTATION:RDM',type)
        axis equal
        set(gcf,'units','points','position',[5,5,1000,1000])
    case 'AXES:MDS' % plots MDS plot
        taskType=varargin{1}; % 'unique' or 'all' taskConds
        
        % aesthetics
        CAT.markersize=10;
        CAT.markertype='o';
        CAT.labelsize=18;
        
        sc1_sc2_functionalAtlas('REPRESENTATION:MDS',taskType,'region','CAT',CAT)
        set(gcf,'units','points','position',[5,5,1000,1000])
        axis equal;
        set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[],'Box','on');
        xlabel('PC1');ylabel('PC2');zlabel('PC3')
        view([81 9]);
    case 'AXES:map' % takes any volume and plots on surface
        toPlot=varargin{1}; % 'Cole_10Networks', 'Buckner_7Networks','SC12_10cluster'
        toPlotName=varargin{2}; % 'Cole10', 'Buckner7', ...
        
        vararginoptions({varargin{3:end}},{'border','sn'}); % option if doing individual map analysis
        
        % plot borders ?
        if exist('border'),
            sc1_sc2_functionalAtlas('MAP:vol2surf',toPlot,'no','border',[])
        else
            sc1_sc2_functionalAtlas('MAP:vol2surf',toPlot,'no')
        end
        
        % one subject or group ?
        if exist('sn'),
            sc1_sc2_functionalAtlas('MAP:vol2surf',toPlot,'no','sn',sn)
        end
        
        title(toPlotName);
        set(gcf,'units','points','position',[5,5,1000,1000])
        set(gca,'Xticklabel',[],'Yticklabel',[])
        axis off
    case 'AXES:allSNN_similarity' % matrix of rand indices between all SNN maps (SC12)
        K=[5:25];
        for k=1:length(K),
            toPlot{k}=sprintf('SC12_%dcluster',K(k));
            toPlotNames{k}=sprintf('%d',K(k));
        end
        
        [RI]=sc1_sc2_functionalAtlas('MAP:compare',toPlot);
        
        figure()
        imagesc_rectangle(RI,'YDir','reverse');
        caxis([0 1]);
        t=set(gca,'Ytick',[1:length(toPlot)]','YTickLabel',toPlotNames',...
            'FontSize',10,'Xtick',[1:length(toPlot)]','XTickLabel',toPlotNames','FontSize',14);
        t.Color='white';
        colorbar
        set(gcf,'units','points','position',[5,5,1000,1000])
    case 'AXES:allSNN_fit' % plot SSE as a function of clusters
        % OR plot upper and lower bounds of multi-task map
        K=[5:24,25];
        for p=1:length(K),
            toPlot{p}=sprintf('%dcluster',K(p));
        end
        
        % Aesthetics
        CAT.markersize=8;
        CAT.markertype='^';
        CAT.linewidth=4;
        CAT.linecolor={'r','k'};
        CAT.markercolor={'r','k'};
        CAT.markerfill={'r','k'};
        
        sc1_sc2_functionalAtlas('MAP:PLOT:SNN',{'SC12'},toPlot,K,'CAT',CAT);
        set(gcf,'units','points','position',[5,5,1000,1000])
        set(gca,'FontSize',18);
        ylabel('R2')
        xlabel('clusters')
        legend('R2','R2adj','Location','SouthEast')
    case 'AXES:map_similarity' % RS: resting state maps (Buckner, Cole)
        toPlot=varargin{1}; % {'Buckner_7Networks','Buckner_17Networks','Cole_10Networks'}
        toPlotNames=varargin{2}; % {'Buckner7',...}
        
        [RI]=sc1_sc2_functionalAtlas('MAP:compare',toPlot);
        
        imagesc_rectangle(RI,'YDir','reverse');
        caxis([0 1]);
        t=set(gca,'Ytick',[1:length(toPlot)]','YTickLabel',toPlotNames',...
            'FontSize',10,'Xtick',[1:length(toPlot)]','Color','white'); %
        colorbar
    case 'AXES:group_curves' % make separate graphs for 'lob10','Buckner_7Networks','Buckner_17Networks','Cole_10Networks','SC12_10cluster'
        toPlot=varargin{1}; % 'SC12_10cluster'
        %         plotName=varargin{2}; % 'Multi-Task:Upper'
        
        % Aesthetics
        CAT.markertype='none';
        CAT.errorwidth=.5;
        CAT.linecolor={'r','k'};
        CAT.errorcolor={'r','k'};
        CAT.linewidth={2, 2};
        CAT.linestyle={'-','-'};
        
        sc1_sc2_functionalAtlas('EVAL:PLOT:CURVES',toPlot,4,'group',1,'unique','CAT',CAT);
        
        % Labelling
        set(gca,'YLim',[0 0.55],'XLim',[0 35],'FontSize',10,'xtick',[0:5:35],'XTickLabel',{'0','','','','','','','35'}); %
        xlabel('Spatial Distances (mm)');
        ylabel('Activity Correlation (R)');
        %         title(plotName);
        set(gcf,'units','centimeters','position',[5,5,6,6])
        %         axis('auto')
        % do stats
        sc1_sc2_functionalAtlas('EVAL:STATS:CURVES',toPlot,4,'group',1,'unique')
    case 'AXES:indiv_curves' % make separate graphs for multi-task parcellation for individual subjects
        toPlot=varargin{1}; % 'SC12_10cluster'
        plotName=varargin{2}; % 'Multi-Task:Upper'
        
        vararginoptions({varargin{3:end}},{'sn'}); % option if doing individual map analysis
        
        % Aesthetics
        CAT.markertype='none';
        CAT.errorwidth=.5;
        CAT.linecolor={'r','k'};
        CAT.errorcolor={'r','k'};
        CAT.linewidth={2, 2};
        CAT.linestyle={'-','-'};
        
        sc1_sc2_functionalAtlas('EVAL:PLOT:CURVES',toPlot,4,'indiv',1,'unique','CAT',CAT,'sn',sn);
        
        % Labelling
        set(gca,'YLim',[0 0.6],'XLim',[0 35],'FontSize',10,'xtick',[0:5:35],'XTickLabel',{'0','','','','','','','35'}); %
        xlabel('Spatial Distances (mm)');
        ylabel('Activity Correlation (R)');
        %         title(plotName);
        set(gcf,'units','centimeters','position',[5,5,6,6])
        axis('auto')
        % do stats
        sc1_sc2_functionalAtlas('EVAL:STATS:CURVES',toPlot,4,'indiv',1,'unique','sn',sn)
    case 'AXES:MT_UpperLower' % makes graph for upper and lower bounds of multi-task plot
        toPlot={'SC2_cnvf_10','SC12_cnvf_10'};
        toPlotName='Multi-Task Parcellation';
        
        % Aesthetics
        CAT.markertype='none';
        CAT.errorwidth=.5;
        CAT.linecolor={'r','k'};
        CAT.errorcolor={'r','k'};
        CAT.linewidth={2, 2};
        CAT.linestyle={'-','--'};
        
        % plot upper and lower within and between curves
        sc1_sc2_functionalAtlas('EVAL:PLOT:CURVES',toPlot{1},4,'group',1,'unique','CAT',CAT);
        hold on
        CAT.linestyle='--';
        CAT.linewidth=1;
        sc1_sc2_functionalAtlas('EVAL:PLOT:CURVES',toPlot{2},4,'group',1,'unique','CAT',CAT);
        hold off
        
        % Labelling
        set(gca,'YLim',[0 0.55],'FontSize',10,'XLim',[0 35],'xtick',[0:5:35],'XTickLabel',{'0','','','','','','','35'});
        %         set(gca,'YLim',[0 0.6],'XLim',[4 32],'FontSize',18,'xtick',[4 32],'XTickLabel',{'4','32'});
        xlabel('Spatial Distances (mm)');
        ylabel('Voxel-to-Voxel Correlation');
        %         title(toPlotName)
        set(gcf,'units','centimeters','position',[5,5,6,6])
        %         legend('within parcels', 'between parcels','Location','SouthWest')
    case 'AXES:diff_curves' % make summary graph for diff curves for all maps
        toPlot=varargin{1};% {'SC12_5cluster','SC12_7cluster','SC12_9cluster','SC12_11cluster','SC12_13cluster','SC12_15cluster','SC12_17cluster'}
        evalNum=varargin{2}; %  4: Unique tasks, averaged across sc1/sc2
        
        evalNums=repmat([evalNum],length(toPlot),1);
        
        % aesthetics
        CAT.errorwidth=.5;
        CAT.markertype='none';
        CAT.linewidth=3;
        CAT.linestyle={'-','-','-','-','-','-'};
        CAT.linewidth={2, 2, 2, 2, 2, 2};
        errorcolor={'g','r','b','k','c','y','m'};
        linecolor={'g','r','b','k','c','y','m'};
        
        %         errorcolor={[0 0 0],[0 50/255 150/255],[44/255 26/255 226/255],[0 150/255 255/255],[185/255 0 54/255],[139/255 0 123/255],[0 158/255 96/255],[0 158/255 96/255]};
        %         linecolor={[0 0 0],[0 50/255 150/255],[44/255 26/255 226/255],[0 150/255 255/255],[185/255 0 54/255],[139/255 0 123/255],[0 158/255 96/255],[0 158/255 96/255]};
        %
        
        for m=1:length(toPlot),
            CAT.errorcolor=errorcolor{m};
            CAT.linecolor=linecolor{m};
            sc1_sc2_functionalAtlas('EVAL:PLOT:DIFF',toPlot{m},evalNums(m),'group',1,'unique','CAT',CAT); % always take crossval + unique
            hold on
        end
        hold off
        
        % Labelling
        set(gca,'YLim',[0 0.2],'FontSize',12,'XLim',[0 35],'xtick',[0:5:35],'XTickLabel',{'0','','','','','','','35'});
        xlabel('Spatial Distances (mm)');
        ylabel('Difference');
        set(gcf,'units','centimeters','position',[5,5,9,12])
        %         legend(plotName,'Location','NorthWest')
        
        
        % do stats
        %         sc1_sc2_functionalAtlas('EVAL:STATS:DIFF',toPlot,evalNums,'group',1,'unique'); % always take crossval + unique
    case 'AXES:subsets_curves' % curves for movies or dissimilar task subsets
        mapType=varargin{1};
        data=varargin{2}; % eval. on [1] or [2]
        subset=varargin{3}; % 'movies' or 'dissimilar'
        numTasks=varargin{4}; % 3 for movies, 2 or 3 for dissimilar
        
        crossval=1;
        
        % aesthetics
        CAT.errorwidth=.5;
        CAT.markertype='none';
        CAT.linewidth=3;
        CAT.linewidth={2, 2, 2, 2, 2, 2};
        linestyle={'-','-','-','-','-','-'};
        errorcolor={'g','b','y','m','k','g'};
        linecolor={'g','b','y','m','k','g'};
        
        idx=1;
        for m=1:length(mapType)
            CAT.errorcolor=errorcolor{idx};
            CAT.linecolor=linecolor{idx};
            CAT.linestyle=linestyle{idx};
            sc1_sc2_functionalAtlas('EVAL:PLOT:SUBSETS',{mapType{m}},data,subset,numTasks,crossval,'CAT',CAT); % always take crossval + unique
            hold on
            fprintf('%s:%s colour is %s and linestyle is %s \n',mapType{m},subset,numTasks,linecolor{idx},linestyle{idx});
            idx=idx+1;
        end
        
        % Labelling
        set(gca,'YLim',[0 0.2],'FontSize',12,'XLim',[0 35],'xtick',[0:5:35],'XTickLabel',{'0','','','','','','','35'});
        xlabel('Spatial Distances (mm)');
        ylabel('Difference');
        set(gcf,'units','centimeters','position',[5,5,9,12])
        %         legend(plotName,'Location','NorthWest')
        
        % do stats
        %         sc1_sc2_functionalAtlas('EVAL:STATS:DIFF',toPlot,evalNums,'group',1,'unique'); % always take crossval + unique
    case 'AXES:subsets_diff'
        mapType=varargin{1}; % {SC2_cnvf_10} for ex.
        data=varargin{2}; % 1, 2, 4 [1: eval on sc1; 2: eval on sc2; 4: eval on sc1+sc2]
        numTasks=varargin{3}; % [7] how many tasks are we taking ?
        
        crossval=1;
        subsets={'random'};
        
        % aesthetics
        CAT.errorwidth=.5;
        CAT.markertype='none';
        CAT.linewidth=3;
        CAT.linewidth={2, 2, 2, 2, 2, 2};
        linestyle={'-','-','-','-','-','-'};
        errorcolor={'k','b','g','m','y','g'};
        linecolor={'k','b','g','m','y','g'};
        
        CAT.errorcolor=errorcolor;
        CAT.linecolor=linecolor;
        CAT.linestyle=linestyle;
        sc1_sc2_functionalAtlas('EVAL:PLOT:SUBSETS_DIFF',mapType,data,subsets,numTasks,crossval,'CAT',CAT); % always take crossval + unique
        
        % Labelling
        set(gca,'YLim',[0.05 0.13],'FontSize',12,'XLim',[0 21],'xtick',[0 21],'XTickLabel',{'Most Similar','Least Similar'});
        xlabel(sprintf('Random Task Subsets (%d)',numTasks));
        ylabel('DCBC');
        %         set(gcf,'units','centimeters','position',[5,5,9,12])
    case 'AXES:indiv_diff' % make summary graph for diff curves for indiv maps (mostly used for lobular)
        toPlot=varargin{1};% 'lob10'
        evalNum=varargin{2}; % 4
        sn=varargin{3}; % [8, 15] subject number(s)
        
        % aesthetics
        CAT.errorwidth=.5;
        CAT.markertype='none';
        CAT.linewidth=3;
        CAT.linestyle={'-','-','-','-','-','-'};
        CAT.linewidth={2, 2, 2, 2, 2, 2};
        errorcolor={'g','b','r','y','m','c'};
        linecolor={'g','b','r','y','m','c'};
        
        % individual
        for s=1:length(sn),
            CAT.errorcolor=errorcolor{s};
            CAT.linecolor=linecolor{s};
            sc1_sc2_functionalAtlas('EVAL:PLOT:DIFF',toPlot,evalNum,'indiv',1,'unique','CAT',CAT,'sn',sn(s)); % always take crossval + unique
            hold on
        end
        
        % group
        CAT.errorcolor='k';
        CAT.linecolor='k';
        sc1_sc2_functionalAtlas('EVAL:PLOT:DIFF','lob10',4,'group',1,'unique','CAT',CAT,'snToPred',sn); % always take crossval + unique
        hold off
        
        % Labelling
        set(gca,'YLim',[-.07 0.12],'FontSize',12,'XLim',[0 35],'xtick',[0:5:35],'XTickLabel',{'0','','','','','','','35'});
        xlabel('Spatial Distances (mm)');
        ylabel('Difference');
        set(gcf,'units','centimeters','position',[5,5,9,12])
        %         legend(plotName,'Location','NorthWest')
        
        % do stats
        %         sc1_sc2_functionalAtlas('EVAL:STATS:DIFF',toPlot,evalNums,'group',1,'unique'); % always take crossval + unique
    case 'AXES:MT_group_indiv' % group versus indiv for multi-task map
        mapsGroup={'SC2_cnvf_10'};
        mapsIndiv={'SC2_cnvf_10'};
        
        % Aesthetics
        CAT.markertype='none';
        CAT.errorwidth=.5;
        CAT.linecolor={'r'};
        CAT.errorcolor={'r'};
        linewidth={2, .5};
        linestyle={'-'};
        
        % group
        for m=1:length(mapsGroup),
            CAT.linewidth=linewidth{m};
            CAT.linestyle=linestyle{m};
            sc1_sc2_functionalAtlas('EVAL:PLOT:DIFF',mapsGroup{m},4,'group',1,'unique','CAT',CAT); % always take crossval + unique
            hold on
        end
        
        % individual
        errorcolor={'k'};
        linecolor={'k'};
        linestyle={'-'};
        for m=1:length(mapsIndiv),
            CAT.linewidth=linewidth{m};
            CAT.linestyle=linestyle{m};
            CAT.errorcolor=errorcolor{m};
            CAT.linecolor=linecolor{m};
            sc1_sc2_functionalAtlas('EVAL:PLOT:DIFF',mapsIndiv{m},4,'indiv',1,'unique','CAT',CAT,'sn',returnSubjs);
        end
        hold off
        % Labelling
        set(gca,'YLim',[0 0.22],'FontSize',12,'XLim',[0 35],'xtick',[0:5:35],'XTickLabel',{'0','','','','','','','35'});
        xlabel('Spatial Distances (mm)');
        ylabel('Difference')
        set(gcf,'units','centimeters','position',[5,5,9,13])
    case 'AXES:boundary_strength' % makes separate graphs for 'lob10','Buckner_7Networks','Buckner_17Networks','Cole_10Networks','SC12_10cluster'
        toPlot=varargin{1}; % 'lob10','Buckner_7Networks' etc
        toPlotName=varargin{2}; % 'Lobular', 'Buckner7' etc
        
        sc1_sc2_functionalAtlas('STRENGTH:visualise_bound',toPlot)
        %         title(toPlotName);
        set(gca,'FontSize',18);
        set(gca,'Xticklabel',[],'Yticklabel',[])
        axis off
        set(gcf,'units','points','position',[5,5,1000,1000])
    case 'AXES:featSpace'  % graph the feature loadings for each network
        toPlot=varargin{1}; % 'featList_all','featList_winner' or 'featMatrix'
        
        sc1_sc2_functionalAtlas('ENCODE:project_featSpace','SC12_10cluster',toPlot)
        
        %         set(gca,'YLim',[0 0.6],'XLim',[1 7],'FontSize',24,'xtick',[1 7],'XTickLabel',{'4','32'});
        set(gcf,'units','points','position',[5,5,1000,1000])
    case 'AXES:taskSpace'  % graph the task loadings for each network
        toPlot=varargin{1}; % 'taskList_all','taskList_winner','taskMatrix'
        
        sc1_sc2_functionalAtlas('ENCODE:project_taskSpace','SC12_10cluster',toPlot)
        
        set(gcf,'units','points','position',[5,10,1000,1000])
    case 'AXES:scatterplot' % graph the scatterplot - two networks (one for motor; one for cognitive)
        toPlot=varargin{1}; % [4,10], [7,9]
        type=varargin{2}; % 'tasks' or 'features'
        
        % Aesthetics
        CAT.markersize=12;
        CAT.labelsize=18;
        sc1_sc2_functionalAtlas('ENCODE:scatterplot','SC12_10cluster',type,toPlot,'CAT',CAT)
        
        set(gcf,'units','points','position',[5,5,1000,1000])
        set(gca,'FontSize',9);
        axis equal
    case 'AXES:varianceFreq'
        % Aesthetics
        CAT.markersize=8;
        CAT.markertype='^';
        CAT.linewidth=4;
        CAT.linecolor={'r','k'};
        CAT.markercolor={'r','k'};
        CAT.markerfill={'r','k'};
        CAT.errorcolor={'r','k'};
        
        sc1_sc2_functionalAtlas('PLOT:spatialFreqCorr',CAT)
        set(gca,'FontSize',18);
        set(gcf,'units','points','position',[5,5,1000,1000])
    case 'AXES:interSubjCorr'
        % Aesthetics
        CAT.markertype='^';
        CAT.markersize=4;
        CAT.linewidth=2;
        CAT.linecolor={'r','k'};
        CAT.markercolor={'r','k'};
        CAT.markerfill={'r','k'};
        CAT.errorcolor={'r','k'};
        
        sc1_sc2_functionalAtlas('PLOT:interSubjCorr',CAT)
        xlabels={'overall','0-0.5','0.5-1','1-1.5','1.5-2','>2'};
        ylabel('Activity Correlation (R)');
        xlabel('Cycles/cm');
        drawline(0,'dir','horz');
        set(gca,'XTickLabel',xlabels,'FontSize',12);
        set(gcf,'units','centimeters','position',[5,5,9,13])
        %         title('Within and Between-subject correlation');
        
    case 'FIGURE2' % Representational Structure
        sc1_sc2_functionalAtlas('AXES:MDS','all')
    case 'FIGURE3a' % Lobular versus Functional
        subplot(2,2,1)
        sc1_sc2_functionalAtlas('AXES:group_curves','lob10','Lobular Parcellation')
        subplot(2,2,2)
        sc1_sc2_functionalAtlas('AXES:MT_UpperLower','Multi-Task Parcellation')
        subplot(2,2,3)
        sc1_sc2_functionalAtlas('AXES:boundary_strength','lob10','Lobular Parcellation')
        subplot(2,2,4)
        sc1_sc2_functionalAtlas('AXES:boundary_strength','SC12_10cluster','Multi-Task Parcellation')
    case 'FIGURE3b' % Map Similarity
        sc1_sc2_functionalAtlas('AXES:map_similarity',{'lob10','SC12_10cluster','Buckner_7Networks','Buckner_17Networks','Cole_10Networks'},...
            {'Lobular','Multi-Task','Buckner7','Buckner17','Cole10'});
    case 'FIGURE5' % Resting State Parcellations
        subplot(2,3,1)
        sc1_sc2_functionalAtlas('AXES:group_curves','Buckner_7Networks','Buckner7')
        subplot(2,3,2)
        sc1_sc2_functionalAtlas('AXES:group_curves','Buckner_17Networks','Buckner17')
        subplot(2,3,3)
        sc1_sc2_functionalAtlas('AXES:group_curves','Cole_10Networks','Cole10')
        subplot(2,3,4)
        sc1_sc2_functionalAtlas('AXES:boundary_strength','Buckner_7Networks','Buckner7')
        subplot(2,3,5)
        sc1_sc2_functionalAtlas('AXES:boundary_strength','Buckner_17Networks','Buckner17')
        subplot(2,3,6)
        sc1_sc2_functionalAtlas('AXES:boundary_strength','Cole_10Networks','Cole10')
    case 'FIGURE6' % Summary Graph
        sc1_sc2_functionalAtlas('AXES:diff_curves',{'lob10','Cole_10Networks','Buckner_7Networks','SC12_10cluster','SC2_10cluster'},...
            {'Lobular','Cole10','Buckner7','Multi-Task:Upper','Multi-Task:Lower'},...
            [4,4,4,4,4])
    case 'FIGURE7' % Multiple Multi-Task Parcellations
        subplot(2,2,[3 4])
        sc1_sc2_functionalAtlas('AXES:diff_curves',{'SC12_7cluster','SC12_10cluster','SC12_17cluster','lob10'},{'Multi-Task:7','Multi-Task:10','Multi-Task:17','Lobular'},repmat([4],4,1))
        subplot(2,2,2)
        sc1_sc2_functionalAtlas('AXES:boundary_strength','SC12_17cluster','Multi-Task17')
        subplot(2,2,1)
        sc1_sc2_functionalAtlas('AXES:boundary_strength','SC12_7cluster','Multi-Task7')
    case 'FIGURE8a'% Multi-Task Map
        sc1_sc2_functionalAtlas('AXES:map','SC12_10cluster','Multi-Task')
    case 'FIGURE8b'% Graph the "winner" features for each cluster
        sc1_sc2_functionalAtlas('AXES:featSpace','winner')
    case 'FIGURE8c'% Assigning Semantic Labels
        %         figure(1)
        %         sc1_sc2_functionalAtlas('AXES:taskSpace',[4,10])
        %         figure(2)
        %         sc1_sc2_functionalAtlas('AXES:taskSpace',[3,6])
        sc1_sc2_functionalAtlas('AXES:scatterplot',[1,6],'features')
    case 'FIGURE9' % Group Versus Individual
        %         subplot(2,4,1)
        %         sc1_sc2_functionalAtlas('AXES:MT_indiv_curves',2,'S02')
        %         subplot(2,4,3)
        %         sc1_sc2_functionalAtlas('AXES:MT_indiv_curves',4,'S04')
        %         subplot(2,4,[5:8])
        %         sc1_sc2_functionalAtlas('AXES:MT_group_indiv')
        %         subplot(2,4,2)
        %         sc1_sc2_functionalAtlas('AXES:map','SC12_10cluster','S02','sn',2)
        %         subplot(2,4,4)
        %         sc1_sc2_functionalAtlas('AXES:map','SC12_10cluster','S04','sn',4)
        subplot(2,2,[1,2])
        sc1_sc2_functionalAtlas('AXES:interSubjCorr')
        subplot(2,2,[3,4])
        sc1_sc2_functionalAtlas('AXES:MT_group_indiv')
    case 'FIGURE10'% Task subset figure
        % we want to plot 'dissimilar', 'random', and 'movie' into one
        % figure
        
    case 'SUPP1'   % Get behavioural results
    case 'SUPP2'   % RDM
        sc1_sc2_functionalAtlas('AXES:RDM','all')
    case 'SUPP3'   % Reliability of activity
        subplot(2,1,1)
        sc1_sc2_functionalAtlas('AXES:reliability','A','Activity Reliability')
        subplot(2,1,2)
        sc1_sc2_functionalAtlas('AXES:reliability','D','Distance Reliability')
    case 'SUPP4'   % Feature & Task Loading Matrices
        sc1_sc2_functionalAtlas('AXES:taskSpace','taskList_all')
    case 'SUPP5'   % Feature & Task Loading Matrices
        sc1_sc2_functionalAtlas('AXES:featSpace','featList_all')
end

% Local functions
function dircheck(dir)
if ~exist(dir,'dir');
    warning('%s doesn''t exist. Creating one now. You''re welcome! \n',dir);
    mkdir(dir);
end

% InterSubj Corr
function C=interSubj_corr(Y)
numSubj=size(Y,3);
for i=1:numSubj
    for j=1:numSubj
        C(i,j)=nansum(nansum(Y(:,:,i).*Y(:,:,j)))/...
            sqrt(nansum(nansum(Y(:,:,i).*Y(:,:,i)))*...
            nansum(nansum(Y(:,:,j).*Y(:,:,j))));
    end;
end

% InterSubj Corr - overall
function C=interSubj_corr_voxel(Y)
numSubj=size(Y,3);
for i=1:numSubj
    for j=1:numSubj
        C(i,j)=Y(:,:,i).*Y(:,:,j)/...
            sqrt(Y(:,:,i).*Y(:,:,i).*...
            Y(:,:,j).*Y(:,:,j));
    end;
end

function E = expectedObs(pivotTable)
%Number of observations
N = sum(nansum(pivotTable));

%Number of observations marginals
X = nansum(pivotTable,1);
Y = nansum(pivotTable,2);

%Propotions
Px = X/N;
Py = Y/N;

%Expected number of observations
E = Py * Px * N;

function G = Gtest(map1,map2, validIdx)
%Argument controller
if nargin == 2
    %Valid vertices index vector
    validIdx = ones(length(map1),1);
end
%Observations
O = pivottable(map1, map2, map1, 'length', 'subset', validIdx);
E = expectedObs(O);
%G-test
G = 2 * sum(nansum( O .* (log(O) - log(E)) ));






