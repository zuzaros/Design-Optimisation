clc
clear all
close all

%Read aerofoil geometry file - the example is for the NACA0012_geometry.txt
%this is the file format Ashes likes to read - so we will stick with this
%as a format.
data = readmatrix('NACA0012_geometry.txt','NumHeaderLines',find(startsWith(strtrim(readlines('NACA0012_geometry.txt')),'Normalized coordinates'),2));


%calculate area over blade span
bladeLength = 1.1; %blade is 1.1m
noElems = 25; %number of elements across blade
bladeSpan = linspace(0,bladeLength,noElems);


%specify the chord distribution across the blade span - from root to tip -
%just as with the Main.m file
newChord = ones(1,noElems)*0.2;
%^^ in this case we have 0.2m across the entire span (of 25 elements)

%the x and y data of the aerofoil shape are normalised coordinates (from 0
%to 1)
xc = data(:,1);
yc = data(:,2);

%loop through the chord lengths, and calculate the cross sectional area of
%each element based on it's chord length
for i = 1:length(newChord)

    %convert normalised coordinates to coordinates in m
    x = xc*newChord(i);
    y = yc*newChord(i);

    %calculate cross-sectional area from coordinates
    Area(i) = abs(trapz(x,y)); 
    %depending on the direction of integration, you will end up with a positive or negative area.
    %we use the abs() as we only care about magnitude, not sign.
    
end

%volume is the integral of the corss sectional area across the span
V = trapz(bladeSpan,Area);


%If you have multiple aerofoils across the blades, you'll have to adapts
%this script - but hopefully this gives you enough to get going!