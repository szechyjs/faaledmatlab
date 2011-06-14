function daq_init()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DAQ Initialization %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (~exist('ao') || ~exist('ai'))
        
        hw = daqhwinfo('nidaq')
        ao = analogoutput('nidaq','Dev1')
        addchannel(ao, [0 1]);
        
        dio = digitalio('nidaq', 'Dev1');
        do_no = addline(dio, 0, 'Out', 'No Output');
        di_no = addline(dio, 1, 'In', 'No Input');
        do_yes = addline(dio, 2, 'Out', 'Yes Output');
        di_yes = addline(dio, 3, 'In', 'Yes Input');
        dig_in = [di_no di_yes];
        dig_out = [do_no do_yes];

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
    end

    %initialize the LED with 0V --> light will be off
    putsample(ao, [0 5])
    
end