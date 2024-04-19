%%
% Clear the workspace
close all;
clearvars;
% Setup PTB with some default values
feature('DefaultCharacterSet','UTF8');
PsychDefaultSetup(2);
Screen('CloseAll');
%PsychDebugWindowConfiguration(0,0.8);
Screen('Preference','TextEncodingLocale','UTF-8');

givebreakafter = 10; %%%%%%%%

filename='tl_epilepsy_bodilysens_sub07_run2'; % .mat file with behavioral data that will be saved
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
PsychHID('KbQueueCheck');
% Seed the random number generator
rand('seed', sum(100 * clock));

screenNumber = min(Screen('Screens')); % for default monitor
%screenNumber = max(Screen('Screens')); % for fMRI monitor

% Define black, white and grey
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% condition backgrounds
gray = [0.5 0.5 0.5];
red = [1 0 0];
blue = [0 0 1];
green = [0 1 0];
yellow = [1 1 51/255];
purple = [76/255 0 153/255];
orange = [1 153/255 51/255];

% Open the screen and create offscreenwindow for a different background
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white, [], 32, 2);

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

%% Defining Some Display Parameters


lineWidth = 20; %linewidth of stimuli 

% Make the matrices which will determine our color (condition background) combinations
backColor = [red;blue;green;yellow;purple;orange];
% 6th block is epilepsy block, and will be activated if only participant
% hits a special button

% X and Y coordinates of the points defining out rectangle/frame, centred on the
% centre of the screen
rectpos=[xCenter/2, yCenter/2, 3*xCenter/2, 3*yCenter/2];

color=black; % color of the fixation dots
 
% Define Block Conditions 

conditions=[1 2 3 4 5]; % 6th block will be the epilepsy block


Exp.PerformanceMat=[]; 


blocknum = 5; % how many of each block will be presented in a run
blocklist=[]; % the array of the order of the type of blocks
for i=1:blocknum
    
    conds = conditions;
    conds = conds(randperm(length(conds)));
    blocklist=[blocklist conds];
    
end

response_period= 15; % the duration of a block

Exp.PerformanceMat=[];
Exp.IctalSeizure=[];

%%
% Get time

Exp.scanstarttime = GetSecs;


KbQueueCreate();

%Trigger
disp('Waiting for trigger ...');

textSize=60;
Screen('TextSize',window,textSize);
DrawFormattedText(window,'calisma baslamak uzere...','center','center', [0 0 0], [],1);
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

Exp.expstarttime = GetSecs;

for i = 1:5
    
    Screen('FillRect', window, [1 1 1]);
    DrawFormattedText(window, num2str(6-i), 'center', 'center',[0 0 0],[],1);
    Screen('Flip', window);
    WaitSecs(1);
    
end


%%
%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

seizurecount =1;
IBI = [1 1.5 2 2.5 2.3 1.3 1.7 3 3 4 5 7 8];

for i=1:length(blocklist)
    xx=1;
    aa=1;
    bb=1;
    respMat=nan(6,1);
    
            Screen('FillRect', window, white);
            DrawFormattedText(window,'Devam Etmek Icin Tusa Basiniz','center','center',red,[],1);
            Screen('Flip',window);

                          KbQueueStart();
                          buttonpress=0;
            while buttonpress==0
                [pressed, keyCode] = KbQueueCheck();
                timeSecs = keyCode(find(keyCode));
                if pressed && keyCode(escapeKey)
                    ShowCursor;
                    sca;
                elseif pressed && (keyCode(Key.blue) || keyCode(Key.yellow))
                    buttonpress=1;
                    break;
                elseif pressed && keyCode(Key.red) % if a seizure started
                    
                        Exp.IctalSeizure(1,seizurecount)=GetSecs; % the onset of the seizure
                        % respMat(6,1)=Exp.IctalSeizure(1,seizurecount);
                        Screen('FillRect', window, gray); 
                        DrawFormattedText(window,'nobet ekrani \n\n lutfen bekleyiniz','center','center',black,[],1);
                        Screen('Flip',window);
                        Exp.IctalSeizure(2,seizurecount)=i; % during which block it occured
                        Exp.IctalSeizure(3,seizurecount)=blocklist(i); % during what type of a block it occured
                        Exp.IctalSeizure(4,seizurecount)=3; % it occurred during a press a button to cont screen
                        respMat(4,1)=3; % an ictal seizure is occurred during this block
                
                        while buttonpress==0 % waiting for the end of the seizure
                         [pressed, keyCode] = KbQueueCheck();
                         timeSecs = keyCode(find(keyCode));
                                if pressed && keyCode(escapeKey)
                                    ShowCursor;
                                    return
                                elseif pressed && keyCode(Key.green) % if seizure ended
                                    Exp.IctalSeizure(5,seizurecount)=GetSecs;
                                    seizurecount=seizurecount+1;
                                    aa=2;
                                    xx=2;
                                    buttonpress=1;
                                    DrawFormattedText(window,'dinlenin','center','center',black,[],1);
                                    Screen('Flip',window);
                                    
                                    WaitSecs(60);
                                    break;
                                end
                        end
                end
            end
          
                      xx=1;
          
                    if aa==2 % if just got out of a seizure block occured during a fixation or interblock button press screen, before moving on to the next block wait for a couple of seconds
                        Screen('FillRect', window, white);
                        Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
                        Screen('Flip',window);
                        aa=1;
                        WaitSecs(2);
                    end
                    
                    
                   
                         KbQueueStop(); 
                         KbQueueFlush();
                         
            toss = randi(length(IBI));
            currIBI = IBI(toss);
            IBI(toss)=[];
            if isempty(IBI)
                IBI = [1 1.5 2 2.5 2.3 1.3 1.7 3 3 4 5 7 8];
            end
    
          % Fixation before blocks
          Screen('FillRect', window, white);
          Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
          Screen('Flip',window);
          fixstart=GetSecs;
          KbQueueStart();
          buttonpress=0;
          while GetSecs < fixstart+currIBI && xx==1 % during which the block continues
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if pressed && keyCode(escapeKey) 
                ShowCursor;
                sca;
                return
            
            elseif pressed && keyCode(Key.red) % if green is pressed (the seizure start)
                Exp.IctalSeizure(1,seizurecount)=GetSecs; % the onset of the seizure
                Screen('FillRect', window, gray); 
                DrawFormattedText(window,'nobet ekrani \n\n lutfen bekleyiniz','center','center',black,[],1);
                Screen('Flip',window);
                Exp.IctalSeizure(2,seizurecount)=i; % during which block it occured
                Exp.IctalSeizure(3,seizurecount)=blocklist(i); % during what type of a block it occured
                Exp.IctalSeizure(4,seizurecount)=2; % it occurred during a IBI
                respMat(4,1)=2; % an ictal seizure is occurred during this block
                
                
                while buttonpress==0 % waiting for the end of the seizure
                  [pressed, keyCode] = KbQueueCheck();
                  timeSecs = keyCode(find(keyCode));
                   if pressed && keyCode(escapeKey)
                     ShowCursor;
                 
                     return
                   elseif pressed && keyCode(Key.green) % if seizure ended
                     Exp.IctalSeizure(5,seizurecount)=GetSecs;
                     seizurecount=seizurecount+1;
                     bb=2;
                     xx=2;
                                    DrawFormattedText(window,'dinlenin','center','center',black,[],1);
                                    Screen('Flip',window);
                                    WaitSecs(60);
                     buttonpress=1;
                     break;
                   end
                end
            end
          end
          
          xx=1;
          
          if bb==2 % if just got out of a seizure block occured during a fixation, before moving on to the next block wait for a couple of seconds
              Screen('FillRect', window, white);
              Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
              Screen('Flip',window);
              bb=1;
              WaitSecs(2);
          end
              
                         KbQueueStop(); 
                         KbQueueFlush();
          
    if blocklist(i)==1
        Screen('FillRect', window, red); 
        DrawFormattedText(window,'RAHIM hislerine ODAKLAN','center','center',black,[],1);
       
    elseif blocklist(i)==2
        Screen('FillRect', window, blue); 
        DrawFormattedText(window,'VUCUT hislerine ODAKLAN','center','center',black,[],1);
       
    elseif blocklist(i)==3
        Screen('FillRect', window, green); 
        DrawFormattedText(window,'DINLEN','center','center',black,[],1);

    elseif blocklist(i)==4
        Screen('FillRect', window, yellow); 
        DrawFormattedText(window,'NOBET hislerini HAYAL ET','center','center',black,[],1);
 
    elseif blocklist(i)==5
        Screen('FillRect', window, purple); 
        DrawFormattedText(window,'Vucutsal/dokunsal bir olayi HAYAL ET','center','center',black,[],1);

    end
    
    respMat(1,1)=i; % which block
    respMat(2,1)=blocklist(i); % what type of a block
    
    Screen('Flip',window);
    respMat(3,1)=GetSecs; % the onset of the block
    
    response_period_start=GetSecs;
    
      
            KbQueueStart();
            buttonpress=0;
        while GetSecs < response_period_start+response_period && xx==1 % while the block continues
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if pressed && keyCode(Key.red) % if green is pressed (the seizure start)
                Exp.IctalSeizure(1,seizurecount)=GetSecs; % the onset of the seizure
                respMat(6,1)=Exp.IctalSeizure(1,seizurecount); % if a seizure happened during which the block, the begining of the seizure
                Screen('FillRect', window, gray); 
                DrawFormattedText(window,'nobet ekrani \n\n lütfen bekleyiniz','center','center',black,[],1);
                Screen('Flip',window);
                Exp.IctalSeizure(2,seizurecount)=i; % during which block it occured
                Exp.IctalSeizure(3,seizurecount)=blocklist(i); % during what type of a block it occured
                Exp.IctalSeizure(4,seizurecount)=1; % it occurred during a block
                respMat(4,1)=1; % an ictal seizure is occurred during this block
                
                
                while buttonpress==0 % waiting for the end of the seizure
                  [pressed, keyCode] = KbQueueCheck();
                  timeSecs = keyCode(find(keyCode));
                  
                   if pressed && keyCode(escapeKey)
                     ShowCursor;
                 
                     return
                   elseif pressed && keyCode(Key.green) % if seizure is ended
                     Exp.IctalSeizure(5,seizurecount)=GetSecs;
                     seizurecount=seizurecount+1;
                     
                                    DrawFormattedText(window,'dinlenin','center','center',black,[],1);
                                    Screen('Flip',window);
                                    WaitSecs(60);
                     xx=2;
                     buttonpress=1;
                     break;
                   end
                end
                
               
                
                         KbQueueStop(); 
                         KbQueueFlush();
                
               
   
            end
        end
         if isnan(respMat(6,1))
            respMat(5,1)=GetSecs; % end of a regular block with no seizure during the block
         end
        
        Exp.PerformanceMat=[Exp.PerformanceMat respMat];
        save(filename,'Exp');
        
%         Screen('FillRect', window, white);
%         Screen('DrawDots', window, [xCenter; yCenter], 15, [0 0 0], [], 2);
%         Screen('Flip',window);
%         WaitSecs(1);
        
 
end
 
% End of experiment screen. We clear the screen once they have made their
% response
save(filename,'Exp');

DrawFormattedText(window, 'calisma bitti \n\n cikmak icin bir tusa basin',...
    'center', 'center', black,[],1);
Screen('Flip', window);
KbStrokeWait;
sca;

ShowCursor;
