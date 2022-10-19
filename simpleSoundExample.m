[s, fs] = audioread('./stimuli/track-syncopated_gridIOI-0.175s_eventType-tone.wav'); 

% see more in documentation 
InitializePsychSound(1); % flag reallyneedlowlatency

% get audio device list
audioDev = PsychPortAudio('GetDevices');

% find output device to use
idx = find(~cellfun(@isempty, regexp({audioDev.DeviceName}, 'Fireface')));

% save device ID
devID = audioDev(idx).DeviceIndex;

% 3 = both playback and recording
playbackMode = 3; 

requestedLatencyClass = 2; 

nChannelsOut = 4; 
nChannelsIn = 4; 

pahandle = PsychPortAudio('Open', ...
                        devID, ...
                        playbackMode, ...
                        requestedLatencyClass, ...
                        fs, ...
                        [nChannelsOut, nChannelsIn]);

% if recording, preallocate 120-s input buffer
bufferSamples = round(fs * 120); 
PsychPortAudio('GetAudioData', pahandle,  bufferSamples); 
                    
%%

% prepare sound and trigger waveforms
n_high = round(0.010 * fs); 
trig_pulse = zeros(1, length(s)); 
trig_pulse(1:n_high) = 1; 

s_out = zeros(nChannelsOut, length(s)); 

s_out(1, :) = s; 
s_out(2, :) = s; 
s_out(3, :) = trig_pulse; 
s_out(4, :) = trig_pulse; 

% first push of audio into the buffer
PsychPortAudio('FillBuffer', pahandle, s_out);

% start playback
startTime = PsychPortAudio('Start', pahandle, [], [], 1);  

PsychPortAudio('Stop', pahandle); 

% get recorded data 
fetchedAudio = PsychPortAudio('GetAudioData', pahandle); 


%%

PsychPortAudio('Close', pahandle)
