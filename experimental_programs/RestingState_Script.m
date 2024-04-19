
close all;
clearvars;

PsychDefaultSetup(2);
Screen('Preference','TextEncodingLocale','UTF-8');
feature('DefaultCharacterSet','UTF8')
Screen('Preference', 'SkipSyncTests', 1)
screensAll = Screen('Screens');
KbName('UnifyKeyNames');
my_key = '1!'; % What key gives a response.
my_trigger = '6'; % What key triggers the script from the scanner.
do_suppress_warnings = 1; % You don't need to do this but I don't like the warning screen at the beginning.
Screen('Preference','TextEncodingLocale','UTF-8');

filename = 'sub07_restingstate';

FileName = fullfile(pwd, [filename, '.mat']); 
if exist(FileName, 'file')
    % Get number of files:1
    
    newNum   =  1;
    filename = fullfile(pwd, [filename, sprintf('%d', newNum), '.mat']);
end



%%

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

%%
duration = 10; %%%%%%%%%%%%%%%%
xx=1;
aa=1;
seizurecount=1;


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
RestrictKeysForKbCheck([]);


Exp.Rest_onset(1,1)=GetSecs;

DrawFormattedText(window, '+', 'center', 'center',[0 0 0],[], 1);
Screen('Flip', window);
resting_start=GetSecs;
KbQueueStart();
buttonpress=0;
while GetSecs < resting_start+duration && xx==1 % while the block continues
            [pressed, keyCode] = KbQueueCheck();
            timeSecs = keyCode(find(keyCode));
            if pressed && keyCode(Key.red) % if green is pressed (the seizure start)
                Exp.IctalSeizure(1,seizurecount)=GetSecs; % the onset of the seizure
                Screen('FillRect', window, gray); 
                DrawFormattedText(window,'nobet ekrani \n\n lutfen bekleyiniz','center','center',black,[],1);
                Screen('Flip',window);
                

                while buttonpress==0 % waiting for the end of the seizure
                  [pressed, keyCode] = KbQueueCheck();
                  timeSecs = keyCode(find(keyCode));
                  
                   if pressed && keyCode(escapeKey)
                     ShowCursor;
                 
                     return
                   elseif pressed && keyCode(Key.green) % if seizure is ended
                     Exp.IctalSeizure(2,seizurecount)=GetSecs;
                     seizurecount=seizurecount+1;
                     
                                    DrawFormattedText(window,'dinlenin','center','center',black,[],1);
                                    Screen('Flip',window);
                                    WaitSecs(120);
                     xx=2;
                     buttonpress=1;
                     break;
                   end
                end
                
              
                         KbQueueStop(); 
                         KbQueueFlush();
                         
                

            end
end



Exp.Rest_end(1,1)=GetSecs;

save(filename,'Exp');
DrawFormattedText(window, 'Session Finished \n\n Press Any Key To Exit',...
    'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;
sca;

ShowCursor;







