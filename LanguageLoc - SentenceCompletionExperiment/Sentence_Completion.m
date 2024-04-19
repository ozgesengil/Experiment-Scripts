
 %%% SENTENCE COMPLETION TASK %%%
 
 %%% 2 versions exist: sentence vs nonwords (set1), sentence vs syll (set2)
 %%% the order of stimuli are not randomized across participants yet!!!!
 %%% at the beginning and in the end of the session: 15 secs rest ????
 %%% making stimuli displayed in a horizontal way while also keeping the
 %%% readibility/font size constant????

%% Initial Preferences 

close all;
clearvars;

PsychDefaultSetup(2);

feature('DefaultCharacterSet','UTF8')
Screen('Preference', 'SkipSyncTests', 1)
screensAll = Screen('Screens');
KbName('UnifyKeyNames');
my_key = '1!'; % What key gives a response.
my_trigger = '6'; % What key triggers the script from the scanner.
do_suppress_warnings = 1; % You don't need to do this but I don't like the warning screen at the beginning.
Screen('Preference','TextEncodingLocale','UTF-8');

%% Stuff to change
screenNum = max(screensAll); % Which screen you want to use. "1" is external monitor, "0" is this screen.
DATA_DIR = [pwd filesep 'data']; % Where the Exp will be saved.
STIM_DIR = [pwd]; % Where all the stimuli are.
stim_font_size = 50; 


set=1; % 1 for sentence vs nonword, 2 for sentence vs syll
subj_id= 'sub_03_hasret';


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

%% Some checks to perform

file_to_save = ['sentencecomp_' subj_id '_fmri_run_set' num2str(set) '_data.mat']; 

% Error message if data file already exists.
if exist([DATA_DIR filesep file_to_save],'file')
    
    cd data/
    p = pwd;
    all_files = dir([p '/' file_to_save]);
    all_files = {all_files.name};
    
    file_to_save = ['sentencecomp_' subj_id '_fmri_run_set' num2str(set) '_repeat' num2str(length(all_files)) '_data.mat']; 
    
end

clear Exp

num_of_trials = 50;
num_of_fix = 2;

%% Start experiment

% Choose which stimuli set to use.

    stim = load([STIM_DIR filesep 'sentencecomp_fmri_stim_set' num2str(set) '.mat']);
    stim = stim.stim;
    

% create the specifics of the output structure
Exp.PerformanceMat=[];
Exp.BlockDesignMat=[];
Exp.id=subj_id;
Exp.fix_onsets=zeros(num_of_fix,1);
Exp.fix_ends=zeros(num_of_fix,1);
fix_counter=1;


% Save all data to current folder.
save([DATA_DIR filesep file_to_save], 'Exp');

% Screen preferences
PsychDefaultSetup(2);
Screen('CloseAll');
%PsychDebugWindowConfiguration(0,0.6)
% Setting this preference to 1 suppresses the printout of warnings.
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', do_suppress_warnings);
Screen('Preference', 'TextRenderer', 0);

% Open screen.

[wPtr,~]=Screen('OpenWindow',screenNum,1);
white=WhiteIndex(wPtr);
black = BlackIndex(wPtr);
scrColor = white;
Screen('FillRect',wPtr,scrColor);
Screen(wPtr, 'Flip');

% HideCursor;

KbQueueCreate(); % create the que in the beginning since it will take some time

Screen('TextSize', wPtr , 100);
DrawFormattedText(wPtr,'Hosgeldiniz...','center','center',[],[],1);
Screen(wPtr, 'Flip');


% Get trigger from scanner.

disp('Waiting for scanner trigger ...');
Exp.scannerstarttime = GetSecs;

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

Exp.experimentstarttime = GetSecs; % get experiment start time


%%% Get a rest ????
for i = 1:10
    
    % Screen('FillRect', wPtr, [0 0 0]);
    DrawFormattedText(wPtr, num2str(11-i), 'center', 'center',[1 1 1],1);
    Screen('Flip', wPtr);
    Exp.fix_onsets(fix_counter)=GetSecs;
    WaitSecs(1);
    
end
Exp.fix_ends(fix_counter)=GetSecs;
fix_counter=fix_counter+1;


%%
nblocks=20;
conditions=[1 2];
block_list=repmat(conditions, 1, nblocks/length(conditions));
    
%% Runs

block_counter=0;
iBi= [5 5.5 6 7 7.5 8 9 9.5 10 10.5 11 12 13 13.5 14 15];
curriTi=1;

for ii=1:(length(block_list))
    blockMat=nan(10,1);
    
        block_type=block_list(ii);

%         % Fixation
%             
%             Screen('TextSize', wPtr , 100);
%             DrawFormattedText(wPtr,'+','center','center',[],[],1);
%             Screen(wPtr, 'Flip');
%             WaitSecs(curriTi);



        Screen('TextSize', wPtr , 50);
        DrawFormattedText(wPtr,'Devam etmek için tuşa basın','center','center',black,[],1);
        Screen(wPtr, 'Flip');
        blockMat(8,1)=GetSecs; % the onset of the 'press a button to cont' screen
        
        KbQueueStart();
        buttonpress=0;
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
             secs = keyCode(find(keyCode));
              
             if pressed && (keyCode(escapeKey) || keyCode(KeyEscape) || keyCode(Key.blue)) % make sure it is not sensitive to TR pulses
                 
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
                
                elseif keyCode(Key.blue)
                    blockMat(9,1)=GetSecs; % the response to the ''press a button to cont' screen
                    buttonpress=1;
                    break
                    
                end
              end
            
        end
        KbQueueStop();
        blockMat(10,1)=blockMat(9,1)-blockMat(8,1); % the rt to 'press a button to cont' screen
        
        
         % Fixation
             
            Screen('TextSize', wPtr , 100);
            DrawFormattedText(wPtr,'','center','center',[],[],1);
            Screen(wPtr, 'Flip');
            WaitSecs(curriTi);


        % Start trials
    respMat=nan(8,1);
    for i = ((block_counter*5)+1):((block_counter*5)+5) % 5 sentences/trials at each block
        
        aa=rem(i,5);
        if aa==0
            aa=5;
        end
        respMat(1,1)=ii; % block num
        respMat(2,1)=block_type;
        respMat(3,1)=i;
        respMat(4,1)=aa;
        
        
        blockMat(1,1)=ii; % block num
        blockMat(2,1)=block_type; % block type, 1: sentence, 2: non-sentence

        stim_seq = stim(i);
        %stim_seq=string(stim_seq);
    
        % White screen for 100 ms
    
        white=WhiteIndex(wPtr);
        Screen('FillRect',wPtr,scrColor);
        Screen(wPtr, 'Flip');
        WaitSecs(0.100)
        
        
        
        % Sequence presentation 
    
        Screen('TextSize', wPtr , stim_font_size);
    
     
       
            DrawFormattedText(wPtr, stim_seq{1},'center','center',black,[],1);
            Screen(wPtr, 'Flip');
            respMat(5,1)=GetSecs; % the onset of the trial
            if rem(i,5)==1 % if it is the first trial of the block
                blockMat(3,1)=GetSecs; % the start of the block
            end
        
        KbQueueStart();
        buttonpress=0;
        while buttonpress==0
            [pressed, keyCode] = KbQueueCheck();
             secs = keyCode(find(keyCode));
              
             if pressed && (keyCode(escapeKey) || keyCode(KeyEscape) || keyCode(Key.blue)) % make sure it is not sensitive to TR pulses
                 
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
                
                elseif keyCode(Key.blue)
                    if rem(i,5)==0 % if it is the last trial
                        blockMat(4,1)=secs; % end of the block with the response
                        blockMat(5,1)=blockMat(4,1)-blockMat(3,1); % the duration of the block
                    end
                    respMat(6,1)=secs; % the button press
                    buttonpress=1;
                    break
                    
                end
              end
            
        end
        KbQueueStop();
    
        % White screen for 100 ms
    
        Screen('FillRect',wPtr,scrColor);
        Screen(wPtr, 'Flip');
        WaitSecs(0.100);
        
        if rem(i,5)==0
        blockMat(6,1)=GetSecs; % the end end of the block :)
        end
        
        respMat(7,1)=GetSecs; % end of the trial
        respMat(8,1)=respMat(7,1)-respMat(5,1); % the duration of the trial
        
        if rem(i,5)==0 && i~=50
        curr_iBi=iBi(randi(length(iBi)));
        Screen('TextSize', wPtr , 100);
        DrawFormattedText(wPtr,'+','center','center');
        Screen(wPtr, 'Flip');
        blockMat(7,1)=GetSecs; % the onset of the iBi
        WaitSecs(curr_iBi);
           if isempty(iBi)
             iBi= [5 5.5 6 7 7.5 8 9 9.5 10 10.5 11 12 13 13.5 14 15];
           end
        end
        
       
       

        if i==50 % Fixation occurs end the end of the run, too
        
            % Fixation
        
            Screen('TextSize', wPtr , 100);
            DrawFormattedText(wPtr,'dinlenin','center','center',black,[],1);
            Screen(wPtr, 'Flip');
            Exp.fix_onsets(fix_counter) = GetSecs;
            WaitSecs(10);
        
            Exp.fix_ends(fix_counter) = GetSecs;
            
            fix_counter=fix_counter+1;

         end  
     Exp.PerformanceMat = [Exp.PerformanceMat respMat]; 
    end
    
    block_counter=block_counter+1;
    Exp.BlockDesignMat = [Exp.BlockDesignMat blockMat];
    save([DATA_DIR filesep file_to_save], 'Exp');
end

save([DATA_DIR filesep file_to_save], 'Exp');

Exp.runtime = GetSecs - Exp.experimentstarttime;

% End of experiment screen
Screen('TextSize', wPtr, 50);
DrawFormattedText(wPtr, 'Calisma tamamlandi! Tusa basin',...
    'center', 'center', black, [], 1);
Screen('Flip', wPtr);
KbStrokeWait;

sca;

ListenChar(0); %start taking keyboard input for default programs
KbQueueRelease(); %delete the collected responses from the que

Priority(0); % set priority to default
ShowCursor; % show cursor

Screen('CloseAll');
ShowCursor

% Save all data to current folder.
save([DATA_DIR filesep file_to_save], 'Exp');


% At the end of your code, it is a good idea to restore the old level.
Screen('Preference','SuppressAllWarnings',oldEnableFlag);

