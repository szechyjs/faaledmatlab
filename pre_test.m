function pre_test(subject_number)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Single Trial Test Based on Signal Detection Theory %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear all; close all;
    
    % DAQ Initialization
    daq_init();

    %load necessary files, inc_cal linearizes the voltage-intensity
    %relationship
    load('int_cal.mat')
    %subject number corralates data to the same subject for all of the tests

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%Subject Data Entry and PreTest%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %subject initialization
    if (~exist('subject_number', 'var'))
        subject_number   = input('What is Subject Number?       ');
    end
    age              = input('Subject Age                   ');
    vision           = input('Subjects Visual Accuity       ','s');
    gender           = input('Is Subject Male or Female?    ','s');
    glass_or_contact = input('Glasses (Enter 1) Hard Contacts (2) Soft (3) Lasik (4) or None (5)?  ','s');

    %Dark Adabption timer
    da_time_limit = 10; %min

    for time = 1:8*60*da_time_limit
        pause(.1)
        output = sprintf('%s %0.3g','Dark Adaptation Time Elapsed:    ',time/600)
    end
    disp('Dark Adaption Complete')
    %%%%%Udate required based on new voltages%%%%%
    test_values = v_model;
    %%%%%------------------------------------%%%%%

    test_values_rand = [test_values(20) test_values(10) 0 test_values(20) test_values(15)];
    test_values_rand = [test_values_rand test_values_rand test_values_rand];
    responses = -99*ones(1,length(test_values_rand));
    intensities_tested = -99*ones(1,length(test_values_rand));
    voltages_tested = -99*ones(1,length(test_values_rand));
    res_time_yes = -99*ones(1,length(test_values_rand));
    res_time_no = -99*ones(1,length(test_values_rand));

    isready = 'n';
    while isready ~= 'y'
        isready = input('Is the tester ready for pre-test?   ','s');
    end

    for test_index = 1:5

        data = ([0*ones(1,1) test_values_rand(test_index)*ones(1,2500) 0*ones(1,1)])';
        %Output data � Start AO and wait for the device object to stop running.
        putdata(ao,[data 5*ones(length(data),1)])

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

    for test_index = 6:10

        data = ([0*ones(1,1) test_values_rand(test_index)*ones(1,45) 0*ones(1,1)])';
        %Output data � Start AO and wait for the device object to stop running.
        putdata(ao,[data 5*ones(length(data),1)])

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

    for test_index = 11:15

        data = ([0*ones(1,1) test_values_rand(test_index)*ones(1,113) 0*ones(1,1)])';
        %Output data � Start AO and wait for the device object to stop running.
        putdata(ao,[data 5*ones(length(data),1)])

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
    subject_data_pretest = struct('SubjectNumber', subject_number, 'Age', age, 'VisualAccuity', vision, 'Gender', gender, 'ControlVoltageOutput', voltages_tested, 'GorC', glass_or_contact, 'ApproximateI', intensities_tested, 'ResponseMatrix', responses, 'YesResponseTime', res_time_yes, 'NoResponseTime', res_time_no);

    filename = sprintf('%s %d %s', 'Subject', subject_number, 'Pretest.mat');
    save(filename, 'subject_data_pretest')

    %%clean up 
    delete(ai);
    delete(ao)
    clear ao

end