%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Configures and Runs Tests Based on Signal Detection Theory %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc

% Default pulse widths
pulses1 = [50 140];       % 26, 50, 90, 140, 226, 500, 1000
pulses2 = [500 1000];
pulses_train = [67 115; 140 115];
num_train_pulses = length(pulses_train);

% Time approximation variables
time_pre = 10;
time_steady = 20.3;
time_pulse = 17.5;
time_total = 0;

%% Configure the test
run_pre = questdlg('Run pre-test?', 'Pre-test', 'Yes', 'No', 'Yes');
run_steady = questdlg('Run steady state?', 'Steady State', 'Yes', 'No', 'Yes');
run_pulse = questdlg('Run pulse test(s)?', 'Pulse Tests', 'Yes', 'No', 'Yes');
run_train = questdlg('Run pulse train test(s)?', 'Pulse Train Tests', 'Yes', 'No', 'No');

if (strcmp(run_pulse, 'Yes'))
    ses_num = input('Enter session number (1): ');
    if (ses_num == 1)
        pulses = pulses1;
    elseif (ses_num == 2)
        pulses = pulses2;
    else
        pulses = pulses1;
    end
    num_pulses = length(pulses);
    disp('The current pulse widths are: (ms)');
    disp(pulses);
    chg_pulses = input('To change them press enter "y" : ', 's');
    
    if (strcmp(chg_pulses, 'y'))
       pulses = [];
       num_pulses = input('Enter the number of pulses to test: ');
       for i=1:num_pulses
           pulses(i) = input(sprintf('Enter the pulse width (ms) for test %d : ', i));
       end
    end
end

if (strcmp(run_train, 'Yes'))
    disp('The current pulse widths are: (ms)');
    disp(pulses_train);
    chg_train = input('To change them press enter "y" : ', 's');
    
    if (strcmp(chg_train, 'y'))
       pulses_train = [];
       num_train_pulses = input('Enter the number of pulse trains to test: ');
       for i=1:num_train_pulses
           pulses_train(i,1) = input(sprintf('Enter the pulse width (ms) for test %d : ', i));
           pulses_train(i,2) = input(sprintf('Enter the delay width (ms) for test %d : ', i));
       end
    end
end

% Calculate time approximation
if (strcmp(run_pre, 'Yes'))
    time_total = time_total + time_pre;
end
if (strcmp(run_steady, 'Yes'))
    time_total = time_total + time_steady;
end
if (strcmp(run_pulse, 'Yes'))
    time_total = time_total + (num_pulses * time_pulse);
end
if (strcmp(run_train, 'Yes'))
    time_total = time_total + (num_train_pulses * time_pulse);
end

% Display test configuration
disp(' ');
disp('********************************');
disp('Test Configuration');
disp('********************************');
fprintf('Pre-test: %s\n', run_pre);
fprintf('Steady State: %s\n', run_steady);
fprintf('Pulse: %s\n', run_pulse);
if (strcmp(run_pulse, 'Yes'))
    disp('Pulses to test: (ms)');
    disp(pulses);
end
fprintf('Pulse: %s\n', run_train);
if (strcmp(run_train, 'Yes'))
    disp('Pulse trains to test: (ms)');
    disp(pulses_train);
end
fprintf('Estimated test time: %g minutes\n', time_total);
disp('********************************');
disp(' ');

% Get the subject number
subject_number = input('What is Subject Number? ');

%% Collect user info and run pretest
while (strcmp(run_pre, 'Yes'))
    disp('Starting Pre-test...');
    pre_test(subject_number)
    disp('Pre-test Complete!');
    run_pre = input('Run pre-test again? ', 's');
    if(strcmp(run_pre,'y'))
        run_pre = 'Yes';
    else
        run_pre = 'No';
    end
end

%% Run steady state test
if (strcmp(run_steady, 'Yes'))
    disp('Starting Steady State Test...');
    steady_test(subject_number)
    disp('Steady State Test Complete!');
end

%% Run pulse tests
if (strcmp(run_pulse,'Yes'))
    disp('Starting Pulse Tests');
    for i=1:num_pulses
       fprintf('Testing %dms Pulses...\n', pulses(i));
       pulse_test(pulses(i), subject_number); 
       fprintf('%dms Pulse Test Complete!', pulses(i));
    end
    disp('Pulse Testing Complete!');
end

%% Run pulse train tests
if (strcmp(run_train,'Yes'))
    disp('Starting Pulse Train Tests');
    for i=1:num_train_pulses
       fprintf('Testing %dms Pulses, %dms Delay...\n', pulses_train(i,1), pulses_train(i,2));
       train_test(pulses_train(i,1), pulses_train(i,2), subject_number); 
       fprintf('%dms Pulse Train Test Complete!', pulses_train(i));
    end
    disp('Pulse Train Testing Complete!');
end
