% Clear the workspace
close all;
clearvars;
% Setup PTB with some default values
feature('DefaultCharacterSet','UTF8')
PsychDefaultSetup(2);
Screen('CloseAll');
%PsychDebugWindowConfiguration(0,0.4)
Screen('Preference', 'SkipSyncTests', 1); %skip synchronization test if necessary
Screen('Preference','TextEncodingLocale','UTF-8');

filename='metacog_NAT_sub33'; % .mat file of behavioral data that will be saved
% prevent overwriting on the same file 
FileName = fullfile(pwd, [filename, '.mat']);
if exist(FileName, 'file')
    % Get number of files:
    newNum   =  1;
    FileName = fullfile(pwd, [filename, sprintf('%d', newNum), '.mat']);
end

%% Setting Some Screen Parameters
% Seed the random number generator
rand('seed', sum(100 * clock));

screenNumber = min(Screen('Screens')); % for default monitor
%screenNumber = max(Screen('Screens')); % for fMRI monitor

% Define black, white and grey
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open the screen and create offscreenwindow for a different background
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white, [], 32, 2);
background1=Screen('OpenOffscreenWindow', window, black);
%PsychDebugWindowConfiguration(0,0.2)

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

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

%% Keyboard Information

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
KeyEscape = KbName('escape');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
firstkey = KbName('1!');
secondkey = KbName('2@');

Key.Trigger = KbName ('6^'); %windows
Key.trigger = KbName('6'); %mac

%Response keys for fMRI button boxes
Key.blue = KbName('1!');
Key.yellow = KbName('2@');
Key.green = KbName ('3#');
Key.red = KbName('4$');

%Response Keys for practice
Key.Z = KbName ('Z');
Key.X = KbName('X');
Key.C = KbName ('C');
Key.V = KbName('V');


%% Defining Some Display Parameters

color=black; % color of the fixation dots
 

%% Defining Stimuli Folder
pic_folder = 'C:\Users\MR_stimulus\Desktop\Ozge\pics'; % the folder with the pics
pics=dir('C:\Users\MR_stimulus\Desktop\Ozge\pics\*.jpg');%list files in the folder

%% Define Performance Matrices

Exp.PerformanceMat=[]; % for behavioral output
Exp.TRtime =[]; 
Exp.RTbeg = [];

%% Starting the Experiment With the Trigger

%TRIGGER : '6'

KbQueueCreate(); % create the que in the beginning since it will take some time

%HideCursor;

disp('Waiting for scanner trigger ...');

textSize=60;
Screen('TextSize',window,textSize);
%DrawFormattedText(window,'The experiment is about to
%start...','center','center', [0 0 0],[]); 
DrawFormattedText(window,'The experiment is about to start...','center','center', [0 0 0],[],1); %mirror image for fmri
Screen('Flip',window);

Exp.scannerstarttime = GetSecs;

%ListenChar(2); % To get the keyboard input for only psychtoolbox from now on

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



%% Experimental Loop
%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

Exp.experimentstarttime = GetSecs; % get experiment start time

ExpTime=0;
piclist = [1:22];%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alwaysTs = [10 22]; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neverTs = [1 3];
piclist=setdiff(piclist,[alwaysTs,neverTs]); % this will be usual target pic list 

currpics = deblank(char(pics.name));
currpics = cellstr(deblank(currpics));
Exp.neverTs{1} = currpics{neverTs(1)};
Exp.neverTs{2} = currpics{neverTs(2)};
Exp.alwaysTs{1} = currpics{alwaysTs(1)};
Exp.alwaysTs{2} = currpics{alwaysTs(2)};


nusual=6; % the number of usual target pictures to be selected from piclist and shown
npics=nusual+4; %the number of total pictures to be shown in this metacognition block (4: NAT pictures)
nblocks=1;

rand_us_pics=randsample(piclist,nusual,false); % choose nusual random pics from the pic list of usual targets
combinedpics=[rand_us_pics, alwaysTs, neverTs]; % all of the pic numbers that will be used in this block
combinedpics=combinedpics(randperm(length(combinedpics))); % randomly shuffling the pics in the array (this will be the order of presenation)



for blocks = 1:nblocks

        DrawFormattedText(window, ['Devam etmek icin bir tusa basin'] , 'center', 'center', black, [],1);
        Screen('Flip', window);
        KbQueueStart();
        buttonpress=0;
        
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
        WaitSecs(2);


        
    for ntrial=1:npics
        
        % intertrial interval array
        iTi = [1 1.5 2 2.5 3 4 5 7 8];

    % find the current image from its location and read it
    currImageLocation = [pic_folder filesep currpics{combinedpics(ntrial)}];
    
    % save the number of the pic .jpg to the output file (2nd row)
    [a, b, c] = fileparts(currpics{combinedpics(ntrial)});
    respMat(2,ntrial) = str2double(b);
    b=str2double(b);

    % extract the numeric value of never and always target pic names
    [xxn1, yyn1, zzn1] = fileparts(currpics{(neverTs(1))});
    [xxn2, yyn2, zzn2] = fileparts(currpics{(neverTs(2))});
    [xxa1, yya1, zza1] = fileparts(currpics{(alwaysTs(1))});
    [xxa2, yya2, zza2] = fileparts(currpics{(alwaysTs(2))});
    yyn1=str2double(yyn1);
    yyn2=str2double(yyn2);
    yya1=str2double(yya1);
    yya2=str2double(yya2);
    
    % save whether the pic is NeverT, AlwaysT or UsualT
    if b==yyn1 || b==yyn2
        respMat(3,ntrial) = 1; % for neverTs pic: 1
    elseif b==yya1 || b==yya2
        respMat(3,ntrial) = 2; % for alwaysT pic: 2
    else
        respMat(3,ntrial) = 3; % for usualT pic: 3
    end

    % read the image
    theImage = imread(currImageLocation);
    % Make the image into a texture
    imageTexture = Screen('MakeTexture', window, theImage);

            % Get the size of the image
            [s1, s2, s3] = size(theImage);
            aspectRatio = s2 / s1;
            heightScaler = 0.5;
            imageHeights = screenYpixels .* heightScaler;
            imageWidths = imageHeights .* aspectRatio;
            theRect = [0 0 imageWidths imageHeights];
            dstRects = CenterRectOnPointd(theRect, screenXpixels /2,...
                screenYpixels /2);
            
            % draw the picture
            Screen('DrawTextures', window, imageTexture, [], dstRects); 

            % draw the question
            Screen('TextSize', window, 40);
            DrawFormattedText(window, 'Bu resim deneyde hangi siklikla onceki resimle bir eslesme olarak geldi?',...
               xCenter/4, yCenter/4, black,[], 1);
            

            
            % draw the scale image
            theScaleImage=imread('C:\Users\MR_stimulus\Desktop\3back_NAT\unnamed.png');
            theScaleImage=flipdim(theScaleImage,2);
            ScaleImageTexture = Screen('MakeTexture', window,theScaleImage);

            % Get the size of the scale image
            [s1, s2, s3] = size(theScaleImage);
            aspectRatio = s2 / s1;
            heightScaler = 0.2;
            imageHeights = screenYpixels .* heightScaler;
            imageWidths = imageHeights .* aspectRatio;
            theRect = [0 0 imageWidths imageHeights];
            dstRects2 = CenterRectOnPointd(theRect, screenXpixels /2,...
                screenYpixels /1.10);
            
            % draw the scale image
            Screen('DrawTextures', window, ScaleImageTexture, [], dstRects2);

            % flip the screen to show all at once
            Screen('Flip', window);
            respMat(4,ntrial)=GetSecs;

        
        % wait for the response/button press  
        KbQueueStart();
        buttonpress=0;
      
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if pressed && keyCode(Key.green)
                  buttonpress=1;
                respMat(7,ntrial)=1;
                break;    
            elseif pressed && keyCode (Key.red)
                buttonpress=1;
                respMat(7,ntrial)=2;
                break;
            elseif pressed && keyCode (Key.blue)
                buttonpress=1;
                respMat(7,ntrial)=3;
                break;
            elseif pressed && keyCode (Key.yellow)
                buttonpress=1;
                respMat(7,ntrial)=4;
                break;
            elseif keyCode(escapeKey)
                ShowCursor;
                sca;
                return
            end
        end
        KbQueueStop();
        respMat(5, ntrial) = GetSecs; 
        respMat(6, ntrial) = respMat(5,ntrial) - respMat(4, ntrial); % The RT of the response from pic onset to the response
        respMat(1, ntrial) = ntrial ; % first row is the number of trial



            toss = randi(length(iTi));
            currITI = iTi(toss);
            iTi(toss)=[];
                if isempty(iTi)
                    iTi = [1 1.5 2 2.5 3 4 5 7 8];
                end
            
        if ntrial<npics % if it is not the last trial
            % draw dots in between trials and jitter the intertrial
            % intervals
            Screen('DrawDots', window, [xCenter; yCenter], 15, black, [], 2);
            Screen('Flip', window);
            WaitSecs(currITI);
        end

            
    end
end
   
Exp.PerformanceMat = [Exp.PerformanceMat respMat];
        save(filename,'Exp');

    %%
    
% End of experiment screen. We clear the screen once they have made their
% response
save(filename,'Exp');
% DrawFormattedText(window, rem(trial-1,10), 'center', 'center', allcolor);
DrawFormattedText(window, 'Seans bitti \n\n Çıkmak için herhangi bir tuşa basınız',...
    'center', 'center', black,[],1);
Screen('Flip', window);
KbStrokeWait;
sca;

ShowCursor;

    
    