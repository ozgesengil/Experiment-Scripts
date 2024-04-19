
%% rests in between some number of trials ? - variable: givebreakafter
%% check the iti ?
%% debug mode is closed ?
%%
% Clear the workspace
 close all;
  clearvars;
% Setup PTB with some default values
feature('DefaultCharacterSet','UTF8');
PsychDefaultSetup(2);
Screen('CloseAll');
%PsychDebugWindowConfiguration(0,0.2);
Screen('Preference','TextEncodingLocale','UTF-8');
Screen('Preference', 'SkipSyncTests', 1);

givebreakafter = 10; %%%%%%%%

filename='recognition_sub_2'; % .mat file with behavioral data that will be saved
% prevent writing over the same file 
FileName = fullfile(pwd, [filename, '.mat']);
if exist(FileName, 'file')
    % Get number of files:
    newNum   =  1;
    FileName = fullfile(pwd, [filename, sprintf('%d', newNum), '.mat']);
end

%%

% Load all pictures

familiar = 'C:\Users\tamer\OneDrive\Desktop\famexp\familiar';
unfamiliar= 'C:\Users\tamer\OneDrive\Desktop\famexp\unfamiliar';
pics_familiar=dir('C:\Users\tamer\OneDrive\Desktop\famexp\familiar\*.jpg');
pics_unfamiliar=dir('C:\Users\tamer\OneDrive\Desktop\famexp\unfamiliar\*.jpg');

pics_familiar = deblank(char(pics_familiar.name));
pics_familiar = cellstr(deblank(pics_familiar)); % containing all familiar pics

pics_unfamiliar = deblank(char(pics_unfamiliar.name));
pics_unfamiliar = cellstr(deblank(pics_unfamiliar)); % containing all unfamiliar pics

piccount = length(pics_familiar)+length(pics_unfamiliar);

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

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------
%%
% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
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

%%
red = [1 0 0];
blue = [0 0 1];
allcolor = [1 1 1 0.2]';
iBi = [4 5 6 4.5 5.5 7 10 5 6];
CurrScore = 0;
Exp.PerformanceMat=[]; 

conds=[1,2];

%%
Exp.expstarttime = GetSecs;

for i = 1:5
    
    Screen('FillRect', window, [1 1 1]);
    DrawFormattedText(window, num2str(6-i), 'center', 'center',[0 0 0],1);
    Screen('Flip', window);
    WaitSecs(1);
    
end


%%
%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
KbQueueCreate();


iTi = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];
blocktype = [1,2];
trialorder=(repmat(conds, 1, piccount/2));
trialorder=trialorder(randperm(length(trialorder)));
piclist_fam=[1:piccount/2];
piclist_unfam=[1:piccount/2];

for block=1:length(blocktype)
 if block==1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
     DrawFormattedText(window,'Gördüğünüz resimler size tanıdık geliyor mu?','center',(screenYpixels-800),red);
     DrawFormattedText(window,'Tanıyabildiğiniz ya da tanıdık gelen resimler için işaret parmağı butonuna basın','center',(screenYpixels-600),red);
     DrawFormattedText(window,'Tanıyamadığınız ya da tanıdık gelmeyen resimler için orta parmak butonuna basın','center',(screenYpixels-400),red);
     DrawFormattedText(window,'Eğer anladıysanız herhangi bir butona basın','center',(screenYpixels-200),red);
     Screen('Flip',window);

     KbQueueStart();
        buttonpress=0;
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if keyCode(escapeKey)
                ShowCursor;
                sca;
            elseif pressed
                buttonpress=1;
                break;
            end
        end
        KbQueueStop();


     for trialnum = 1:piccount
        respMat = nan(7, 1);

        % give a break after each x pics
        if trialnum>1 && rem(trialnum,givebreakafter)==1
            DrawFormattedText(window,'Devam Etmek İçin Bir Tuşa Basınız','center','center',red);
            Screen('Flip',window);

                          KbQueueStart();
                           buttonpress=0;
            while buttonpress==0
                [pressed, keyCode] = KbQueueCheck();
                timeSecs = keyCode(find(keyCode));
                if keyCode(escapeKey)
                    ShowCursor;
                    sca;
                elseif pressed
                    buttonpress=1;
                    break;
                end
            end
                         KbQueueStop(); 
        end
    

       if trialorder(trialnum)==1
           pic_folder = familiar;
           trialtype= 1;
        
       elseif trialorder(trialnum)==2
           pic_folder = unfamiliar;
           trialtype= 2;
  
       end
    
       respMat(1,:)=block;
       respMat(2,:)=trialnum;
       respMat(3,:)=trialtype;
   
                    % Fixation point before the trials
                    Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
                    % Flip to the screen
                    [VBLTimestamp] = Screen('Flip', window, when);
            
                    toss = randi(length(iTi));
                    currITI = iTi(toss);
                    iTi(toss)=[];
                    
                    if isempty(iTi)
                    iTi = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];
                    end
                    
                    if trialnum<piccount
                    Screen('Flip', window, VBLTimestamp-slack+currITI);
                    end
    
        if  trialtype == 1 % if it is a familiar pic trial
            currImageLocation = familiar;
            curr_picnum = piclist_fam(randi(length(piclist_fam)));
            piclist_fam=setdiff(piclist_fam, curr_picnum);
            
        else % if it is an unfamiliar pic trial
            currImageLocation = unfamiliar;
            curr_picnum = piclist_unfam(randi(length(piclist_unfam)));
            piclist_unfam=setdiff(piclist_unfam, curr_picnum);
            
        end
        
        

        currImage = [currImageLocation filesep pics_familiar{curr_picnum}];
        theImage = imread(currImage);
        [a b c] = fileparts(pics_familiar{curr_picnum});
        respMat(4,:) = str2num(b);
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
        respMat(5,:) = StimTime;
        
        KbQueueStart();
        buttonpress=0;
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if pressed
                buttonpress=1;
                break;
            end
        end
        KbQueueStop();
        respMat(6,:) = timeSecs(1)- StimTime;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(Key.blue)
            respMat(7,:) = 1;
        elseif keyCode(Key.yellow)
            respMat(7,:) = 2;  
        end
        
        
        
        Screen('DrawDots', window, [xCenter; yCenter], 15, black, [], 2);
        Screen('Flip', window);
        WaitSecs(0.5);
    
    Exp.PerformanceMat = [Exp.PerformanceMat respMat];
    
    save(filename,'Exp');
    end


 elseif block==2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    iTi = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];
    blocktype = [1,2];
    trialorder=(repmat(conds, 1, piccount/2));
    trialorder=trialorder(randperm(length(trialorder)));
    piclist_fam=[1:piccount/2];
    piclist_unfam=[1:piccount/2];


     DrawFormattedText(window,'Gördüğünüz resimler size ne kadar tanıdık geliyor?','center',(screenYpixels-1000),red);
     DrawFormattedText(window,'Hiç tanıdık gelmiyorsa 1 e','center',(screenYpixels-800),red);
     DrawFormattedText(window,'Birazcık tanıdık geliyorsa 2 ye','center',(screenYpixels-600),red);
     DrawFormattedText(window,'Oldukça tanıdık geliyorsa 3 e','center',(screenYpixels-400),red);
     DrawFormattedText(window,'Tanıdığınızdan eminseniz 4 e basınız','center',(screenYpixels-200),red);
     Screen('Flip',window);

     KbQueueStart();
        buttonpress=0;
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if keyCode(escapeKey)
                ShowCursor;
                sca;
            elseif pressed
                buttonpress=1;
                break;
            end
        end
        KbQueueStop();

    for trialnum = 1:piccount
        respMat = nan(7, 1);

         % give a break after each x pics
        if trialnum>1 && rem(trialnum,givebreakafter)==1
            DrawFormattedText(window,'Devam Etmek İçin Bir Tuşa Basınız','center','center',red);
            Screen('Flip',window);

                          KbQueueStart();
                           buttonpress=0;
            while buttonpress==0
                [pressed, keyCode] = KbQueueCheck();
                timeSecs = keyCode(find(keyCode));
                if keyCode(escapeKey)
                    ShowCursor;
                    sca;
                elseif pressed
                    buttonpress=1;
                    break;
                end
            end
                         KbQueueStop(); 
        end
    
       if trialorder(trialnum)==1
           pic_folder = familiar;
           trialtype= 1;
        
       elseif trialorder(trialnum)==2
           pic_folder = unfamiliar;
           trialtype= 2;
  
       end
    
       respMat(1,:)=block;
       respMat(2,:)=trialnum;
       respMat(3,:)=trialtype;
   
                    % Fixation point before the trials
                    Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
                    % Flip to the screen
                    [VBLTimestamp] = Screen('Flip', window, when);
            
                    toss = randi(length(iTi));
                    currITI = iTi(toss);
                    iTi(toss)=[];
                    
                    if isempty(iTi)
                    iTi = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];
                    end
                    
                    if trialnum<piccount
                    Screen('Flip', window, VBLTimestamp-slack+currITI);
                    end
    
        if  trialtype == 1 % if it is a familiar pic trial
            currImageLocation = familiar;
            curr_picnum = piclist_fam(randi(length(piclist_fam)));
            piclist_fam=setdiff(piclist_fam, curr_picnum);
            
        else % if it is an unfamiliar pic trial
            currImageLocation = unfamiliar;
            curr_picnum = piclist_unfam(randi(length(piclist_unfam)));
            piclist_unfam=setdiff(piclist_unfam, curr_picnum);
            
        end
        
        KbQueueCreate();

        currImage = [currImageLocation filesep pics_familiar{curr_picnum}];
        theImage = imread(currImage);
        [a b c] = fileparts(pics_familiar{curr_picnum});
        respMat(4,:) = str2num(b);
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
        respMat(5,:) = StimTime;
        
        KbQueueStart();
        buttonpress=0;
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if pressed
                buttonpress=1;
                break;
            end
        end
        KbQueueStop();
        respMat(6,:) = timeSecs(1)- StimTime;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(Key.blue)
            respMat(7,:) = 1;
        elseif keyCode(Key.yellow)
            respMat(7,:) = 2;  
        elseif keyCode(Key.green)
            respMat(7,:) = 3;
        elseif keyCode(Key.red)
            respMat(7,:) = 4;  
        end
        
       
        Screen('DrawDots', window, [xCenter; yCenter], 15, black, [], 2);
        Screen('Flip', window);
        WaitSecs(0.5);
    
    Exp.PerformanceMat = [Exp.PerformanceMat respMat];
    
    save(filename,'Exp');
    end

    

 end
end


% End of experiment screen. We clear the screen once they have made their
% response

DrawFormattedText(window, 'SON. Herhangi bir tusa basiniz...',...
    'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;
KbQueueRelease();
sca;

ShowCursor;

