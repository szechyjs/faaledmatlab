%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Configures and Runs Tests Based on Signal Detection Theory %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc

% Default pulse widths
pulses = [26 90];       % 26, 90, 226, 750, 2000
num_pulses = length(pulses);

% Time approximation variables
time_pre = 10;
time_steady = 20.3;
time_pulse = 17.5;
time_total = 0;

%% Configure the test
run_pre = questdlg('Run pre-test?', 'Pre-test', 'Yes', 'No', 'Yes');
run_steady = questdlg('Run steady state?', 'Steady State', 'Yes', 'No', 'Yes');
run_pulse = questdlg('Run pulse test(s)?', 'Pulse Tests', 'Yes', 'No', 'Yes');

if (strcmp(run_pulse, 'Yes'))
    disp('The current pulse widths are: (ms)');
    disp(pulses);
    chg_pulses = input('To change them press enter "y" : ', 's');
    
    if (strcmp(chg_pulses, 'y'))
       pulses = [];
       num_pulses = input('Enter the number of pulses to test: ');
       for i=1:num_pulses
           pulses(length(pulses)+1) = input(sprintf('Enter the pulse width (ms) for test %d : ', i));
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

