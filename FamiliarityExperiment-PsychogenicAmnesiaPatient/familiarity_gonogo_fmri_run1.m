
%%

%%
% Clear the workspace
close all;
clearvars;
% Setup PTB with some default values
feature('DefaultCharacterSet','UTF8');
PsychDefaultSetup(2);
Screen('CloseAll');

PsychDebugWindowConfiguration(0,0.6);
Screen('Preference','TextEncodingLocale','UTF-8');
Screen('Preference', 'SkipSyncTests', 1);


filename='recognition_ok_080822_run1'; % .mat file with behavior11l data that will be saved
% prevent writing over the same file 
FileName = fullfile(pwd, [filename, '.mat']);
if exist(FileName, 'file')
    % Get number of files:
    newNum   =  1;
    FileName = fullfile(pwd, [filename, sprintf('%d', newNum), '.mat']);
end

%% Setting Some Screen Parameters

PsychHID('KbQueueCreate');
PsychHID('KbQueueStart');
 
% Seed the random number generator
rand('seed', sum(100 * clock));

screenNumber = min(Screen('Screens')); % for default monitor
%screenNumber = max(Screen('Screens')); % for fMRI monitor

% Define black, white and grey
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
red = [1 0 0];

% Open the screen and create offscreenwindow for a different background
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white, [], 32, 2);  % Screen('OpenWindow', screenNumber, white ,[], 32, 2);          
background1=Screen('OpenOffscreenWindow', window, black); 

% Flip to clear
Screen('Flip', window);

% Query the frame duration
FlipInterval=Screen('GetFlipInterval', window);
slack=FlipInterval/2;
when=0;

% Set the text size
Screen('TextSize', window, 100);

% Query the maximum priority level
Priority(MaxPriority(window));

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('TextSize', window, 40);

[screenXpixels, screenYpixels] = Screen('WindowSize', window);

%% Keyboard Information

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key

% KbName('UnifyKeyNames'); %%% keys for OZGE's mac
% escapeKey = KbName('ESCAPE');
% KeyEscape = KbName('escape');
% leftKey = KbName('LeftArrow');
% rightKey = KbName('RightArrow');
firstkey = KbName('1!');
secondkey = KbName('2@');
% 
Key.Trigger = KbName ('6^'); %windows
Key.trigger = KbName('6'); %mac

%Response keys for fMRI button boxes
% Key.blue = KbName('1!');
% Key.yellow = KbName('2@');
% Key.green = KbName ('3#');
% Key.red = KbName('4$');


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


%% Defining Some Display Parameters

theColor = [0 0 0]; 
lineWidth = 20;
color=black; 
 

%% Load all pictures

% 3 classes of pics:
    % familiar : the pics she recollected as familiar in the previous experiment
    % shouldbefamiliar: the pics she should have been familiar with if she didnot had the
    % amnesia
    % unfamiliar: the pics she shouldnot have been familiar with even if she didnot have
    % amnesia

familiar = 'G:\famexp_fmri\familiar';
shouldbefamiliar = 'G:\famexp_fmri\shouldbefamiliar';
unfamiliar= 'G:\famexp_fmri\unfamiliar';


pics_familiar=dir('G:\famexp_fmri\familiar\*.jpg');
pics_shouldbefamiliar=dir('G:\famexp_fmri\shouldbefamiliar\*.jpg');
pics_unfamiliar=dir('G:\famexp_fmri\unfamiliar\*.jpg');

pics_familiar = deblank(char(pics_familiar.name));
pics_familiar = cellstr(deblank(pics_familiar)); % containing all familiar pics

pics_shouldbefamiliar = deblank(char(pics_shouldbefamiliar.name));
pics_shouldbefamiliar = cellstr(deblank(pics_shouldbefamiliar)); % containing all familiar pics

pics_unfamiliar = deblank(char(pics_unfamiliar.name));
pics_unfamiliar = cellstr(deblank(pics_unfamiliar)); % containing all unfamiliar pics

piccount = length(pics_familiar)+length(pics_shouldbefamiliar)+length(pics_unfamiliar);

%% Starting the Experiment With the Trigger

Exp.PerformanceMat=[];
Exp.Rest=[];

%TRIGGER : '6'

KbQueueCreate(); % create the que in the beginning since it will take some time

%HideCursor;

disp('Waiting for scanner trigger ...');

textSize=60;
Screen('TextSize',window,textSize);
DrawFormattedText(window,'calisma baslamak uzere...','center','center', [0 0 0],[],1);
Screen('Flip',window);

%Exp.scannerstarttime = GetSecs;

%ListenChar(2); %Getting keyboard input for only psychtoolbox from now on

KbQueueStart();
trigger=0;
while trigger==0
    [pressed, keyCode] = KbQueueCheck();
    
    if pressed && keyCode(Key.trigger)
        trigger=1;
        break;
    elseif pressed && keyCode(Key.Trigger)
        trigger=1;
        break;
    end
    
end
KbQueueStop();
Exp.expstarttime = GetSecs;

Exp.Rest(1,1)=GetSecs;
for i = 1:5
    
    Screen('FillRect', window, [1 1 1]);
    DrawFormattedText(window, num2str(6-i), 'center', 'center',[0 0 0],1,1);
    Screen('Flip', window);
    WaitSecs(1);
    
end
Exp.Rest(2,1)=GetSecs;

%% Experimental Loop


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
% blocklength = 10; %%%%%%%%
stimtime = 2; % pic duration in secs
givebreakafter = 15;

block=0;

blocktype = [1,2,3]; % 1: familiar in previous exp
                     % 2: supposed to be familiar 
                     % 3: supposed to be unfamiliar

                     
               
trialorder=[repmat(1,length(pics_familiar),1,1)', repmat(2,length(pics_shouldbefamiliar),1,1)', repmat(3,length(pics_unfamiliar),1,1)'];
trialorder=trialorder(randperm(length(trialorder)));


piclist_fam=[1:length(pics_familiar)];
piclist_shfam=[1:length(pics_shouldbefamiliar)];
piclist_unfam=[1:length(pics_unfamiliar)];


iTi = [1 1.2 1.5 1.5 1.5 2 2 2 2.2 2.5 2.7 3 3.2 3.5 4 5 7 8 8.5 9 9.5 10];

KbQueueCreate();


     for trialnum = 1:piccount
        respMat = nan(11, 1);

        % give a break after each x pics
        if rem(trialnum,givebreakafter)==1
            block=block+1;
           
            
            DrawFormattedText(window,'Devam Etmek İçin Bir Tuşa Basınız','center','center',red,[],1);
            Screen('Flip',window);
            respMat(9,1)=GetSecs;
            
                          KbQueueStart();
                           buttonpress=0;
            while buttonpress==0
                [pressed, keyCode] = KbQueueCheck();
                timeSecs = keyCode(find(keyCode));
                if keyCode(escapeKey)
                    ShowCursor;
                    sca;
                elseif keyCode(Key.blue) || keyCode(Key.yellow)
                    buttonpress=1;
                    respMat(10,1)=GetSecs;
                    break;
                end
            end
                         KbQueueStop(); 
        end
        respMat(11,1)=respMat(10,1)-respMat(9,1);

       if trialorder(trialnum)==1
           pic_folder = familiar;
           trialtype= 1;
        
       elseif trialorder(trialnum)==2
           pic_folder = shouldbefamiliar;
           trialtype= 2;
           
       elseif trialorder(trialnum)==3
           pic_folder = unfamiliar;
           trialtype= 3;
  
       end
    
       respMat(1,1)=block;
       respMat(2,1)=trialnum;
       respMat(3,1)=rem(trialnum,givebreakafter);
   
                    % Fixation point before the trials
                    Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
                    % Flip to the screen
                    [VBLTimestamp] = Screen('Flip', window, when);
            
                    toss = randi(length(iTi));
                    currITI = iTi(toss);
                    iTi(toss)=[];
                    
                    if isempty(iTi)
                    iTi = [1 1.2 1.5 1.5 1.5 2 2 2 2.2 2.5 2.7 3 3.2 3.5 4 5 7 8 8.5 9 9.5 10];
                    end
                    
                    if trialnum<piccount
                    Screen('Flip', window, VBLTimestamp-slack+currITI);
                    end
    
        if  trialtype == 1 % if it is a familiar pic trial
            currImageLocation = familiar;
            curr_picnum = piclist_fam(randi(length(piclist_fam)));
            piclist_fam=setdiff(piclist_fam, curr_picnum);
            
            currImage = [currImageLocation filesep pics_familiar{curr_picnum}];
            [a b c] = fileparts(pics_familiar{curr_picnum});
            
        elseif  trialtype == 2 % if it is a shouldbefamiliar pic trial
            currImageLocation = shouldbefamiliar;
            curr_picnum = piclist_shfam(randi(length(piclist_shfam)));
            piclist_shfam=setdiff(piclist_shfam, curr_picnum);
            
            currImage = [currImageLocation filesep pics_shouldbefamiliar{curr_picnum}];
            [a b c] = fileparts(pics_shouldbefamiliar{curr_picnum});
            
        elseif  trialtype == 3 % if it is an unfamiliar pic trial
            currImageLocation = unfamiliar;
            curr_picnum = piclist_unfam(randi(length(piclist_unfam)));
            piclist_unfam=setdiff(piclist_unfam, curr_picnum);
            
            currImage = [currImageLocation filesep pics_unfamiliar{curr_picnum}];
            [a b c] = fileparts(pics_unfamiliar{curr_picnum});
            
        end
        
        
        respMat(4,1)=trialtype; % pic type
        theImage = imread(currImage);
        theImage = flipdim(theImage,2);
        respMat(5,1) = str2num(b); % pic number.jpg
        imageTexture = Screen('MakeTexture', window, theImage);

        [s1, s2, s3] = size(theImage);
        aspectRatio = s2 / s1;
        heightScaler = 0.5;
        imageHeights = screenYpixels .* heightScaler;
        imageWidths = imageHeights .* aspectRatio;
        theRect = [0 0 imageWidths imageHeights];
        dstRects = CenterRectOnPointd(theRect, screenXpixels /2,...
            screenYpixels /2);
        
        
        Screen('DrawTextures', window, imageTexture, [], dstRects);
        
        % Flip to the screen
        Screen('Flip', window);
        StimTime = GetSecs; 
        respMat(6,1) = StimTime; % onset of the pic
        
%         % WaitSecs(stimtime);
%         while GetSecs < StimTime+stimtime
%             [~, ~, keyCode] = KbCheck(-1);
%             if keyCode(Key.Escape) || keyCode(escapeKey) %if escape is pressed
%                 break;
%             end
%         end
        

         KbQueueStart();
            buttonpress=0;
            while buttonpress==0
                [pressed, keyCode] = KbQueueCheck();
                timeSecs = keyCode(find(keyCode));
                if pressed && keyCode(Key.blue)
                    buttonpress=1;
                    respMat(7, 1) = timeSecs(1)- respMat(6, 1); % RT
                    respMat(8,1)=1;
                    break;
                    
                elseif pressed && keyCode (Key.yellow)
                    buttonpress=1;
                    respMat(7, 1) = timeSecs(1)- respMat(6, 1); % RT
                    respMat(8,1)=2;
                    break;

                elseif keyCode(escapeKey)
                    ShowCursor;
                    sca;
                    return
                end
            end
            KbQueueStop();
            
        
        
        Screen('DrawDots', window, [xCenter; yCenter], 15, black, [], 2);
        Screen('Flip', window);
        WaitSecs(0.5);
        
                    % Fixation point after the last trial of the block
                   if rem(trialnum,givebreakafter)==0
                    Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
                    % Flip to the screen
                    [VBLTimestamp] = Screen('Flip', window, when);
            
                    toss = randi(length(iTi));
                    currITI = iTi(toss);
                    iTi(toss)=[];
                    
                    if isempty(iTi)
                    iTi = [1 1.2 1.5 1.5 1.5 2 2 2 2.2 2.5 2.7 3 3.2 3.5 4 5 7 8 8.5 9 9.5 10];
                    end
                    
                    if trialnum<piccount
                    Screen('Flip', window, VBLTimestamp-slack+currITI);
                    end
                   end
    
    Exp.PerformanceMat = [Exp.PerformanceMat respMat];
    
    save(filename,'Exp');
     end

    
     
% Exp.Rest(1,2)=GetSecs;
% for i = 1:5
%     
%     Screen('FillRect', window, [1 1 1]);
%     DrawFormattedText(window, num2str(6-i), 'center', 'center',[0 0 0],1);
%     Screen('Flip', window);
%     WaitSecs(1);
%     
% end
% Exp.Rest(2,2)=GetSecs;
     

%RestrictKeysForKbCheck([]);

% End of experiment screen 
Screen('TextSize', window, 30);
DrawFormattedText(window, 'deney bitti. cikmak icin bir tusa basin.',...
    'center', 'center', black,[],1);
Screen('Flip', window);

KbQueueStart();
trigger=0;
while trigger==0
    [pressed, keyCode] = KbQueueCheck();
    
    if pressed
        trigger=1;
        break;
    elseif pressed
        trigger=1;
        break;
    end
    
end
KbQueueStop();

sca;

%ListenChar(0); %start taking keyboard input for default programs
KbQueueRelease(); %delete the collected responses from the que

Priority(0); % set priority to default
ShowCursor; % show cursor

