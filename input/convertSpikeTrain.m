% load the spike train used by Julia
% the spike train is stored in the variable "stim"
load relayNeuronResponse;

% parameters
dt          = 0.05;             % time step [ms]
TTLlength   = 10;               % length of the TTL pulse [time steps]

% binarize the spike train
stim        = stim>0;     
i = 1, k = 1;
while i<length(stim)
    if stim(i) == 0
        i               = i+1;
    else
        spikeTrain(k,1) = (i-1)*dt;
        k               = k+1;
        i               = i+TTLlength;
    end
end

% save the spike train
fid = fopen('inputSpikeTrain.txt','w');
for i = 1:1:length(spikeTrain)
    fprintf(fid,'%9.2f\n',spikeTrain(i));
end
fclose(fid);