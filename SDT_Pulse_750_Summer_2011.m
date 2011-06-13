%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Single Trial Test Based on Signal Detection Theory %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DAQ Initialization %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;

hw = daqhwinfo('nidaq')
ao = analogoutput('nidaq','Dev1')
addchannel(ao, [0 1]);

% Create an analog input object using Board ID "Dev5".
ai = analoginput('nidaq','Dev5');

% Data will be acquired from hardware channel 0 and 1
%these represent the the yes and no buttons
addchannel(ai, [0 1]);
% Set the sample rate and samples per trigger
%at a sample collection rate of 100 samples per second, collecting 500
%samples will be equivalent to 5 seconds of data collection
ai.SampleRate = 100;
ai.SamplesPerTrigger = 500;

%initialize the LED with 0V --> light will be off
putsample(ao, [0 5])

%load necessary files, inc_cal linearizes the voltage-intensity
%relationship
load('int_cal.mat')
%subject number corralates data to the same subject for all of the tests
sub_num = input('What is subject number?    ');

%%%%%Udate required based on new voltages%%%%%
test_values = v_model;
%%%%%------------------------------------%%%%%

num_trials = 7; %each intensity will be displayed this many times
num_ops = 20;   %there will be this many different intensities
blnk_trials = 30; %there will be this many blank trials

%generates all of the values required in a single linear vector
test_values_linear = zeros(1,num_trials*num_ops+blnk_trials);
for i_make_vect = 1:num_ops;
    for i_each_num = 1:num_trials
        test_values_linear(blnk_trials + i_each_num + num_trials*(i_make_vect-1)) = test_values(i_make_vect);
    end
end

%this randomizes the vector differently for each subject
r_i = randperm(length(test_values_linear));
test_values_rand = test_values_linear(r_i);

responses = -99*ones(1,length(test_values_rand));
intensities_tested = -99*ones(1,length(test_values_rand));
voltages_tested = -99*ones(1,length(test_values_rand));
res_time_yes = -99*ones(1,length(test_values_rand));
res_time_no = -99*ones(1,length(test_values_rand));

isready = 'n';
while isready ~= 'y'
    isready = input('Is the tester ready for step increase threshold testing?   ','s');
end

for test_index = 1:length(test_values_rand)
   
    if test_index == 85
        sprintf('%s','30 Second Break Initiated')
        pause(30)
        sprintf('%s','30 Second Break Ended')
    end
           
    data = ([0*ones(1,1) test_values_rand(test_index)*ones(1,375) 0*ones(1,1)])';
    %Output data — Start AO and wait for the device object to stop running.
    putdata(ao,[data 5*ones(length(data),1)])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%we need to test if the user can input while the light is being
    %%%%%%%displayed
    
    % Start the acquisition
    start(ai);
    
    tone(440, 0.4)
    start(ao)
    %trigger(ao)
    wait(ao,6)
    
    %intensities_tested(test_index) = I(test_values_rand(test_index));
    voltages_tested(test_index) = test_values_rand(test_index);

    % Acquire data into the MATLAB workspace
    data = getdata(ai);

    % Graphically plot the results
    t = linspace(0,ai.SamplesPerTrigger/ai.SampleRate,length(data));

    %store button data as vectors called yes and no
    yes = data(:,1);
    no = data(:,2);
        
    res_title = sprintf('%s %d %s %d','Response for Trial Number ', test_index, 'of', length(test_values_rand));

    %realtime plot of user responses
    figure(1)
    subplot(211)
    plot(t,yes,'-g','LineWidth',2);
    title(res_title)
    xlabel('time (s)')
    ylabel('Yes Button Response')
    subplot(212)
    plot(t,no,'-r','LineWidth',2);        
    xlabel('time (s)')
    ylabel('No Button Response')

    % Clean up
    stop(ai);
    
    find_yes = find(yes > 4);
    find_no = find(no > 4);
    
    if ~isempty(find_yes) && isempty(find_no)
        responses(test_index) = 1;
        res_time_yes(test_index) = mean(find_yes)/(ai.samplerate);%make sure this works
        res_time_no(test_index) = 0;
    elseif isempty(find_yes) && ~isempty(find_no)
        responses(test_index) = 0;
        res_time_no(test_index) = mean(find_no)/(ai.samplerate);%make sure this works
        res_time_yes(test_index) = 0;
    else
        %either neither or both button were pushed
        responses(test_index) = -1;
        res_time_yes(test_index) = 0;
        res_time_no(test_index) = 0;
    end
    
    %%%%%%check if this is necessary
    putsample(ao, [0 5])
    
    %break before next trial
    pause(2);
    %%%%%%%%%%%%%%%%%got to here when editing

end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%store and save data%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
subject_data_226 = struct('SubjectNumber', sub_num, 'ControlVoltageOutput', voltages_tested, 'ApproximateI', intensities_tested, 'ResponseMatrix', responses, 'YesResponseTime', res_time_yes, 'NoResponseTime', res_time_no);

filename = sprintf('%s %d %s', 'Subject', sub_num, 'P226.mat');
save(filename, 'subject_data_226')

%%clean up 
delete(ai);
delete(ao)
clear ao

 


