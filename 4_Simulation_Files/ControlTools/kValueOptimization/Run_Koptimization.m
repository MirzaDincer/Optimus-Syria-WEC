clearvars; close all; clc;
addpath(genpath('..\..\WetiMatlabFunctions'))

%% Setup

ROSCO           = '..\..\OptSyria\ServoData\ROSCO_FB.IN'; 
FASTexeFile     = '..\..\OptSyria\openfast_x64.exe ';
SimulationName  = '..\..\OptSyria\OPTSyria5MW';
inflowFile      = '..\..\OptSyria\OPTSyria5MW_Inflow.dat';

WindSpeed       = 6.5;
WindSpeedString = sprintf('%.2f HWindSpeed', WindSpeed);
ManipulateTXTFile(inflowFile,'1 HWindSpeed', WindSpeedString);

initalKvalue = '1.727300000000      ! VS_Rgn2K';

k0 = 1.7273;
Deltak = 0.1;
N  = 4;

k_Result = zeros(N,2);

kVals = k0 + (-N:N) * Deltak;

kStr  = compose("%.12f      ! VS_Rgn2K", kVals);  % String with K values to replace

%% Run OpenFAST

for i=1:length(kVals)
  ManipulateTXTFile(ROSCO,initalKvalue,kStr(i)); % Replace K

  dos([FASTexeFile,SimulationName,'_FB.fst']); % Run OpenFAST

  Results              = ReadFASTbinaryIntoStruct([SimulationName,'_FB.outb']);

  sProtation = 60/Results.RotSpeed(end); % seconds per rotation
  dt = Results.Time(2) - Results.Time(1);
  start_index = round((600 - 3*sProtation)/dt); % [(600 seconds) - (3*one rotation in seconds)]/dT
  P = mean(Results.GenPwr(start_index:end));
  k_Result(i,:) = [kVals(i) P]; % Store K and Power

  ManipulateTXTFile(ROSCO,kStr(i),initalKvalue);

end

%% Plot

figure('Name','K value at 6.5 m/s')
title('K values at 6.5 m/s')
hold on;grid on;box on;
plot(k_Result(:,1), k_Result(:,2), "-o")
% xline(1.4273,LineWidth=4);
xlabel('k [Nm/(rad/s)^2]')
ylabel('P [kW]')
% legend('theta=0°','Formula calculation for theta = 0° ',Location='northwest')

%% Save and Finalize
save('k_Result.mat','k_Result')
ManipulateTXTFile(inflowFile, WindSpeedString, '1 HWindSpeed');




