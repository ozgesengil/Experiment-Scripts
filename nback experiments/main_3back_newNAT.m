%num_sess%
% Clear the workspace
close all;
clear;
% Setup PTB with some default values
PsychDefaultSetup(2);
Screen('CloseAll');
% sub_nb = inputdlg('id?');
%%cd('D:\aa02');
filename = 'sub33_doke061022_sess3';
% % sub_nb = inputdlg('id?');
% % % % cd('E:\aa02');
% filename = 'xx';%char(sub_nb);%strcat(sub_nb,'_');
FileName = fullfile(pwd, [filename, '.mat']);
if exist(FileName, 'file')
    % Get number of files:
    
    newNum   =  1;
    filename = fullfile(pwd, [filename, sprintf('%d', newNum), '.mat']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scanmode = 0;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp.ndummies = 10; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TotalTime = 16*60;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
minTrials=9;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%6%%%%%%%
maxTrials = 18;
WMdur = 30;%%%%%%%%%%%%%%%%%%%%%
RestAfter = 3;%%%%%%%%%%%%%%%
pic_folder = 'C:\Users\MR_stimulus\Desktop\Ozge\pics';
% rest_pics_folder = 'C:\Users\MR_stimulus\Desktop\Ipek\faces\xpresented';
pics=dir('C:\Users\MR_stimulus\Desktop\Ozge\pics\*.jpg');%list files in the folder
% restpics = dir('C:\Users\MR_stimulus\Desktop\Ipek\faces\presented\*.bmp');
iBi = [4 5 6 7 8 9 10 11 12 13 14];
trialtypes = [1 2];
RestPeriod = 30;
LengthOptions = [6 9];
NBACK = [3 3];
%%%%%%%%%%%%%%%%%%%%%%%%%

%%


% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle'). Look
% at the help function of rand "help rand" for more information
rand('seed', sum(100 * clock));
% rng('shuffle');
% Set the svcreen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);
% PsychDebugWindowConfiguration(0, 0.4);

% Open the screen
% [window, windowRect] = PsychImaging('OpenWindow', 1, grey, [], 32, 1);
% [window, windowRect] = Screen('OpenWindow', screenNumber, grey, [], 32, 2);
% [window,windowRect]=Screen('OpenWindow', screenNumber, white,[10 20 1200 700]);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 10 1800 1000], 32, 2);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 100);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Screen('TextSize', window, 60);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------
%%
% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('DownArrow');
downKey = KbName('DownArrow');
Key.blue = KbName('1!');
Key.yellow = KbName('2@');
Key.green = KbName ('3#');
Key.red = KbName('4$');
Key.trigger = KbName ('6^');
Key.Escape = KbName('escape');

Key.Z = KbName ('Z');
Key.X = KbName('X');
Key.C = KbName ('C');
Key.V = KbName('V');

%%
red = [1 0 0];
green = [0 1 0];
allcolor = [1 1 1 0.2]';

cuecolor(1,:) = [0 1 0];
cuecolor(2,:) = [0 0 1];


err = [];


CurrBlock = 0;
CurrScore = 0;
BlockLen = [12,12];
BlockName = {'variable';'fixed'};
change = 0;
Exp.PerformanceMat=[]; Exp.TRtime =[];
Exp.Timings = []; Timings = nan(1,8);

Exp.RTbeg = [];

%%


% Get time

Exp.scanstarttime = GetSecs;


KbQueueCreate();

%Trigger
disp('Waiting for trigger ...');

textSize=60;
Screen('TextSize',window,textSize);
DrawFormattedText(window,'Please relax the scanner is about to start','center','center', [0 0 0], [],1);
Screen('Flip',window);

KbQueueStart();
curTR=0;
while curTR==0
    [pressed, Keycode] = KbQueueCheck();
    timeSecs = Keycode(find(Keycode));
    if pressed && Keycode(Key.trigger)
        CurrTR=1;
        break;
    end
end
KbQueueStop();


RestrictKeysForKbCheck([]);
%     KbStrokeWait();
Exp.expstarttime = GetSecs;
% %
% %
Rest = nan(11,1);
Rest(1,1) = 100;
Exp.Rest(1,1)=GetSecs;
Rest(5,1) = GetSecs;
for i = 1:10
    Screen('FillRect', window, [1 1 1]);
    DrawFormattedText(window, 'Please rest before the next session', 'center', 'center',[0 0 0],[], 1);
    DrawFormattedText(window, num2str(11-i), 'center', yCenter+150,[0 0 0],[], 1);
    
    %     DrawFormattedText(window, 'Session 1/4', 'center', yCenter+300,[0 0 0],[], 1);
    Screen('Flip', window);
    WaitSecs(1);
end
Exp.Rest(1,2)=GetSecs;
Rest(6,1) = GetSecs;
% %
% %     end

Exp.PerformanceMat = [Exp.PerformanceMat Rest];



%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
ExpTime=0;
piclist = [2,4,5,6,7,8,9,11,12,13,14,15,16,17,18,19,20,21]; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alwaysTs = [10 22]; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neverTs = [1 3]; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
currpics = deblank(char(pics.name));
currpics = cellstr(deblank(currpics));
Exp.neverTs{1} = currpics{neverTs(1)};
Exp.neverTs{2} = currpics{neverTs(2)};
Exp.alwaysTs{1} = currpics{alwaysTs(1)};
Exp.alwaysTs{2} = currpics{alwaysTs(2)};

% for Always and Usual Target Randomization 
randTarget_1=1:12;
randTarget_2=1:8;
randTarget_3=1:4;

% to randomly choose the always target pic out of 2 for targets 1, 2 and 3
randA_1=1:8;
randA_2=1:6;
randA_3=1:4;

% to randomly choose whether a given non-target middle posiiton will be
% always or never target pic, or whether an initial position will be never
% targte1 or never target 2 pic
randM=1:8;
randN=1:8;



for Blocks = 1:1
    
    
    CurrBlockLen = 16;
    iBi = [2 3 4 5 6 2.5 3.5 4.5 5.5 7 10 15];
    Blocks =1:CurrBlockLen; % this array will be used to decide which episodes will have how many targets
    
    
    
    for Episode = 1:CurrBlockLen % Episdode: the number of episodes in a given functional session/run
        iTi = [1 1.5 2 2.5 3 4 5 7 8]; % intertrial interval in between the pics and after the screen saying that press a button to continue
        ntot = length(currpics); % the number of total pics in the pics folder
        nback = 3; % This is a 3-back script
        toss = randi(2);
        trials = ones(1,9); % this is the array for trials, each episode consists of 9 trials
        numTrials = 9; % each episode consists of 9 trials
        KbQueueCreate();
        
        curr_cuecolor = [0 1 0]; % red
        Exp.Timings(Episode)=GetSecs; % Exp.Timings indexes shows the onset (time) of press a button to continue screen 
        BeginTime = GetSecs;
        DrawFormattedText(window, 'press a button to continue ', 'center', 'center'  , red,[], 1);
        Screen('Flip', window);
        
         % Waiting for the response to the press a button to cont screen
        KbQueueStart();
        buttonpress=0;
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if keyCode(escapeKey)
                ShowCursor;
                sca;
                return
                
            elseif keyCode(Key.green)
                buttonpress=1;
                break;
                
            elseif keyCode(Key.blue)
                buttonpress=1;
                
                break;
            elseif keyCode(Key.red)
                buttonpress=1;
                
                break;
            elseif keyCode(Key.yellow)
                buttonpress=1;
                
                break;
            end
        end
        
        BeginRT = timeSecs(1)-BeginTime;
        KbQueueStop();
        
        % Fixation dots after press a button to cont screen
        Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
        Screen('Flip', window);
        
        
        %get 9 pictures out of usual pics (without replacement for a two consecutive episodes (odd and even, respectively))
        currlist = datasample(piclist,9,'Replace',false); % currlist: the first list here consists of all nontargets and usual pics (to be changed later)
        piclist = setdiff(piclist,currlist); % without replacement*
        if length(piclist)<9
           piclist = [2,4,5,6,7,8,9,11,12,13,14,15,16,17,18,19,20,21]; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        
        % determining the number of targets in this episode (0,1,2, or 3
        % targets in a given episode, 25% each)
        toss = randi(length(Blocks));
        numTs = rem(Blocks(toss),4); % number of targets in this current episode
        Blocks(toss)=[]; % without replacement (making sure 0,1,2,3 targets appear equally frequently)
        toss = [];

        % determining which trials will be target trials AVOIDING TARGET
        % REPETITIONS ALL TOGETHER
        targetpos=1:(numTrials-nback); % array containing the positions of the possible pre-target trials
           for i = 1: numTs % number of targets in the episode
                     toss(i)  = randsample(targetpos,1); % pre-target trials are chosen from trials 1-6
                
                     while length(toss) ~= length(unique(toss)) % make sure to select unique elements
                           toss(i) = randi(6);
                     end
                     % AVOID TARGET REPETITION
                     if toss(i)<4
                         targetpos=setdiff(targetpos, toss(i)+3);
                     elseif toss(i)>3
                         targetpos=setdiff(targetpos, toss(i)-3);
                     end
                     trials(toss(i)+nback)=2; % target trials will be marked as 2 in 'trials' array, non-target trials:1
           end
       
        
      
        % listing the first n pictures of the episode as .jpg in accordance
        % with the random currlist array
        for i=1:nback
            currpic{i} = currpics{currlist(i)}; % all from usual target pics
        end
        
        
     

        %randomly choosing the iTi
        toss = randi(length(iTi));
        currITI = iTi(toss);
        iTi(toss)=[];
        if isempty(iTi)
            iTi = [1 1.5 2 2.5 3 4 5 7 8];
        end
        WaitSecs(currITI);

        % choosing the pics from n+1 to the last trial, in accordance with
        % whether it is a target or non-target (NOTE THAT, STILL, ALL PICS ARE USUAL
        % PICS TILL THIS POINT)
           a = (nback+1);
        for i = a:numTrials % from trial n+1 to the last trial
            
            if trials(i) == 2 % if it is determined to be a target trial
                currpic{i} = currpic{i-nback}; % the picture came n trial ago will be chosen
            else
                currpic{i} = currpics{currlist(i)}; % if it is non-target trial, go with the currpic list
            end
            
        end
        

       % changing 50% of target pics with always target pics
       
           a=find(trials==2); % find the target trial
          if a>0
           for p=1:length(a)
               if p==1 % for the first target
                   xx=randsample(randTarget_1,1);
                   randTarget_1=setdiff(randTarget_1,xx);
                             if rem(xx,2)==0 % if it is an even number (50% of such trials) - make it an always target pic
                                xxx=randsample(randA_1,1);
                                randA_1=setdiff(randA_1,xxx);
                                    if rem(xxx,2)==0
                                        currpic{a(p)} = currpics{alwaysTs(2)}; % make the target trial at2 pic
                                        currpic{a(p)-nback} = currpics{alwaysTs(2)}; % make the pre-target trial at2 pic
                                    else
                                        currpic{a(p)} = currpics{alwaysTs(1)}; % make the last target trial at1 pic
                                        currpic{a(p)-nback} = currpics{alwaysTs(1)}; % make the pre-target trial at1 pic   
                                    end

                            end 

               elseif p==2 % for the second target
                    yy=randsample(randTarget_2,1); 
                    randTarget_2=setdiff(randTarget_2,yy);
                            if rem(yy,2)==0 % if it is an even number (50% of such trials) - make it an always target pic
                                xxx=randsample(randA_2,1);
                                randA_2=setdiff(randA_2,xxx);
                                    if rem(xxx,2)==0
                                        currpic{a(p)} = currpics{alwaysTs(2)}; % make the target trial at2 pic
                                        currpic{a(p)-nback} = currpics{alwaysTs(2)}; % make the pre-target trial at2 pic
                                    else
                                        currpic{a(p)} = currpics{alwaysTs(1)}; % make the target trial at1 pic
                                        currpic{a(p)-nback} = currpics{alwaysTs(1)}; % make the pre-target trial at1 pic   
                                    end

                           end 

               elseif p==3 % third target will always be an always target pic
                   zz=randsample(randA_3,1); 
                   randA_3=setdiff(randA_3,zz);
                           if rem(zz,2)==0
                               currpic{a(p)} = currpics{alwaysTs(2)}; % make the last target trial at2 pic
                               currpic{a(p)-nback} = currpics{alwaysTs(2)}; % make the pre-target trial at2 pic
                           else
                               currpic{a(p)} = currpics{alwaysTs(1)}; % make the last target trial at1 pic
                               currpic{a(p)-nback} = currpics{alwaysTs(1)}; % make the pre-target trial at1 pic
                           end
               end
           end
          end



        % Never and Always Targets As Non-targets in Middle Positions
        
        if numTs<=1 % if there is 0 or 1 target
            a = find(trials(7:9)==1); % find the non-target trials from trial 7 to 9 to adress their pre-trials from 4 to 6
            a = setdiff(a,find(trials(4:6)==2));   % make sure that these middle positions are not themselves
                                                   % targets following the initial positions

                ll=randsample(randM,1);
                randM=setdiff(randM,ll);
                if rem(ll,4)==0
                    currpic{a(2)+3} = currpics{alwaysTs(2)}; % non-target AT
                    currpic{a(1)+3} = currpics{neverTs(2)};  % non-target NT
                elseif rem(ll,4)==1
                    currpic{a(2)+3} = currpics{alwaysTs(1)}; % non-target AT
                    currpic{a(1)+3} = currpics{neverTs(1)};  % non-target NT
                elseif rem(ll,4)==2
                    currpic{a(1)+3} = currpics{alwaysTs(1)}; % non-target AT
                    currpic{a(2)+3} = currpics{neverTs(1)};  % non-target NT
                elseif rem(ll,4)==3
                    currpic{a(1)+3} = currpics{alwaysTs(2)}; % non-target AT
                    currpic{a(2)+3} = currpics{neverTs(2)};  % non-target NT
                end


             b = find(trials(4:6)==1); % find the non-target trials from trial 4 to 6 to adress their pre-trials from 1 to 3
              
             nn=randsample(randN,1);
             randN=setdiff(randN,nn);
                if rem(nn,4)==0
                    currpic{b(1)} = currpics{neverTs(1)};  % non-target NT1
                elseif rem(nn,4)==1
                    currpic{b(1)} = currpics{neverTs(2)};  % non-target NT2
                elseif rem(nn,4)==2
                    currpic{b(2)} = currpics{neverTs(1)};  % non-target NT1
                elseif rem(nn,4)==3
                    currpic{b(2)} = currpics{neverTs(2)};  % non-target NT2
                end
        end
        
    
        
        respMat = nan(11, numTrials);
        respMat(10,1) = BeginTime;
        respMat(11,1) = BeginRT;
        respMat(4,1:length(trials))=trials;
        respMat(1,:)=ones(1,numTrials);
        respMat(3,:) = numTs*ones(1,numTrials);
        respMat(2,:) = (Episode)*ones(1,numTrials);
        
        
        %         respMat(6,:)=trials;
        
        Timings= nan(1,(maxTrials+4));
        
        
        BlockStart = GetSecs;
        
        for trial = 1:numTrials
            toss = randi(length(iTi));
            currITI = iTi(toss);
            iTi(toss)=[];
            if isempty(iTi)
                iTi = [1 1.5 2 2.5 3 4 5 7 8];
            end
            respToBeMade = 1; response = nan;
            currImageLocation = [pic_folder filesep currpic{trial}];
            theImage = imread(currImageLocation);
            [a b c] = fileparts(currpic{trial});
            respMat(9,trial) = str2num(b);
            % Make the image into a texture
            imageTexture = Screen('MakeTexture', window, theImage);
            
            % rescale the current image
            
            
            % Get the size of the image
            [s1, s2, s3] = size(theImage);
            aspectRatio = s2 / s1;
            heightScaler = 0.5;
            imageHeights = screenYpixels .* heightScaler;
            imageWidths = imageHeights .* aspectRatio;
            theRect = [0 0 imageWidths imageHeights];
            dstRects = CenterRectOnPointd(theRect, screenXpixels /2,...
                screenYpixels /2);
            
            
            Screen('DrawTextures', window, imageTexture, [], dstRects);
            %             if CurrBlockLen == 12
            %                  DrawFormattedText(window, num2str(trial), 'center', (screenYpixels-100), curr_cuecolor,[],1);
            %             end
            % Flip to the screen
            Screen('Flip', window);
            respMat(5, trial) = GetSecs;
            WaitSecs(1.5);
            %
            
            
            Screen('DrawDots', window, [xCenter; yCenter], 15, curr_cuecolor, [], 2);
            Screen('Flip', window);
            
            
            
            if trial<numTrials
                WaitSecs(currITI);
            end
            
        end
        
        DrawFormattedText(window, '?' , 'center', 'center', green, [],1);
        DrawFormattedText(window, '0  1  2  3' , 'center', yCenter+300, green, [],1);
        Screen('Flip', window);
        KbQueueStart();
        buttonpress=0;
        
        %          while buttonpress==0
        %              [pressed, keyCode] = KbQueueCheck();
        %              timeSecs = keyCode(find(keyCode));
        %              if pressed
        %                  buttonpress=1;
        %                  break;
        %              end
        %          end
        
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if pressed && keyCode(Key.blue)
                buttonpress=1;
                break;
            elseif pressed && keyCode (Key.yellow)
                buttonpress=1;
                break;
            elseif pressed && keyCode (Key.green)
                buttonpress=1;
                break;
            elseif pressed && keyCode (Key.red)
                buttonpress=1;
                break;
            elseif keyCode(escapeKey)
                ShowCursor;
                sca;
                return
            end
        end

        KbQueueStop();
        respMat(6, trial) = timeSecs(1)- respMat(5, trial); 
        if keyCode(Key.green) && numTs== 0
            
            err = 0 ;
            respMat(7, :) = 1;
            %                     respToBeMade = 0;
            %                 tEnd = GetSecs;
            % % %                 respMat(4, trial) = secs -  Timings(trial);
            color = green;
        elseif keyCode(Key.red)&& numTs== 1
            
            err = 0 ;
            respMat(7, :) = 1;
            %                     respToBeMade = 0;
            %                 tEnd = GetSecs;
            % % %                 respMat(4, trial) = secs -  Timings(trial);
            color = green;
            
        elseif keyCode(Key.blue) && numTs== 2
            
            err = 0 ;
            respMat(7, :) = 1;
            %                     respToBeMade = 0;
            %                 tEnd = GetSecs;
            % % %                 respMat(4, trial) = secs -  Timings(trial);
            color = green;
        elseif keyCode(Key.yellow)&& numTs== 3
            
            err = 0 ;
            respMat(7, :) = 1;
            %                     respToBeMade = 0;
            %                 tEnd = GetSecs;
            % % %                 respMat(4, trial) = secs -  Timings(trial);
            color = green;
            
        else
            
            err = 1 ;
            respMat(7, :) = 0;
            %                     respToBeMade = 0;
            %                 tEnd = GetSecs;
            % % % %                 respMat(4, trial) = secs -  Timings(trial);
            %                 color = red;
        end
        %
        
        
        
        
        
        %         num_errs = find(respMat(9,(nback+1):end)==0);
        if err==0
            CurrScore = CurrScore+1;
            change = '+1';
                    else
                        CurrScore = CurrScore-1;
                        change = '-1';
            
        end
        respMat(8, :) = CurrScore;
        % Draw Score
        
        DrawFormattedText(window, ['Current Score = ' num2str(CurrScore)], 'center', yCenter+100, red, [],1);
        DrawFormattedText(window, ['Last Change = ' num2str(change)], 'center', yCenter-100, red, [],1);
        Screen('Flip', window);
        WaitSecs(1);
        
        toss = randi(length(iBi));
        currIBI = iBi(toss);
        iBi(toss)=[];
        if isempty(iBi)
            iBi = [2 3 4];
        end
        
        if Episode<CurrBlockLen
            
            % Draw the fixation point
            Screen('DrawDots', window, [xCenter; yCenter], 10, [0 0 0], [], 2);
            % Screen('FramePoly', window, rectColor, [xPosVector; yPosVector]', lineWidth);
            % Flip to the screen
            Screen('Flip', window);
            WaitSecs(currIBI);
            
        end
        
        Exp.PerformanceMat = [Exp.PerformanceMat respMat];
        Exp.Timings = [Exp.Timings Timings];
        save(filename,'Exp');
    end
    Rest = nan(11,1);
    Rest(1,1) = 100;
    Rest(5,1) = GetSecs;
    
    
    Exp.Rest(Blocks+1,1)=GetSecs;
    Screen('FillRect', window, [1 1 1]);
    DrawFormattedText(window, 'Rest', 'center', 'center',[0 0 0],[], 1);
    
    DrawFormattedText(window, 'End of the Session', 'center', yCenter+300,[0 0 0],[], 1);
    
    
    Screen('Flip', window);
    WaitSecs(60);
    Exp.Rest(Blocks+1,2)=GetSecs;
    
    Rest(6,1) = GetSecs;
    
    Exp.PerformanceMat = [Exp.PerformanceMat Rest];
    
    
    ExpTime = GetSecs - Exp.expstarttime;
    %     TotalTime = SSO.Clock - expstarttime;
    %     TotalTime2 = GetSecs - expstarttime2;
    %%
    
    
end


% End of experiment screen. We clear the screen once they have made their
% response
save(filename,'Exp');
% DrawFormattedText(window, rem(trial-1,10), 'center', 'center', allcolor);
DrawFormattedText(window, 'Session Finished \n\n Press Any Key To Exit',...
    'center', 'center', black, [], 1 );
Screen('Flip', window);
KbStrokeWait;
sca;

ShowCursor;

