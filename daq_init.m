function daq_init()

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
    
end