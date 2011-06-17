function pre_test(subject_number)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Single Trial Test Based on Signal Detection Theory %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close all;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DAQ Initialization %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (~exist('ao') || ~exist('ai'))
        
        hw = daqhwinfo('nidaq');
        
        % Create an analog output object using Board ID "Dev1".
        ao = analogoutput('nidaq','Dev1');
        addchannel(ao, 0);
        
        dio = digitalio('nidaq', 'Dev1');
        addline(dio, 0:1, 0, 'Out');

        % Create an analog input object using Board ID "Dev1".
        ai = analoginput('nidaq','Dev1');

        % Data will be acquired from hardware channel 0 and 1
        % these represent the the yes and no buttons
        addchannel(ai, [0 1]);
        
        % Set the sample rate and samples per trigger
        % at a sample collection rate of 100 samples per second, collecting 500
        % samples will be equivalent to 5 seconds of data collection
        ai.SampleRate = 100;
        ai.SamplesPerTrigger = 500;
    end
    
    % initialize the LED with 0V --> light will be off
    putsample(ao, 0)

    %load necessary files, inc_cal linearizes the voltage-intensity
    %relationship
    load('int_cal.mat')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%Subject Data Entry and PreTest%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %subject initialization
    if (~exist('subject_number', 'var'))
        subject_number   = input('What is Subject Number?       ');
    end
    age              = input('Subject Age                   ');
    vision           = input('Subjects Visual Accuity       ','s');
    gender           = input('Is Subject Male or Female?    ','s');
    glass_or_contact = input('Glasses (Enter 1) Hard Contacts (2) Soft (3) Lasik (4) or None (5)?  ','s');
    skip_dark_adapt  = input('Skip dark adaption?           ','s');

    %Dark Adabption timer
    da_time_limit = 8; %min
    post_res_delay = 2; %sec

    if (strcmp(skip_dark_adapt, 'y'))
        for time = 1:10*60*da_time_limit
            pause(.1)
            output = sprintf('%s %0.3g','Dark Adaptation Time Elapsed:    ',time/600)
        end
        disp('Dark Adaption Complete')
    end
    %%%%%Udate required based on new voltages%%%%%
    test_values = v_model;
    %%%%%------------------------------------%%%%%

    % Use the following values for each test [8.7 4.25 0 8.7 6]
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

    % Steady state test (2.5s pulse)
    for test_index = 1:5

        data = ([0*ones(1,1) test_values_rand(test_index)*ones(1,2500) 0*ones(1,1)])';
        %Output data - Start AO and wait for the device object to stop running.
        putdata(ao, data)

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
        yes = round(data(:,1));
        no = round(data(:,2));

        res_title = sprintf('Response for Trial Number %d of %d, %g volts', test_index, length(test_values_rand)', test_values_rand(test_index));

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
        putsample(ao, 0)

        %break before next trial
        tone(900, 0.1);
        pause(post_res_delay);

    end

    % Pulse test 1 (90ms pulse)
    for test_index = 6:10

        data = ([0*ones(1,1) test_values_rand(test_index)*ones(1,45) 0*ones(1,1)])';
        %Output data - Start AO and wait for the device object to stop running.
        putdata(ao, data)

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
        yes = round(data(:,1));
        no = round(data(:,2));

        res_title = sprintf('Response for Trial Number %d of %d, %g volts', test_index, length(test_values_rand)', test_values_rand(test_index));

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
        putsample(ao, 0)

        %break before next trial
        tone(900, 0.1);
        pause(post_res_delay);

    end

    % Pulse test 2 (226ms pulse)
    for test_index = 11:15

        data = ([0*ones(1,1) test_values_rand(test_index)*ones(1,113) 0*ones(1,1)])';
        %Output data - Start AO and wait for the device object to stop running.
        putdata(ao, data)

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
        yes = round(data(:,1));
        no = round(data(:,2));

        res_title = sprintf('Response for Trial Number %d of %d, %g volts', test_index, length(test_values_rand)', test_values_rand(test_index));

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
        putsample(ao, 0)

        %break before next trial
        tone(900, 0.1);
        pause(post_res_delay);

    end

    % Plot results of Pre-test
    close all;
    x = 1:15;

    expected = [1; 1; 0; 1; 1];
    expected = [expected; expected; expected];

    % Calculated percentage correct
    numcorrect = 0;
    for i=1:length(expected)
        if (res_pretest(i) == expected(i))
            numcorrect = numcorrect + 1;
        end
    end
    percentage = numcorrect / length(expected) * 100;

    % Change expected value to ratio of brightest
    expected = voltages_tested.*expected;
    expected = expected./max(voltages_tested);

    % Compile plot variable
    plot_values = [responses' expected];

    % Plot results
    sprintf('Percentage correct %g%%', percentage)
    subplot(311);bar(x(1:5),plot_values(1:5,:));
    title('2.5s Pulse Results');
    set(gca,'YTick',[0 1]);
    subplot(312);bar(x(6:10),plot_values(6:10,:));
    title('90ms Pulse Results');
    set(gca,'YTick',[0 1]);
    subplot(313);bar(x(11:15),plot_values(11:15,:));
    title('226ms Pulse Results');
    set(gca,'YTick',[0 1]);
    legend('Response','Intensity');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %store and save data%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    subject_data_pretest = struct('SubjectNumber', subject_number, 'Age', age, 'VisualAccuity', vision, 'Gender', gender, 'ControlVoltageOutput', voltages_tested, 'GorC', glass_or_contact, 'ApproximateI', intensities_tested, 'ResponseMatrix', responses, 'YesResponseTime', res_time_yes, 'NoResponseTime', res_time_no);

    filename = sprintf('%s %d %s', 'Subject', subject_number, 'Pretest.mat');
    save(filename, 'subject_data_pretest')

    %%clean up 
    delete(ai);
    delete(ao);
    delete(dio);
    clear ao

end