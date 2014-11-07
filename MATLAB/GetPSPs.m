% 
% Quick script to extract the PSPs from the NEURON simulations
%

% parameters
baseline    = -70; % mV

% get peaks
data        = load('../output/dataset#07/woinh_a3_122_00.00_1291_voltage.txt');
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
plot(data), hold on;
plot(locs,pks,'or');
plot(locs_min,-pks_min,'og');

% build stats
for i = 1:1:length(pks)
    deltaVoltage(i) = pks(i)+pks_min(i);
end