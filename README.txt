FAA LED MATLAB
==============


SDT_Config_Run.m
----------------
Running this file will configure and run all the required test for each test subject.

pre_test.m
----------
Gathers information about the test subject and performs a pre-test.
Can be run as a function by passing the subject number as a parameter,
or can be run on its own, and a prompt will as for the values.

steady_test.m
-------------
Performs the steady state test on the test subject.
Can be run as a function by passing the subject number as a parameter,
or can be run on its own, and a prompt will as for the value.

pulse_test.m
------------
Performs the pulse tests on the test subject.
Can be run as a function by passing the subject number and pulse width as a parameter,
or can be run on its own, and a prompt will as for the values.

daq_init.m
----------
Initializes the NI DAQ equipment.

tone.m
------
Creates and plays an auidible tone.
Requires two parameters, the center frequency and the tone duration in seconds.