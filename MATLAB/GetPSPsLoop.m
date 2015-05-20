%
% Quick script to extract the PSPs from the NEURON simulations
%

% parameters
baseline    = -70; % mV
deltaVoltage= [];

% files
path        = '../output/dataset#19/';
dataFiles	= dir([path '*voltage.txt']);

% get peaks
for fls = 1:1:length(dataFiles)
    
    % load file and get peaks
    data        = load([path dataFiles(fls).name]);
    data        = -data;
    [pks,locs]  = findpeaks(data);
    [pks_min,locs_min] = findpeaks(-data);
    if length(pks_min) ~= length(pks)
        if locs(1) < locs_min(1)
            locs(1) = [];
            pks(1)  = [];
        elseif locs_min(end) > locs(end)
            locs_min(end) = [];
            pks_min(end)  = [];
        end
    end
    
    % plot
    figure;
    plot(data), hold on;
    plot(locs,pks,'or');
    plot(locs_min,-pks_min,'og');
    
    % build stats
    for i = 1:1:length(pks)
        dV(i) = pks(i)+pks_min(i);
    end
    deltaVoltage = cat(2,deltaVoltage,dV);
    
end