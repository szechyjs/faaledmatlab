clc; close all; clear all;

subject_number = input('What is Subject Number?       ');

filename1 = sprintf('%s %d %s', 'Subject', subject_number, 'Steady.mat');
filename2 = sprintf('%s %d %s', 'Subject', subject_number, 'P50.mat');
filename3 = sprintf('%s %d %s', 'Subject', subject_number, 'P140.mat');
filename4 = sprintf('%s %d %s', 'Subject', subject_number, 'P500.mat');
filename5 = sprintf('%s %d %s', 'Subject', subject_number, 'P1000.mat');
filename6 = sprintf('%s %d %s', 'Subject', subject_number, 'PT67.mat');
filename7 = sprintf('%s %d %s', 'Subject', subject_number, 'PT140.mat');

xls_threshold_file = 'Summer_2011_Thresholds';

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


%all subjects will be tested with the steady light
load(filename1)
res_steady = subject_data_steady.ResponseMatrix;
voltage_steady = subject_data_steady.ControlVoltageOutput;
res_time_yes_steady = subject_data_steady.YesResponseTime;
res_time_no_steady = subject_data_steady.NoResponseTime;

% check filenames for existance
if (exist(filename2,'file'))
    file2=1;
else
    file2=0;
end
if (exist(filename3,'file'))
    file3=1;
else
    file3=0;
end
if (exist(filename4,'file'))
    file4=1;
else
    file4=0;
end
if (exist(filename5,'file'))
    file5=1;
else
    file5=0;
end
if (exist(filename6,'file'))
    file6=1;
else
    file6=0;
end
if (exist(filename7,'file'))
    file7=1;
else
    file7=0;
end

%use the if statements to sort the subject by which of the pulse width test
%they took
if (file2 && file3)
    load(filename2)
    pulse_name1 = '50'; 
    res_p1 = subject_data.ResponseMatrix;
    voltage_p1 = subject_data.ControlVoltageOutput;
    res_time_yes_p1 = subject_data.YesResponseTime;
    res_time_no_p1 = subject_data.NoResponseTime;

    load(filename3)
    pulse_name2 = '140'; 
    res_p2 = subject_data.ResponseMatrix;
    voltage_p2 = subject_data.ControlVoltageOutput;
    res_time_yes_p2 = subject_data.YesResponseTime;
    res_time_no_p2 = subject_data.NoResponseTime;
end

if (file4 && file5)
    load(filename4)
    pulse_name1 = '500'; 
    res_p1 = subject_data.ResponseMatrix;
    voltage_p1 = subject_data.ControlVoltageOutput;
    res_time_yes_p1 = subject_data.YesResponseTime;
    res_time_no_p1 = subject_data.NoResponseTime;

    load(filename5)
    pulse_name2 = '1000'; 
    res_p2 = subject_data.ResponseMatrix;
    voltage_p2 = subject_data.ControlVoltageOutput;
    res_time_yes_p2 = subject_data.YesResponseTime;
    res_time_no_p2 = subject_data.NoResponseTime;
end

if (file6 && file7)
    load(filename6)
    pulse_name1 = 'T67'; 
    res_p1 = subject_data.ResponseMatrix;
    voltage_p1 = subject_data.ControlVoltageOutput;
    res_time_yes_p1 = subject_data.YesResponseTime;
    res_time_no_p1 = subject_data.NoResponseTime;

    load(filename7)
    pulse_name2 = 'T140'; 
    res_p2 = subject_data.ResponseMatrix;
    voltage_p2 = subject_data.ControlVoltageOutput;
    res_time_yes_p2 = subject_data.YesResponseTime;
    res_time_no_p2 = subject_data.NoResponseTime;
end

volt_ops = v_model;

range = sprintf('%s %d','A',subject_number-198);
xlswrite(xls_threshold_file, subject_number, 1, range)

%% Results for the 5 second (steady) pulse

figure(1)
subplot(321)
plot(1:170,res_time_no_steady,'ro',1:170,res_time_yes_steady,'go','LineWidth',2)
ylabel('Response Time (s)')
legend('"No" Response', '"Yes" Response')
xlabel('Trial Number (n)')
axis([0 170 .1 5])

false_pos_steady = 0;
res_steady_data = zeros(1,length(volt_ops));
for index = 1:length(res_steady)
    if res_steady(index) == 1
        for jndex = 1:length(volt_ops)
            if voltage_steady(index) == volt_ops(jndex)
                res_steady_data(jndex) = res_steady_data(jndex) + 1;
            end
        end
    end
    if res_steady(index) == 1 && voltage_steady(index) == 0
        false_pos_steady = false_pos_steady + 1;
    end
end

indep = [false_pos_steady/30 res_steady_data/7];
dep = [0; I]';

w = ones(1,length(dep));

if subject_number == 12
    modelFun = @(b,x) b(1)*x + b(2);
else
    modelFun = @(b,x) 1 ./ (1 + exp(-(b(1) + x*b(2))));
end
start = [1, .1]; %Initial values for algorythm, best if non-zero

wght_indep = sqrt(w).*indep;
modelFunw = @(b,x) sqrt(w).*modelFun(b,x);

[bFitw,rw,tilda,Sigmaw] = nlinfit(dep,wght_indep,modelFunw,start);

xgrid = linspace(0,10,1000)'; %resolution of regression line
[yFitw, deltaw] = nlpredci(modelFun,xgrid,bFitw,rw,'cov',Sigmaw);

bottom = find(yFitw <= .5);
top = find(yFitw >= .5);

mid_l = max(bottom);
mid_h = min(top);

threshold = [(yFitw(mid_l)+yFitw(mid_h))/2 (xgrid(mid_l)+xgrid(mid_h))/2]
%threshold = [1 1]

if subject_number == 2 || subject_number == 133 ||subject_number==164
    threshold = [.5,0];
end

title1 = sprintf('%s %d %s %.2f','Steady Light Step Method for Subject', subject_number, 'Threshold =', threshold(2), '\mucd');

figure(1)
subplot(322)
plot(0,false_pos_steady/30,'ro',dep(2:length(dep)),indep(2:length(dep)),'ko',threshold(2), threshold(1),'r^', xgrid, yFitw, 'b-',xgrid,yFitw+deltaw,'b:',xgrid,yFitw-deltaw,'b:','LineWidth',2);
title(title1)
xlabel('Intensity (\mucd)'); 
ylabel('Probability of Detection');
legend({'P(False Pos)','Data', 'Threshold','Weighted fit', '95% Confidence Limits'},'location','SouthEast');
axis([0 10 -.2 1.2])

range = sprintf('%s %d','B',subject_number-198);
xlswrite(xls_threshold_file, threshold(2), 1, range)

%% Results for the P1 (depends on test set up for each of the subjects)

figure(1)
subplot(325)
plot(1:170,res_time_no_p1,'ro',1:170,res_time_yes_p1,'go','LineWidth',2)
ylabel('Response Time (s)')
legend('"No" Response', '"Yes" Response')
xlabel('Trial Number (n)')
axis([0 170 .1 5])

false_pos_p1 = 0;
res_p1_data = zeros(1,length(volt_ops));
for index = 1:length(res_p1)
    if res_p1(index) == 1
        for jndex = 1:length(volt_ops)
            if voltage_p1(index) == volt_ops(jndex)
                res_p1_data(jndex) = res_p1_data(jndex) + 1;
            end
        end
    end
    if res_p1(index) == 1 && voltage_p1(index) == 0
        false_pos_p1 = false_pos_p1 + 1;
    end
end

indep = [false_pos_p1/30 res_p1_data/7];
dep = [0; I]';

w = ones(1,length(dep));

if subject_number == 12
    modelFun = @(b,x) b(1)*x + b(2);
else
    modelFun = @(b,x) 1 ./ (1 + exp(-(b(1) + x*b(2))));
end
start = [1, .1]; %Initial values for algorythm, best if non-zero

wght_indep = sqrt(w).*indep;
modelFunw = @(b,x) sqrt(w).*modelFun(b,x);

[bFitw,rw,tilda,Sigmaw] = nlinfit(dep,wght_indep,modelFunw,start);

xgrid = linspace(0,15,1000)'; %resolution of regression line
[yFitw, deltaw] = nlpredci(modelFun,xgrid,bFitw,rw,'cov',Sigmaw);

bottom = find(yFitw <= .5);
top = find(yFitw >= .5);

mid_l = max(bottom);
mid_h = min(top);

threshold = [(yFitw(mid_l)+yFitw(mid_h))/2 (xgrid(mid_l)+xgrid(mid_h))/2]
%threshold = [1 1]

if subject_number == 118 || subject_number == 2 || subject_number == 2 ||...
        subject_number == 130 || subject_number == 133 |...
        subject_number == 151 ||subject_number == 164
    threshold = [.5,0];
end

title1 = sprintf('%s %s %s %d %s %.2f','Pulse Width ', pulse_name1 ,' ms for Subject', subject_number, 'Threshold =', threshold(2), '\mucd');

figure(1)
subplot(326)
plot(0,false_pos_steady/30,'ro',dep(2:length(dep)),indep(2:length(dep)),'ko',threshold(2), threshold(1),'r^', xgrid, yFitw, 'b-',xgrid,yFitw+deltaw,'b:',xgrid,yFitw-deltaw,'b:','LineWidth',2);
title(title1)
xlabel('Intensity (\mucd)'); 
ylabel('Probability of Detection');
axis([0 15 -.2 1.2])

range = sprintf('%s %d','C',subject_number-198);
xlswrite(xls_threshold_file, threshold(2), 1, range)
    
%% Results for the P2 (depends on test set up for each of the subjects)

figure(1)
subplot(323)
plot(1:170,res_time_no_p2,'ro',1:170,res_time_yes_p2,'go','LineWidth',2)
ylabel('Response Time (s)')
legend('"No" Response', '"Yes" Response')
xlabel('Trial Number (n)')
axis([0 170 .1 5])

false_pos_p2 = 0;
res_p2_data = zeros(1,length(volt_ops));
for index = 1:length(res_p2)
    if res_p2(index) == 1
        for jndex = 1:length(volt_ops)
            if voltage_p2(index) == volt_ops(jndex)
                res_p2_data(jndex) = res_p2_data(jndex) + 1;
            end
        end
    end
    if res_p2(index) == 1 && voltage_p2(index) == 0
        false_pos_p2 = false_pos_p2 + 1;
    end
end

indep = [false_pos_p2/30 res_p2_data/7];
dep = [0; I]';


w = ones(1,length(dep));

if subject_number == 12
    modelFun = @(b,x) b(1)*x + b(2);
else
    modelFun = @(b,x) 1 ./ (1 + exp(-(b(1) + x*b(2))));
end
start = [1, .1]; %Initial values for algorythm, best if non-zero

wght_indep = sqrt(w).*indep;
modelFunw = @(b,x) sqrt(w).*modelFun(b,x);

[bFitw,rw,tilda,Sigmaw] = nlinfit(dep,wght_indep,modelFunw,start);

xgrid = linspace(0,10,1000)'; %resolution of regression line
[yFitw, deltaw] = nlpredci(modelFun,xgrid,bFitw,rw,'cov',Sigmaw);

bottom = find(yFitw <= .5);
top = find(yFitw >= .5);

mid_l = max(bottom);
mid_h = min(top);

threshold = [(yFitw(mid_l)+yFitw(mid_h))/2 (xgrid(mid_l)+xgrid(mid_h))/2]
%threshold = [1 1]

if subject_number == 2 || subject_number == 121 || subject_number == 130 ||...
        subject_number == 133 || subject_number == 164
    threshold = [.5,0];
end

title1 = sprintf('%s %s %s %d %s %.2f','Pulse Width ', pulse_name2 ,' ms for Subject', subject_number, 'Threshold =', threshold(2), '\mucd');

figure(1)
subplot(324)
plot(0,false_pos_steady/30,'ro',dep(2:length(dep)),indep(2:length(dep)),'ko',threshold(2), threshold(1),'r^', xgrid, yFitw, 'b-',xgrid,yFitw+deltaw,'b:',xgrid,yFitw-deltaw,'b:','LineWidth',2);
title(title1)
xlabel('Intensity (\mucd)'); 
ylabel('Probability of Detection');
axis([0 10 -.2 1.2])

range = sprintf('%s %d','D',subject_number-198);
xlswrite(xls_threshold_file, threshold(2), 1, range)
