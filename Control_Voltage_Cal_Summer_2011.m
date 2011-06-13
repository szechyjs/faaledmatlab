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
addchannel(ai, [0 1]);
% Set the sample rate and samples per trigger
ai.SampleRate = 100;
ai.SamplesPerTrigger = 300;

putsample(ao, [0 5])
pause;

TestArray_Length = 20;
TestArray = [3.2 3.25 3.3 3.4 3.5 3.6 3.7 3.9 4 4.25 4.5 4.75 5 5.5 6 6.5 7 7.5 8.2 8.7];

output_cont_voltage = -99*ones(1,TestArray_Length);
measured_I = -99*ones(1,TestArray_Length);
for i = 1:TestArray_Length
    putsample(ao, [TestArray(i) 5])
    
    output_cont_voltage(i) = TestArray(i);
    measured_I(i) = input('What is the Intensity Measured?     ');    
end

plot(output_cont_voltage, measured_I,'-o')


v_model = output_cont_voltage;
I = measured_I;
save('int_cal.mat', 'v_model', 'I')


%%



















% %% Find relation between control voltage and intensity
% 
% intensity_curve = [
% 0.015	3
% 2.77	3.2375
% 20.48	3.475
% 42.05	3.7125
% 66.44	3.95
% 89.7	4.1875
% 112.8	4.425
% 135.7	4.6625
% 158.8	4.9
% 181.13	5.1375
% 203.42	5.375
% 224.8	5.6125
% 246.33	5.85
% 267.7	6.0875
% 288.4	6.325
% 308.6	6.5625
% 327.9	6.8
% 345.4	7.0375
% 362.14	7.275
% 376.1	7.5125
% 389.5	7.75
% 402.4	7.9875
% 413.3	8.225
% 424.6	8.4625
% 435.4	8.7
% ];
% v = intensity_curve(:,1)';
% int = intensity_curve(:,2)';
% TestArray_Length = 25;
% % v = output_cont_voltage;
% % int = measured_I;
% plot(v, int)
% 
% w = [1 ones(1,TestArray_Length-2) 1]; %weighting function
% 
% %Try different model functions
% 
% modelFun = @(b,x) b(1) + b(2)*x + b(3)*x.^2;
% 
% start = [1, 1, 1]; %Initial values for algorythm, best if non-zero
% 
% wght_int = sqrt(w).*int;
% modelFunw = @(b,x) sqrt(w).*modelFun(b,x);
% 
% [bFitw,rw,Jw,Sigmaw,msew] = nlinfit(v,wght_int,modelFunw,start);
% 
% rmsew = sqrt(msew);
% 
% bCIw = nlparci(bFitw,rw,'cov',Sigmaw); %confidence intervals
% seFitw = sqrt(diag(Sigmaw));
% 
% xgrid = linspace(min(v),max(v),200)'; %resolution of regression line
% [yFitw, deltaw] = nlpredci(modelFun,xgrid,bFitw,rw,'cov',Sigmaw);
% figure(1)
% plot(v,int,'ko', xgrid, yFitw,'b-',xgrid,yFitw+deltaw,'b:',xgrid,yFitw-deltaw,'b:');
% title('Steady Light')
% xlabel('Control Voltage (V)'); ylabel('Intensity (cd/ft^2)');
% legend({'Data', 'Weighted fit', '95% Confidence Limits'},'location','SouthEast');
% 
% %% Try the opposite relation to determine voltage as a function of intensity
% 
% v = intensity_curve(:,1)';
% int = intensity_curve(:,2)';
% 
% w = [1 ones(1,TestArray_Length-2) 1]; %weighting function
% 
% %Try different model functions
% 
% modelFun = @(b,x) b(1) + b(2)*x + b(3)*x.^2;
% 
% start = [1, 1, 1]; %Initial values for algorythm, best if non-zero
% 
% wght_v = sqrt(w).*v;
% modelFunw = @(b,x) sqrt(w).*modelFun(b,x);
% 
% [bFitw,rw,Jw,Sigmaw,msew] = nlinfit(int,wght_v,modelFunw,start);
% 
% rmsew = sqrt(msew);
% 
% bCIw = nlparci(bFitw,rw,'cov',Sigmaw); %confidence intervals
% seFitw = sqrt(diag(Sigmaw));
% 
% xgrid = linspace(min(int),max(int),200)'; %resolution of regression line
% [yFitw, deltaw] = nlpredci(modelFun,xgrid,bFitw,rw,'cov',Sigmaw);
% figure(2)
% plot(int,v,'ko', xgrid, yFitw,'b-',xgrid,yFitw+deltaw,'b:',xgrid,yFitw-deltaw,'b:');
% title('Steady Light')
% xlabel('Control Voltage (V)'); ylabel('Intensity (cd/ft^2)');
% legend({'Data', 'Weighted fit', '95% Confidence Limits'},'location','SouthEast');
% 
% I = 10:8:420;
% v_model = bFitw(1) + bFitw(2)*I + bFitw(3)*I.^2;
% 
% figure(3)
% plot(int,v,'o',I,v_model)
% xlabel('Control Voltage (V)'); ylabel('Intensity (cd/ft^2)');
% legend('Data', 'Voltage Model','location','SouthEast');