% parameters
frequency = 4;              % Hz
timeStep  = 3e-03;          % sec
N         = ceil(25/timeStep);
Nreps     = [3000];
Words     = [1:14];
MaxWordFit= 13;

% main loop
for idx = 1:1:length(Nreps)
    
    % initial output
    fprintf(['Simulating N = ' num2str(Nreps(idx),'%04.0f') ' repetitions\n']);
    
    % generate random spike trains
    fprintf('\t\t * Generating synthetic spike trains...');
    SpikeTrains = (rand(N,Nreps(idx))<=frequency*timeStep);
    fprintf(' Done\n');
    
    % calculate the entropy tables for total entropy
    fprintf('\t\t * Preprocessing done, calculating probability distributions...\n');
    for i = Words
        fprintf(['\t\t\t > Calculating for words of length ' num2str(i,'%02.0f') '...']);
        for k = 1:1:Nreps(idx)
            frequencyCount{i,k} = zeros(2^i,1);
            for j = 1:length(SpikeTrains)-i+1
                word                        = myfasterbin2dec(SpikeTrains(j:(j+i-1),k));
                frequencyCount{i,k}(word+1) = frequencyCount{i,k}(word+1)+1;
            end
            frequencyCount{i,k} = frequencyCount{i,k}/sum(frequencyCount{i,k});
        end
        fprintf(' Done\n');
    end
    
    % calculate total entropy
    for i = Words
        for k = 1:1:Nreps(idx)
            prob = frequencyCount{i,k};
            prob(prob == 0) = [];
            prob(prob == 1) = [];
            if isempty(prob)
                HRaw(k)   = 0;
                HRate(k)  = 0;
            else
                HRaw(k)   = -(prob'*log2(prob));
                HRate(k)  = HRaw(k)/(i*3e-03);
            end
        end
        Htotal.raw(i)   = mean(HRaw);
        Htotal.rate(i)  = mean(HRate);
        clear HRaw HRate;
    end
    
    % calculate the entropy tables for noise entropy
    fprintf('\t\t * Preprocessing done, calculating probability distributions (noise entropy)...\n');
    for i = Words
        fprintf(['\t\t\t > Calculating for words of length ' num2str(i,'%02.0f') '...']);
        for j = 1:length(SpikeTrains)-i+1
            frequencyCount = zeros(2^i,1);
            for k = 1:1:Nreps(idx)
                word                        = myfasterbin2dec(SpikeTrains(j:(j+i-1),k));
                frequencyCount(word+1)      = frequencyCount(word+1)+1;
            end
            prob = frequencyCount/sum(frequencyCount);
            prob(prob == 0) = [];
            prob(prob == 1) = [];
            if isempty(prob)
                HRaw(j)   = 0;
                HRate(j)  = 0;
            else
                HRaw(j)   = -(prob'*log2(prob));
                HRate(j)  = HRaw(j)/(i*timeStep);
            end
        end
        Hnoise.raw(i)   = mean(HRaw);
        Hnoise.rate(i)  = mean(HRate);
        fprintf(' Done\n');
        clear HRaw HRate;
    end
    
    % plot total entropy
    handle.f(idx) = figure('Name',['Number of repetitions = ' num2str(Nreps(idx))]);
    scl = 1./(Words*timeStep);
    handle.sp(idx,1)    = subplot(211);
    handle.p(idx,1)     = plot(scl,Htotal.raw,'-or'); hold on;
    handle.p(idx,2)     = plot(scl,Hnoise.raw,'-og');
    ylabel('total entropy (bits)');
    vertscl = max(1.2*max(Htotal.raw),1);
    axis([0 max(scl) 0 vertscl]);
    handle.sp(idx,2)    = subplot(212);
    handle.p(idx,3)     = plot(scl,Htotal.rate,'-or'); hold on;
    handle.p(idx,4)     = plot(scl,Hnoise.rate,'-og');
    ylabel('total entropy rate (bits/sec)');
    xlabel('1/word length (sec^{-1})');
    vertscl = max(1.2*max(Htotal.rate),1);
    axis([0 max(scl) 0 vertscl]);
    set([handle.p(idx,:)],'LineWidth',1);
    
    % fit line through total entropy
    coeffNames      = {'a','b'};
    myfun   = fittype(...
        'a*x+b',...
        'independent','x',...
        'coefficients',coeffNames);
    options = fitoptions(...
        'method','NonLinearLeastSquares',...
        'StartPoint',[0.1 22],...
        'MaxFunEvals',5000,...
        'TolFun',1e-07,...
        'TolX',1e-07,...
        'Lower',[-Inf -Inf],...
        'Upper',[+Inf +Inf]);
    [cfun,gof] = fit(scl(1:MaxWordFit)',Htotal.rate(1:MaxWordFit)',myfun,options);
    rng = [0;max(scl)];
    plot(rng,cfun(rng),'-b','LineWidth',2);
    dummy(idx) = cfun.b;
    
    % fit line through noise entropy
    options = fitoptions(...
        'method','NonLinearLeastSquares',...
        'StartPoint',[0.1 1],...
        'MaxFunEvals',5000,...
        'TolFun',1e-07,...
        'TolX',1e-07,...
        'Lower',[-Inf -Inf],...
        'Upper',[+Inf +Inf]);
    [cfun,gof] = fit(scl(1:MaxWordFit)',Hnoise.rate(1:MaxWordFit)',myfun,options);
    plot(rng,cfun(rng),'-b','LineWidth',2); refresh;
    Hfinal(idx)     = dummy(idx)-cfun.b;
%     Hfinal(idx)     = Htotal.rate(10)-Hnoise.rate(10);
    
    % clear variables at the end of the loop
    clear SpikeTrains frequencyCount prob Htotal Hnoise scl;
    fprintf('\n');
end

% figure
figure('Name','Mutual information vs. number of repetitions');
p = plot(Nreps,Hfinal,'-sb','LineWidth',2);
xlabel('number of repetitions');
ylabel('mutual information [bits/sec]');