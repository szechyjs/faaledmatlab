function pulse_test(pulse_length, sub_num)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Single Trial Test Based on Signal Detection Theory %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear all; close all;
    
    % If file is ran by itself collect required variables
    if(~exist('sub_num','var'))
        sub_num = input('What is subject number?    ');
    end
    
    if(~exist('pulse_length','var'))
        pulse_length = input('What is the pulse length (ms)?    ');
    end

    % DAQ Initialization
    daq_init();

    %load necessary files, inc_cal linearizes the voltage-intensity
    %relationship
    load('int_cal.mat')

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

        data = ([0*ones(1,1) test_values_rand(test_index)*ones(1,pulse_length/2) 0*ones(1,1)])';
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
    subject_data = struct('SubjectNumber', sub_num, 'ControlVoltageOutput', voltages_tested, 'ApproximateI', intensities_tested, 'ResponseMatrix', responses, 'YesResponseTime', res_time_yes, 'NoResponseTime', res_time_no);

    filename = sprintf('%s %d %s%s%s', 'Subject', sub_num, 'P', pulse_length, '.mat');
    save(filename, 'subject_data')

    %%clean up 
    delete(ai);
    delete(ao)
    clear ao
end