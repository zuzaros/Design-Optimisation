clc
clear all
close all

%%%% FOR YOU TO CHANGE %%%%%%
aerofoilName = 'naca2415'; %define aerofoil name - must match the name in the downloaded files
ReynoldsRange = [5e4, 1e5, 2e5, 5e5, 1e6]; %list of Reynolds numbers for each downloaded polar.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%checks if aerofoil polar file already exists - and if so, deletes the file
%before a new one is made
if exist(strcat(aerofoilName,'_polar.txt')) == 2
    fclose('all');
    delete(strcat(aerofoilName,'_polar.txt'))
    disp('aerofoil polar already exists, deleting file')
end

A = txt2cell('AerofoilPolarTemplate.txt'); %outputs aerofoilPolarTemplate as cell array.
%A can be edited and added to - then saved as a .txt file

%add the aerofoil name to A
A{23} = aerofoilName;
A{24} = [];

PolarHeader = txt2cell('PolarHeader.txt'); %outputs PolarHeader.txt as cell array.
PolarHeader(end) = [];

for Re = ReynoldsRange
    
    disp(strcat('reading Reynolds number =',32,num2str(Re)))
    polarPath = strcat(aerofoilName,'\xf-',aerofoilName,'-il-',num2str(Re),'.txt'); %create path for file
    data = readtable(polarPath); %read data

    %create new table with just the data we need - alpha, CL, CD, CM
    extractData = table(data.alpha, data.CL, data.CD, data.CM);

    PolarHeader{3} = num2str(Re); %add in Reynolds number value to correct location in Polar Header
    Asize = size(A,2); %look at current size of A

    %loop over PolarHeader and add to cell array, A
    for i = 1:size(PolarHeader,2)
        A{Asize + i} = PolarHeader{i};
    end

    Asize = size(A,2); %look at current size of A
    %loop over rows in extracted data and add to cell array, A
    for i = 1:size(extractData,1)
        A{Asize + i} = num2str(table2array(extractData(i,:)));
    end

    %add in new line to A to separate data
    A{end + 1} = [];

end

% Write cell A into txt
disp('writing to .txt file')
fid = fopen(strcat(aerofoilName,'_polar.txt'), 'w');
for i = 1:numel(A)
        fprintf(fid,'%s\n', char(A{i}));
end
fclose(fid);
disp('writing complete')