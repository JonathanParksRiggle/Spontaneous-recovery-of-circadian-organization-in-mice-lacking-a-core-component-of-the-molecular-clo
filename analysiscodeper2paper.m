filename = 'C:\Users\jrigg\Box\Data\Wavelet Per2 for initial papers\Recheck dates\recheck2.mat';
load(filename);
per2fields = fieldnames(datafiles);
per2_struct = datafiles; 
clear datafiles
Longs = [30 6.5 4.26 2.13 1.07]; 
Shorts = [.5 .5 2.13 1.07 .53];
nvoices = [34 27.5 100 101 99]; %give tau sizes of ~100 (except the largest)
%% CURRENTLY YOU ARENT STORING PROPERLY YOU NEED TO BE ABLE TO SELECTS VARS BASED ON LV
for lv = 1:length(per2fields)
    channel = per2fields{lv,1};
    NstepsPerHr=60; % sampling rate in minutes 
    Nsteps=length(per2_struct.(channel));  % total number of samples
    t=(0:Nsteps-1)'/NstepsPerHr; % creates timept vector
    T=t(Nsteps)-t(1); % time at last time point [reqiuired for CalcScaleForCWT
    for window = 1%: length(Longs) Only care about the longest
        longestperiod=Longs(window);shortestperiod=Shorts(window);  % range of periods to use in AWT in hours 
        gamma=3;beta=10; % parameter values for Morse wavelet function 
        nvoice=nvoices(window); % adjust to get 100 tau values depending on window size 
        [fs,tau, qscaleArray] = CalcScaleForCWT(shortestperiod,longestperiod,T,NstepsPerHr,nvoice);%approximates the periods with each wavelet scale
        [row,~,~] = find(tau == tau(tau >= shortestperiod & tau <= longestperiod)'); %allows you to set
        %the true window you want insures that you are looking just at shortest to
        %longest period in your approximate was used for the windows for wavelet
        %ridge 
        vars{lv,1}{window, 1} = qscaleArray(row:row(end,1),1); %adjust each array appropriately
        vars{lv,1}{window, 2} = fs(row:row(end,1),1); %adjust each array appropriately
        vars{lv,1}{window, 3} = tau(row:row(end,1),1); %adjust each array appropriately
        vars{lv,1}{window, 4} = longestperiod;
        vars{lv,1}{window, 5} = shortestperiod;
        vars{lv,1}{window, 6} = t;
    end
end


%% Clean (get rid of any NaNs)
nannum = 0;
internum = 0;

for per2 = 1:length(per2fields)
    field = per2fields{per2, 1};
    per2_struct.(field)(:,4) = fillmissing(per2_struct.(field)(:,4), 'constant', 0);
    [row, col] = find(per2_struct.(field)((per2_struct.(field)(:,4) > 4 * std(per2_struct.(field)(:,4))), 4));
    per2_struct.(field)(row, col) = NaN; 
    per2_struct.(field)(:,4) = fillmissing(per2_struct.(field)(:,4), 'movmean',10);
    
end 


%% Figures for Per2 Paper
for lv = 1:length(per2fields)
    channel = per2fields{lv,1};
    for window = 1% Only need the full window for this
        fulltotal=length(per2_struct.(channel))*length(vars{lv,1}{window, 3});
        edgecut = (vars{lv,1}{window,4} * 1.5) * 60;
        wavedatatemp = abs(wavetrans(per2_struct.(channel)(:,4),{1,gamma,beta,vars{lv,1}{window,2},'bandpass'},'periodic'));
        wavedatatemp = wavedatatemp(ceil(edgecut):1:ceil(end-edgecut),:);
        fulltotal=size(wavedatatemp,1)*size(wavedatatemp,2);
        avgtotalpower = sum(sum(wavedatatemp,2))/fulltotal; 
        normtemp = wavedatatemp/avgtotalpower; 
        norm.(channel) = normtemp; 
    end
end
%%
%for every cell that is Nan makes it this 
for lv = 1:length(per2fields)
    channel = per2fields{lv,1};
    for window = 1% Only need the full window for this
        counter = 0; 
        addendum = 0;
        position= 0;
        for avger = 1:length(norm.(channel))
            counter = counter + 1;
            adder = norm.(channel)(avger,1:200);
            if counter < 3
                addendum = adder + addendum;
            elseif counter == 3
                position = position + 1;
                addendum = adder + addendum;
                avgnorm.(channel)(position, 1:200) = addendum/3;
                addendum = 0;
                counter = 0;
            end
        end
    end
end
       %%         
for lv = 1:length(per2fields)
    channel = per2fields{lv,1};
    for window = 1%:length(Longs)% Only need the full
        figure ('visible', 'off')
        h = pcolor((1:length(avgnorm.(channel)))/480, vars{lv,1}{window,3}, avgnorm.(channel)');
        colorbar
        caxis([0, quantile(max(avgnorm.(channel)), .75)]) 
        colormap jet
        set(h, 'EdgeColor', 'none')
        set(gca,'TickDir','out');
        saveas(gcf, ['C:\Users\jrigg\Box\Data\Wavelet Per2 for initial papers\Recheck dates\Check jet\' channel 'jet' '.tiff'])
        close gcf
    end
end
%%
