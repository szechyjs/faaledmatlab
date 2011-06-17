function percentage = Data_Analysis_Pretest(sub_num)

    clc; close all;

    % If file is ran by itself collect required variables
    if(~exist('sub_num','var'))
        sub_num = input('What is subject number?    ');
    end

    filename = sprintf('%s %d %s', 'Subject', sub_num, 'Pretest.mat');

    xls_threshold_file = 'Pretest Analysis';

    load('int_cal')

    I = [
    0.161659176
    0.234617718
    0.307273527
    0.464694448
    0.641792983
    0.818891519
    1.006585693
    1.38651503
    1.574209204
    2.052526616
    2.545980655
    3.019757079
    3.490506177
    4.40173112
    5.278141821
    6.044055146
    6.61924697
    7.061236477
    7.551663191
    7.789308234];

    load(filename)
    res_pretest = subject_data_pretest.ResponseMatrix;
    voltage_pretest = subject_data_pretest.ControlVoltageOutput';

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
    expected = voltage_pretest.*expected;
    expected = expected./max(voltage_pretest);

    % Compile plot variable
    plot_values = [res_pretest' expected];

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
    
    range = sprintf('%s %d','A',sub_num-100);
    xlswrite(xls_threshold_file, percentage, 1, range)
end