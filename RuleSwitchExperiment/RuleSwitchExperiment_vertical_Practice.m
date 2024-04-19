%----------------------------------------------------------------------
%                       RULE-SWITCH EXPERIMENT
%----------------------------------------------------------------------

% Experiment's description:
    % Relevant stimuli are numbers 

    % Rules are determined by the frame color of the trial
   
    % The responses regarding the numbers are collected with right hand keyboard presses.

    % This is a block design with each block consisting of 10 trials. Blocks
    % are alternating between rule repeat blocks (small/big font rule/blue frame) and 
    % rule switch blocks (the rule is alternating between the two rules we
    % have).

    % The following is how I coded the rules and accurate key presses:
         % Green Frame:
              % Choose the number with greater numerical value (in the left or
              % right, arrow keys)
         % Blue Frame:
              % Choose the number which is written in a bigger font (in the left or
              % right, arrow keys)


% Here are the responding rows of output/performance matrices (in total it has 11):
    % 1. Block number
    % 2. Curr block type (1: rule repeat, 2: rule switch)
    % 3. Current Task/Color condition (1 for Green Frame, 2 for Blue Frame)
    % 4. Number 1 showed in the trial
    % 5. Number 2 showed in the trial
    % 6. If the rule is the font/green rule:1
    % 7. If the rule is the numerical value/blue rule:1
    % 8. Onset of the stimuli
    % 9. Timing of the Response (When the response is made)
    % 10. Correct Answer:1 / Erronous Answer:0
    % 11. Reaction Time
    % 12. 'Press any key to cont.' screen onset
    % 13. 'Press any key to cont.' screen response timing
    % 14. 'Press any key to cont.' screen RT (10-9)


             %%%%% THE THINGS TO CHECK AND CHANGE:
         
     

             % make sure that the response keys are compatible with
             % fmri button boxes
             
             % font sizes and places of displays!!!!
             
             % mirror flip!
             
             % create a practice version after all is well
             
             % make it all turkish!!!!
                  
                  

%%
% Clear the workspace
close all;
clearvars;
% Setup PTB with some default values
PsychDefaultSetup(2);
Screen('CloseAll');
%PsychDebugWindowConfiguration(0,0.6)
Screen('Preference','TextEncodingLocale','UTF-8');
%Screen('Preference', 'SkipSyncTests', 1); %skip synchronization test, for
%just debugging purposes

filename='sub_elif_poyraz_ruleswitch_2'; % .mat file with behavioral data that will be saved
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
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white, [], 32, 2);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white, [0 10 1900 1000], 32, 2);
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


%% Defining Some Display Parameters

theColor = [0 0 0]; % color of stimuli (letter or number)
lineWidth = 20; %linewidth of stimuli (letter or number)

% Make the matrices which will determine our color (condition) combinations
rectColor(1,:) = [0 1 0]; % green
rectColor(2,:) = [0 0 1]; % blue

% X and Y coordinates of the points defining out rectangle/frame, centred on the
% centre of the screen
rectpos=[2*xCenter/3, 1*yCenter/4, 4*xCenter/3, 7*yCenter/4];

color=black; % color of the fixation dots
 

%% Defining Stimuli Matrices

%define original number and letters
numbers=[0,1,2,3,4,5,6,7,8,9];

%% Define Block Conditions 

conditions_r=[1 2]; % 1: rule repeat block, 2: rule switch block

%% Define Font Sizes

font_size = [260,140];

%% Define Performance Matrices

Exp.PerformanceMat_A=[]; % for block A behavioral data 

%% Starting the Experiment With the Trigger

%TRIGGER : '6'

KbQueueCreate(); % create the que in the beginning since it will take some time

%HideCursor;

disp('Waiting for scanner trigger ...');

textSize=60;
Screen('TextSize',window,textSize);
%DrawFormattedText(window,'The experiment is about to
%start...','center','center', [0 0 0],[],1); % to make it mirror-image
%in FMRI
DrawFormattedText(window,'Hosgeldiniz...','center','center', [0 0 0],[],1);
Screen('Flip',window);

Exp.scannerstarttime = GetSecs;

%ListenChar(2); %Getting keyboard input for only psychtoolbox from now on

% % KbQueueStart();
% % trigger=0;
% % while trigger==0
% %     [pressed, keyCode] = KbQueueCheck();
% %     
% %     if pressed && keyCode(Key.trigger)
% %         trigger=1;
% %         break;
% %     elseif pressed && keyCode(Key.Trigger)
% %         trigger=1;
% %         break;
% %     end
% %     
% % end
% % KbQueueStop();

Exp.experimentstarttime = GetSecs; % get experiment start time

for i = 1:3
    
    Screen('FillRect', window, [1 1 1]);
    DrawFormattedText(window, num2str(4-i), 'center', 'center',[0 0 0],1);
    Screen('Flip', window);
    WaitSecs(1);
    
end
        nblocks=20; % 10 blocks for each block type, 20 in total (it should be a 4x)
        numtrials=10; % 10 trials per block
        respMatA = nan(14, numtrials); % generate the response matrix that will be saved
        iTi = [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5]; %inter-trial interval array
        block_type = repmat(conditions_r, 1, nblocks/length(conditions_r)); % to make rule switch and rule repeat blocks to appear one after the other
        trial_type = repmat(conditions_r, 1, numtrials/length(conditions_r)); % to make rule switch and rule repeat TRIALS to appear one after the other in rule switch blocks
        starterrulelist = 1:(nblocks/2); % will be used to make 50% of the switch trials to begin with rule1, and 50% of them with rule2
        
        
        % to randomize the first block type (starting with rule repeat
        % block vs rule switch block)
          toss=randi(2);
          if rem(toss,2)==0
              conditions_r2 = [2,1];
              block_type = repmat(conditions_r2, 1, numtrials/length(conditions_r2)); % to make rule switch and rule repeat blocks to appear one after the other
          end


       iBi= [5 5.5 6 7 7.5 8 8.5 9 9.5 10 11 11.5 12 13 14 14.5 15];
%% Experimental Loop

for blocks = 1:20 % 20 blocks
        
        fontlist = repmat(conditions_r, 1, numtrials/2); % will be used to make the bigger font appear on the left and right in equal frequency
        length_fontlist = length(fontlist);    
    
        curr_block_type=block_type(blocks); % block type 1 or 2 
         % block type 1: green frame, font rule
         % block type 2: blue frame, numerical value rule
           
         
        for i = 1:numtrials
             
            
              if curr_block_type==1 % if a rule repeat block
                 curr_color = rectColor(1,:); % green frame
                 curr_task = 1;
              elseif curr_block_type==2 % if a rule switch block
                  curr_task = trial_type(i); % choose the rule from the alternating list
                  curr_color = rectColor(curr_task,:);% choose the frame color accordingly
              end
              
            
              if isempty(numbers) % if all the numbers are choosen before in previous trials
                  numbers = [0,1,2,3,4,5,6,7,8,9];  
              end
              
            % choosing which numbers will be appearing
            stimuli{1} = numbers(randi(length(numbers))); % selecting a number
            numbers = setdiff(numbers, stimuli{1}); % donot replace the choosen number
            stimuli{2} = numbers(randi(length(numbers))); % select another number that is not selected for the stimuli 1
            numbers = setdiff(numbers, stimuli{2}); % donot replace the choosen number
            % stimuli 1 will be displayed in the left
            % stimuli 2 will be displayed in the right
            
            % choosing which side will have the bigger font size
            bigfont_side_index = randi(length_fontlist-i+1); 
            bigfont_side = fontlist(bigfont_side_index); % if 1: it will appear on the left, if 2: it will appear on the right 
            fontlist(bigfont_side_index)=[]; % do not replace the choosen number 
            
            % learning the correct responses based on the stimuli picked
            resp_numvalue=(stimuli{1}>stimuli{2}); % (if 1: stimulus1>stimulus2, and left is the correct answer for this rule)
            resp_font=(bigfont_side==1); % (if 1: left side has bigger font size, left is the correct answer for this rule)
            
            % saving those variables to the performance matrix
            respMatA(1,i)=blocks;
            respMatA(2,i)=curr_block_type;
            respMatA(3,i)=curr_task;
            respMatA(4,i)=stimuli{1};
            respMatA(5,i)=stimuli{2};
            respMatA(6,i)=resp_numvalue;
            respMatA(7,i)=resp_font;

            stimuli1 = num2str(stimuli{1}); %preparing for screen display
            stimuli2 = num2str(stimuli{2});  %preparing for screen display
            Screen('FrameRect', window, curr_color, rectpos, lineWidth); % frame for the selected condition/color

                        if bigfont_side==1 % the bigger font for the left side
                            Screen('TextSize', window, font_size(1));
                            DrawFormattedText(window, stimuli1, 'center', 11*yCenter/8, theColor,[],1);
                            Screen('TextSize', window, font_size(2));
                            DrawFormattedText(window, stimuli2, 'center', 7*yCenter/8, theColor,[],1);
                        elseif bigfont_side==2 % the bigger font for the right side
                            Screen('TextSize', window, font_size(2));
                            DrawFormattedText(window, stimuli1, 'center', 11*yCenter/8, theColor,[],1);
                            Screen('TextSize', window, font_size(1));
                            DrawFormattedText(window, stimuli2, 'center', 7*yCenter/8, theColor,[],1); 
                        end
                        
                        
            Screen('Flip', window, when);
            tStart = GetSecs;
            respMatA(8,i)=tStart;
            KbQueueStart();
            press=0;
            
            while press==0
              [pressed, keyCode] = KbQueueCheck();
              secs = keyCode(find(keyCode));
              
             if pressed && (keyCode(escapeKey) || keyCode(KeyEscape) || keyCode(Key.blue) || keyCode(Key.yellow)) % make sure it is not sensitive to TR pulses
                 respMatA(9,i)=secs(1);
                 
              if curr_block_type==1 % if it is a rule repeat block (resp_font will determine the correct answer)
            
                if keyCode(escapeKey)
                    ShowCursor;
                    ListenChar(0);
                    sca;
                    return
            
                elseif keyCode(KeyEscape)
                    ShowCursor;
                    ListenChar(0);
                    sca;
                    return
                
                elseif keyCode(Key.blue) && resp_font==1 % if left is pressed and bigger font is on the left
                    respMatA(10, i) = 0; % correct
                    respMatA(11, i) = secs(1) - tStart;
                    press=1;
                    
                elseif keyCode(Key.yellow) && resp_font==0 % if right is pressed and bigger font is on the right
                    respMatA(10, i) = 0; % correct
                    respMatA(11, i) = secs(1) - tStart;
                    press=1;
                    
                else
                    respMatA(10, i) = 1; % error
                    respMatA(11, i) = secs(1) - tStart;
                    press=1;
                   
                end
            
             else % if it is a rule switch block (resp_numvalue and resp_font will determine the answer based on the curr_task type)  
                if  curr_task==1 % green frame
                    if   keyCode(escapeKey)
                         ShowCursor;
                         ListenChar(0);
                         sca;
                         return
            
                    elseif keyCode(KeyEscape)
                        ShowCursor;
                        ListenChar(0);
                        sca;
                        return
                
                    elseif keyCode(Key.blue) && resp_font == 1 % bigger font on the left and left key 
                        respMatA(10, i) = 0; % correct
                        respMatA(11, i) = secs(1) - tStart;
                        press=1;
                    
                    elseif keyCode(Key.yellow) && resp_font == 0 % bigger font on the right and right key 
                        respMatA(10, i) = 0; % correct
                        respMatA(11, i) = secs(1) - tStart;
                        press=1;
                    
                    else 
                        respMatA(10, i) = 1; % error
                        respMatA(11, i) = secs(1) - tStart;
                        press=1;
                    
                    end
                elseif  curr_task==2 % blue frame
                    if   keyCode(escapeKey)
                         ShowCursor;
                         ListenChar(0);
                         sca;
                         return
            
                    elseif keyCode(KeyEscape)
                        ShowCursor;
                        ListenChar(0);
                        sca;
                        return
                
                    elseif keyCode(Key.blue) && resp_numvalue == 1 % bigger number the left and left key 
                        respMatA(10, i) = 0; % correct
                        respMatA(11, i) = secs(1) - tStart;
                        press=1;
                    
                    elseif keyCode(Key.yellow) && resp_numvalue == 0 % bigger number on the right and right key 
                        respMatA(10, i) = 0; % correct
                        respMatA(11, i) = secs(1) - tStart;
                        press=1;
            
                    else 
                        respMatA(10, i) = 1; % error
                        respMatA(11, i) = secs(1) - tStart;
                        press=1;
                    
                    end     
                    
                end
              end
             end
            end
            KbQueueStop();
            
            
       
                    % Fixation point in between trials
                   if respMatA(10,i)==1
                    Screen('DrawDots', window, [xCenter; yCenter], 15, color, [], 2);
                   elseif respMatA(10,i)==0
                    Screen('DrawDots', window, [xCenter; yCenter], 15, [1 0 0], [], 2);
                   end
                    % Flip to the screen
                    [VBLTimestamp] = Screen('Flip', window, when);
            
                    toss = randi(length(iTi));
                    currITI = iTi(toss);
                    iTi(toss)=[];
                    
                    if isempty(iTi)
                    iTi = [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
                    end
                    
                    if i<numtrials
                    Screen('Flip', window, VBLTimestamp-slack+currITI);
                    end
            
        end
        
       
        
         if blocks<nblocks
         Screen('TextSize', window, 100);
         if isempty(iBi)
          iBi= [5 5.5 6 7 7.5 8 8.5 9 9.5 10 11 11.5 12 13 14 14.5 15];
         end
         DrawFormattedText(window, 'dinlenin',...
            'center', 'center', black,[],1);
         Screen('Flip', window);
         respMatA(12,i)=GetSecs; % onset of this screen
         % KbStrokeWait;
         curr_iBi=iBi(randi(length(iBi)));
         WaitSecs(curr_iBi);
         end
         KbQueueStart();
         DrawFormattedText(window, 'devam etmek icin herhangi bir tusa basin',...
            'center', 'center', black,[],1);
         Screen('Flip', window);
         respMatA(13,i)=GetSecs; % onset of press a button to cont screen

         buttonpress=0;
                 while buttonpress==0
                   [pressed, keyCode] = KbQueueCheck();
                   timeSecs = keyCode(find(keyCode));

                        if pressed && keyCode(escapeKey)
                            ShowCursor;
                            sca;
                            return
                        elseif pressed && (keyCode(escapeKey) || keyCode(KeyEscape) || keyCode(Key.blue) || keyCode(Key.yellow))
                            buttonpress=1;
                            break;
            
                        end
                 end
             KbQueueStop();

            respMatA(14,i)=timeSecs(1); % the response timing to press a button to cont screen
            respMatA(15,i)=respMatA(14,i)-respMatA(13,i); % RT to this screen
         
         
         
                    % Fixation point in between episodes
                    Screen('DrawDots', window, [xCenter; yCenter], 15, color, [], 2);
                    % Flip to the screen
                    [VBLTimestamp] = Screen('Flip', window, when);
            
                    toss = randi(length(iTi));
                    currITI = iTi(toss);
                    iTi(toss)=[];
                    
                    if isempty(iTi)
                    iTi = [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
                    end
                    
                    if blocks<nblocks
                    Screen('Flip', window, VBLTimestamp-slack+currITI);
                    end
         
         Exp.PerformanceMat_A = [Exp.PerformanceMat_A respMatA]; % save the behavioral data of block to the matrix
         save(FileName,'Exp');

end


% End of experiment screen 
Screen('TextSize', window, 30);
DrawFormattedText(window, 'Experiment Is Finished \n\n Press Any Key To Exit',...
    'center', 'center', black,[],1);
Screen('Flip', window);
KbStrokeWait;

sca;

ListenChar(0); %start taking keyboard input for default programs
KbQueueRelease(); %delete the collected responses from the que

Priority(0); % set priority to default
ShowCursor; % show cursor

