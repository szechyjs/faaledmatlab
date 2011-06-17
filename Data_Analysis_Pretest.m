clc; close all; clear all;

subject_number = input('What is Subject Number?       ');

filename = sprintf('%s %d %s', 'Subject', subject_number, 'Pretest.mat');

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
expected = voltage_pretest.*expected;
expected = expected./max(voltage_pretest);

plot_values = [res_pretest' expected];

subplot(311);bar(x(1:5),plot_values(1:5,:));
title('2.5s Pulse Results');
xlabel('Pulse number');
set(gca,'YTick',[0 1]);
subplot(312);bar(x(6:10),plot_values(6:10,:));
title('90ms Pulse Results');
xlabel('Pulse number');
set(gca,'YTick',[0 1]);
subplot(313);bar(x(11:15),plot_values(11:15,:));
title('226ms Pulse Results');
xlabel('Pulse number');
set(gca,'YTick',[0 1]);
legend('Response','Intensity');