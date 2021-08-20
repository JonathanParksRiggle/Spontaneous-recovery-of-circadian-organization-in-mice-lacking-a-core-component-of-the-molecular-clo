locationa = uigetdir; % Identify where to search for files
a = dir([locationa, '/*.csv']); %Store the name of all .xls files as a vector
filename = {a(:).name}.'; %extract the intact file names
files = cell(length(a),1);
for ii = length(a):-1:1 
      % Create the full file name and partial filename
      fullname = [locationa filesep a(ii).name];
      temp = strsplit(a(ii).name,'_'); 
      temp = strcat('Channel', temp); 
      channels{ii,1} = temp{1};
      % Read in the data
      files{ii} =   csvread(fullname, 4, 0);    
end
datafiles = cell2struct(files, channels); 
clear files filename temp fullname