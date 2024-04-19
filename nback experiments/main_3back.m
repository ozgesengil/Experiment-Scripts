%num_sess%
% Clear the workspace
close all;
clear;
% Setup PTB with some default values
PsychDefaultSetup(2);
Screen('CloseAll');
% sub_nb = inputdlg('id?');
%%cd('D:\aa02');
filename = 'sub26_zeel130122_sess4';
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
TotalTime = 16*60;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  6666
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
% PsychDebugWindowConfiguration(0, 0.6);

% Open the screen
% [window, windowRect] = PsychImaging('OpenWindow', 1, grey, [], 32, 1);
% [window, windowRect] = Screen('OpenWindow', screenNumber, grey, [], 32, 2);
% [window,windowRect]=Screen('OpenWindow', screenNumber, white,[10 20 1200 700]);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 10 1900 1000], 32, 2);

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
for i = 1:15
    Screen('FillRect', window, [1 1 1]);
    DrawFormattedText(window, 'Please Rest before the next Session', 'center', 'center',[0 0 0],[], 1);
    DrawFormattedText(window, num2str(16-i), 'center', yCenter+150,[0 0 0],[], 1);
    
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
piclist =1:18;
alwaysTs = 19:20;
neverTs = 21:22;
currpics = deblank(char(pics.name));
currpics = cellstr(deblank(currpics));
Exp.neverTs{1} = currpics{neverTs(1)};
Exp.neverTs{2} = currpics{neverTs(2)};
Exp.alwaysTs{1} = currpics{alwaysTs(1)};
Exp.alwaysTs{2} = currpics{alwaysTs(2)};
for Blocks = 1:1
    
    
    CurrBlockLen = 16;
    iBi = [2 3 4 5 6 2.5 3.5 4.5 5.5 7 10 15];
    Blocks =1:CurrBlockLen;
    
    
    
    for Episode = 1:CurrBlockLen
        
        
        iTi = [1 1.5 2 2.5 3 4 5 7 8];
        
        ntot = length(currpics);
        nback = 3;%NBACK(randi(2));
        toss = randi(2);
        trials = ones(1,9);
        numTrials = 9;
        
        
        
        curr_cuecolor = [0 1 0];
        Exp.Timings(Episode)=GetSecs;
        BeginTime = GetSecs;
        DrawFormattedText(window, 'press a button to continue ', 'center', 'center'  , red,[], 1);
        Screen('Flip', window);
        
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
        %             WaitSecs(0.5)
        %
        Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
        Screen('Flip', window);
        
        %get 9 pictures
        currlist = datasample(piclist,9,'Replace',false);
        piclist = setdiff(piclist,currlist);
        if length(piclist)<9
            piclist =1:18;
        end
        
        
        
        toss = randi(length(Blocks));
        numTs = rem(Blocks(toss),4);
        Blocks(toss)=[];
        toss = [];
        for i = 1: numTs
            toss(i)  = randi(numTrials-nback);
            while length(toss) ~= length(unique(toss))
                toss(i) = randi(4);
            end
            trials(toss(i)+nback)=2;
        end
        
        
        
        for i=1:nback
            currpic{i} = currpics{currlist(i)};
        end
        
        
        a = (nback+1);
        toss = randi(length(iTi));
        currITI = iTi(toss);
        iTi(toss)=[];
        if isempty(iTi)
            iTi = [1 1.5 2 2.5 3 4 5 7 8];
        end
        WaitSecs(currITI);
        for i = a:numTrials
            
            if trials(i) == 2
                currpic{i} = currpic{i-nback};
            else
                currpic{i} = currpics{currlist(i)};
                
                
            end
            
        end
        
        if numTs>1
            a = find(trials==2, 1, 'last' );
            if rem(Episode,2)==0
                currpic{a} = currpics{20};
                currpic{a-nback} = currpics{20};
                if trials(a-nback)==2
                    currpic{a-nback-nback} = currpics{20};
                end
            else
                currpic{a} = currpics{19};
                currpic{a-nback} = currpics{19};
                if trials(a-nback)==2
                    currpic{a-nback-nback} = currpics{19};
                end
                
            end
        else
            a = find(trials(4:6)==1);
            if rem(Episode,2)==0
                currpic{a(2)+nback} = currpics{20};
                currpic{a(1)+nback} = currpics{22};
            else
                currpic{a(2)+nback} = currpics{19};
                currpic{a(1)+nback} = currpics{21};
                
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
        %
        %                  break;
        %
        %              end
        %          end
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if pressed && keyCode(Key.blue)
                buttonpress=1;
                %                     respMat(8, trial) = timeSecs(1)- respMat(7, trial);
                
                break;
                
                
            elseif pressed && keyCode (Key.yellow)
                buttonpress=1;
                %                     respMat(8, trial) = timeSecs(1)- respMat(7, trial);
                break;
                
            elseif pressed && keyCode (Key.green)
                buttonpress=1;
                %                     respMat(8, trial) = timeSecs(1)- respMat(7, trial);
                break;
                
            elseif pressed && keyCode (Key.red)
                buttonpress=1;
                %                     respMat(8, trial) = timeSecs(1)- respMat(7, trial);
                break;
            elseif keyCode(escapeKey)
                ShowCursor;
                %                     respMat(4, trial) = timeSecs- Timings(trial);
                sca;
                return
            end
        end
        %             KbQueueStop();
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
    WaitSecs(30);
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
    'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;
sca;

ShowCursor;

