%% Dyadic Vocal State Generator
%{
   Author: Natasha Yamane, MA <nmy2103@tc.columbia.edu>
   Date created: July 13, 2017
   Last updated: February 28, 2020
%}

%%
% The following program processes raw output data from the Automatic Vocal 
% Transaction Analyzer (AVTA) to generate instances  of individual partner
% vocalizations in a workable Microsoft Excel format.  The resulting .xls
% file(s) can then be used for further data analysis.

%% Prepping for the program
% # *IMPORTANT:* This program (*.m* file) MUST be saved within the same
% directory as all of the files that will be accessed in this program.
% # Create a folder containing all the .pa files to be scanned.
% # *Convert the .pa files into *.txt* files for scanning.  This can easily 
% be done by replacing *.pa* with *.txt* in each file's name. 
% # Open a new Excel workbook.  Copy and paste a list of the new .txt files 
% into one column in the spreadsheet. *Save the workbook as a .xls file.*

%% Instructions for running the program
% # Within line 40 of the syntax below, replace |FILENAME1.xls| with the
% name of the Excel spreadsheet containing the list of .txt files.
% # Within line 291 of the syntax below, replace |FILENAME2.xls| with a
% filename of your choice for the Excel workbook containing all output.
% This is the default setting.
% Optional: Uncomment the last block of syntax to generate your output as
% individual Excel files.

%% Prepare workspace
clear           % clears workspace
clc             % clears command window
close all       % closes all figures

%% Importing dyad codes

% reads .xlsx file containing individual data sets
[~,~,Dyad_IDs] = xlsread('FILENAME1.xls');
    
% indexes array of .txt files
for data = 1:length(Dyad_IDs)
    
    % opens .txt file
    fileID = fopen(Dyad_IDs{data});

    % reads and saves data as cell array, skipping header line
    dyad = textscan(fileID,'%s','HeaderLines',1); 
        
    % opens up 'dyad' cell array as 'raw'
    raw = [dyad{:}{:}];
        
        % indexes through each dyad's line of 'raw'
        for code = 1:numel(raw)
            
            % converts each element to double class
            dyad_codes(code) = str2double(raw(code));
        end
        
    % stores codes in cell array 'ALL_DATA'
    ALL_DATA{data} = dyad_codes;
        
    % closes .txt file
    fclose(fileID);
        
    % clears 'dyad_codes' to prepare for the following dyad
    clear dyad_codes
        
    % clears 'fileID' to prepare for the following .txt file
    clear fileID
        
    % stores source file names in new array 'ALL_DYADS'
    ALL_DYADS{data} = Dyad_IDs{data};
end

clear raw
clear data
clear code
clear dyad

disp('*** All Dyad Files ***')
disp(ALL_DYADS)

disp('*** All Original Dyadic Codes ***')
disp(ALL_DATA)
%% Generating all raw instances of vocalization

for dat = 1:length(ALL_DATA) % indexes through each dyad
    
    % opens up each dyad as 'dyad_dat'
    dyad_dat = [ALL_DATA{dat}(:)];
    
    % indexes from second element through each dyadic code
    for i = 2:2:numel(dyad_dat)

        % generates instances for silence
        if dyad_dat(i) == 0
           p1_voc(i) = 5;
           p2_voc(i) = 5;

        % generates instances for partner1 vocalization
        elseif dyad_dat(i) == 1
           p1_voc(i) = 1;
           p2_voc(i) = 5;
           
        % generates instances for partner2 vocalization 
        elseif dyad_dat(i) == 2
           p1_voc(i) = 5;
           p2_voc(i) = 1;
        
        % generates instances for simultaneous speech
        elseif dyad_dat(i) == 3
           p1_voc(i) = 1;
           p2_voc(i) = 1;
        
        % ignores signal end code of 07
        elseif dyad_dat(i) > 3
           p1_voc(i) = 0;
           p2_voc(i) = 0;
        end
        
    end
    
    clear dyad_dat
    clear i   
    
    % stores vocalizations in separate cell arrays
    ALL_P1_VOCALS{dat} = p1_voc;
    ALL_P2_VOCALS{dat} = p2_voc;
    
    clear p1_voc
    clear p2_voc
end

clear dat

disp('***** Instances of Vocalizations *****')

disp('*** All Partner 1 Vocalizations ***')
disp(ALL_P1_VOCALS)

disp('*** All Partner 2 Vocalizations ***')
disp(ALL_P2_VOCALS)

%% Generating only exact instances of vocalization

% indexes through each partner1 track
for p1 = 1:length(ALL_P1_VOCALS)
    
    % opens up each partner1 track
    p1_dat = [ALL_P1_VOCALS{p1}(:)];
    
    % removes exraneous 0s from track
    p1_dat(p1_dat == 0) = [];
    
    % codes instances of silence as 0s
    p1_dat(p1_dat == 5) = 0;
    
    PARTNER1_TRACKS{p1} = p1_dat;
    
    % generates quarter-second time points
    x = (numel(p1_dat) - 1) * 0.25;
    t = 0:.25:x;
    
    % stores quarter-second timepoints in separate cell arrays
    ALL_QUARTER_SEC{p1} = t';
    
    clear p1_dat
    clear x
    clear t
end

disp('*** All Partner 1 Tracks Prepared ***')
disp(PARTNER1_TRACKS)

clear p1

% indexes through each Partner 2 track
for p2 = 1:length(ALL_P2_VOCALS)
    
    % opens up each Partner 2 track
    p2_dat = [ALL_P2_VOCALS{p2}(:)];
    
    % removes extraneous 0s from track
    p2_dat(p2_dat == 0) = [];
    
    % codes instances of silence as 0s
    p2_dat(p2_dat == 5) = 0;
    
    PARTNER2_TRACKS{p2} = p2_dat;
    
    clear p2_dat
end

disp('*** All Partner 2 Tracks Prepared ***')
disp(PARTNER2_TRACKS)

clear p2

% removes extraneous zeros from original AVTA codes
for c = 1:length(ALL_DATA)
    dyad = [ALL_DATA{c}(:)];
    dyad(1:2:end) = [];
    dyad(end) = [];
    
    % stores cleaned up codes back into array
    ALL_DATA{c} = dyad;
    
    clear dyad
end

clear c

%%
% %% Data checking with descriptives of SS
% 
% for i = 1:length(ALL_DATA)
%     VS{i,1} = numel(find(ALL_DATA{i} == 0)) / 4;
%     VS{i,2} = numel(find(ALL_DATA{i} == 1)) / 4;
%     VS{i,3} = numel(find(ALL_DATA{i} == 2)) / 4;
%     VS{i,4} = numel(find(ALL_DATA{i} == 3)) / 4;
% end
% 
% % creates crosstabulation of dyads and 4-state codes
% xtab = table(Dyad_IDs, VS);
% 
% % writes table into MS Excel file
% writetable(xtab,'datacheck_XTAB.xlsx', 'FileType', ...
%     'spreadsheet','Sheet', 1)
% 
% % calculate mean and SD of SS frequency
% MEAN = mean([VS{:,4}]);
% SD = std([VS{:,4}]);
% 
% % plot distribution of SS ("3")
% histogram([VS{:,4}])
% hold on
% x = [MEAN, MEAN];
% y = [0,15];
% plot(x,y)
% plot([MEAN-SD, MEAN-SD], y)
% plot([MEAN+SD, MEAN+SD], y)
% hold off

%% Generating dyad filenames for table output

for d = 1:length(PARTNER1_TRACKS)
    
    % opens up each track as 'dyad_dat'
    track = [PARTNER1_TRACKS{d}(:)];
    
    % indexes from second element through each dyadic code
    for i = 1:numel(track)
        dyad_file(i) = string(ALL_DYADS{d});
    end
    
    ALL_DYAD_FILES{d} = dyad_file';
    
    clear dyad_file
end

clear d
clear track
clear i

%% Generating tables for Excel output

% designates variables for table output
Dyad = ALL_DYAD_FILES;
Original_Code = ALL_DATA;
Time = ALL_QUARTER_SEC;
Partner1 = PARTNER1_TRACKS;
Partner2 = PARTNER2_TRACKS;

% converts .txt filenames to .xls filenames
new_IDs = strrep(Dyad_IDs,'txt','xls');

%% 
% The following section allows for output in *one Excel workbook* or
% separate *Excel worksheets*. Replace |FILENAME2.xls| with a filename
% of your choice for the output file.

% generates table output for separate Excel worksheets
for dat = 1:length(Dyad)
    VR_Output = table(Dyad{dat}, Original_Code{dat}, Time{dat}, ...
    Partner1{dat}, Partner2{dat}, 'VariableNames', {'Dyad' ...
        'Original_Code' 'Time' 'Partner1' 'Partner2'});

    % writes table into MS Excel file
    writetable(VR_Output,'FILENAME2.xls', ...
        'FileType','spreadsheet','Sheet',dat)
end

% % generates table output for separate Excel workbooks
% for dat = 1:length(Dyad)
%     VR_Output = table(Dyad{dat}, Original_Code{dat}, Time{dat}, ...
%     Partner1{dat}, Partner2{dat}, 'VariableNames', {'Dyad' ...
%         'Original_Code' 'Time' 'Partner1' 'Partner2'});
% 
%     % writes table into MS Excel file
%     writetable(VR_Output, new_IDs{dat})
%     
%     clear VR_Output
% end