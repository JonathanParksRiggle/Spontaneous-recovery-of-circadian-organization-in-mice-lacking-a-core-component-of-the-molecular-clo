%% Upload
locationa = uigetdir; % Identify where to search for files
a = dir([locationa, '/*.csv']); %Store the name of all .xls files as a vector
filename = {a(:).name}.'; %extract the intact file names
files = cell(length(a),1);
for ii = length(a):-1:1 
      % Create the full file name and partial filename
      fullname = [locationa filesep a(ii).name];
      temp = strsplit(a(ii).name,"_"); 
      Chnums{ii,1} = temp{1};
      temp = strcat("Channel", temp); 
      channels{ii,1} = temp{1};
      % Read in the data
      files{ii} =   csvread(fullname, 4, 0);    
end
datafiles = cell2struct(files, channels); 
clear files filename fullname
per2_struct = datafiles;
per2fields = fieldnames(per2_struct);
clear datafiles
%% LD
for per2 = 1:length(per2fields)
    field = per2fields{per2, 1};
    if strcmp(field, 'Channel48') ==1 % 48 12/1 - 12/10
        Start = 1440 * 7;
        End = 1440 * 16; 
    elseif strcmp(field,'Channel207') == 1 || strcmp(field, 'Channel203') == 1 || strcmp(field, 'Channel41') == 1 || strcmp(field,'Channel42')% 12/20 - 12/29
        Start = 1440 * 26;
        End = 1440 * 35; 
    elseif strcmp(field, 'Channel198') == 1 || strcmp(field, 'Channel190') == 1 %198 190 12/13 - 12/22
        Start = 1440 * 19;
        End = 1440 * 28; 
    elseif strcmp(field, 'Channel204') == 1 %204 12/12 12/21
        Start = 1440 * 18;
        End = 1440 * 27; 
    elseif strcmp(field, 'Channel217') == 1 %217 12/10-12/19
        Start = 1440 * 16;
        End = 1440 * 25; 
    elseif strcmp(field, 'Channel189') == 1 %189 11/28 - 12/7
        Start = 1440 * 4;
        End = 1440 * 13; 
    elseif strcmp(field, 'Channel184') == 1 %184 12/18 - 12/27
        Start = 1440 * 24;
        End = 1440 * 33; 
    else %12/22-12/31
        Start = 1440 * 28;
        End = 1440 * 37; 
    end
    Start = Start - 1440; %Start needs to be 1440 (a day) earlier, because it isat the end of the day
    DayArray = 0:1:9;
    MininDay = 1440;
    Lightson = MininDay.*DayArray + (5*60) + 11; 
    Lightsoff = MininDay.*DayArray + (17*60) + 11;% 
    frame = per2_struct.(field)(Start:End,4);
    count = 0;
    for day = 1:10
        if day == 1
            DayTotal(per2,day) = sum(frame(1:1440*day),'all');
            AlphaTotal(per2, day) = sum(frame(1:Lightson(1,day)),'all') +  sum(frame(Lightsoff(1,day):1440*day),'all');
            RhoTotal(per2, day) = sum(frame(Lightson(day,1):Lightsoff(day,1)),'all');
        else
            DayTotal(per2, day) = sum(frame((1440*day - 1439):1440*day),'all');
            AlphaTotal(per2, day) = sum(frame((1440*day - 1439):Lightson(1,day)),'all') +  sum(frame(Lightsoff(1,day):1440*day),'all');
            RhoTotal(per2, day) = sum(frame(Lightson(1,day):Lightsoff(1,day)),'all');
        end
    end
end
%%

Counttable = table(DayTotal, AlphaTotal, RhoTotal);
Counttable.Properties.RowNames = Chnums;
location = 'C:\Users\jrigg\Box\Data\GDX 2021 Analysis\TotalLDCounts.csv';
writetable(Counttable, location, 'WriteRowNames',true);    
        