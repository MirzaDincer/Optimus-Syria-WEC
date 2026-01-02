%% setup
clearvars;close all;clc;
addpath(genpath('..\WetiMatlabFunctions'))
addpath('..\ControlTools\')

%% Read Results
FB{1}                      = ReadFASTbinaryIntoStruct('URef_20_Seed_01_FB.outb');
FB{2}                      = ReadFASTbinaryIntoStruct('URef_20_Seed_02_FB.outb');
FB{3}                      = ReadFASTbinaryIntoStruct('URef_20_Seed_03_FB.outb');

FBFF{1}                    = ReadFASTbinaryIntoStruct('URef_20_Seed_01_FBFF.outb');
FBFF{2}                    = ReadFASTbinaryIntoStruct('URef_20_Seed_02_FBFF.outb');
FBFF{3}                    = ReadFASTbinaryIntoStruct('URef_20_Seed_03_FBFF.outb');
FBFF_R{1}                  = ReadROSCOtextIntoStruct('URef_20_Seed_01_FBFF.RO.dbg');
FBFF_R{2}                  = ReadROSCOtextIntoStruct('URef_20_Seed_02_FBFF.RO.dbg');
FBFF_R{3}                  = ReadROSCOtextIntoStruct('URef_20_Seed_03_FBFF.RO.dbg');

nSeeds = 3;

%% cost
% cost display results
RotSpeed_0  = 10;     % [rpm]
TwrBsMyt_0  = 8.0374e+04;  % [kNm] 
t_Start     = 60;        % [s]

for i = 1:nSeeds
    % cost for feedback only
    Cost_FB(i) = (max(abs(FB{i}.RotSpeed(FB{i}.Time>=t_Start)-RotSpeed_0))) / RotSpeed_0 ...
         + (max(abs(FB{i}.TwrBsMyt(FB{i}.Time>=t_Start)-TwrBsMyt_0))) / TwrBsMyt_0;
    
    % cost for feedback feedforward
    Cost_FBFF(i) = (max(abs(FBFF{i}.RotSpeed(FBFF{i}.Time>=t_Start)-RotSpeed_0))) / RotSpeed_0 ...
         + (max(abs(FBFF{i}.TwrBsMyt(FBFF{i}.Time>=t_Start)-TwrBsMyt_0))) / TwrBsMyt_0;
end

for i = 1:nSeeds
    fprintf('Cost for feedback only seed%i:  %f \n', i, Cost_FB(i));
    fprintf('Cost for feedback feedforward seed%i:  %f \n\n', i, Cost_FBFF(i));
end

%% TwrBsMyt DEL
WoehlerExponentSteel    = 4;

for i = 1:nSeeds
    FB_DEL(i) = CalculateDEL(FB{i}.TwrBsMyt(FB{i}.Time>=t_Start), FB{i}.Time(FB{i}.Time>=t_Start), WoehlerExponentSteel);
    FBFF_DEL(i) = CalculateDEL(FBFF{i}.TwrBsMyt(FBFF{i}.Time>=t_Start), FBFF{i}.Time(FBFF{i}.Time>=t_Start), WoehlerExponentSteel);
end

for i = 1:nSeeds
    fprintf("TwrBsMyt DEL for FB only seed%i: %.2f\n", i, FB_DEL(i));
    fprintf("TwrBsMyt DEL for FBFF seed%i: %.2f\n\n", i, FBFF_DEL(i));
end

%% std deviation

% for rpm
for i = 1:nSeeds
    rpmSTD_FB(i) = std(FB{i}.RotSpeed(FB{i}.Time>=t_Start));
    rpmSTD_FBFF(i) = std(FBFF{i}.RotSpeed(FBFF{i}.Time>=t_Start));
end

for i = 1:nSeeds
    fprintf("RPM STD for FB only seed%i: %.2f\n", i, rpmSTD_FB(i));
    fprintf("RPM STD for FBFF seed%i: %.2f\n\n", i, rpmSTD_FBFF(i));
end

%% Rotor speed Power Spectral Density
% feedback only 
dt = 0.0125;     % [s]
fs = 1/dt;       % [Hz]

StartIndex = find(FB{1}.Time == 60, 1, 'first');

N  = length(FB{1}.RotSpeed(StartIndex:end));

% Welch settings: 4 blocks 
L        = floor(N/4);      % block length so we have 4 segments
window   = ones(L,1);       % rectangular window
noverlap = L/2;               % 50% overlap
nfft     = L; 

P1_FB  = cell(1, nSeeds);
fw0_FB = cell(1, nSeeds);

% FB remove mean 
for i = 1:nSeeds
    rpmFB = FB{i}.RotSpeed(StartIndex:end);
    rpmFB = rpmFB - mean(rpmFB);
    
    [P1_FB{i}, fw0_FB{i}]         = pwelch(rpmFB, window, noverlap, nfft, fs); 
end

P1_FBFF  = cell(1, nSeeds);
fw0_FBFF = cell(1, nSeeds);

% FBFF remove mean
for i = 1:nSeeds
    rpmFBFF = FBFF{i}.RotSpeed(StartIndex:end);
    rpmFBFF = rpmFBFF - mean(rpmFBFF);
    
    [P1_FBFF{i}, fw0_FBFF{i}]     = pwelch(rpmFBFF, window, noverlap, nfft, fs);  
end


% plot rotor speed PSD
for i = 1:nSeeds
    figure('Name', sprintf('Rotor Speed PSD - Seed %02d', i));

    semilogy(fw0_FB{i},   P1_FB{i},   'DisplayName', sprintf('FB   seed %02d', i));
    hold on; grid on; box on;
    semilogy(fw0_FBFF{i}, P1_FBFF{i}, 'DisplayName', sprintf('FBFF seed %02d', i));

    title(sprintf('Rotor Speed PSD - Seed %02d', i));
    xlabel('f [Hz]');
    ylabel('P_1(f) [(rpm)^2/Hz]');
    xlim([0 1]);
    ylim([1e-4 1e1])
    legend('Location','best');
end

%% Tower base bending PSD

% FB remove mean 
for i = 1:nSeeds
    rpmFB = FB{i}.TwrBsMyt(StartIndex:end);
    rpmFB = rpmFB - mean(rpmFB);
    
    [P1_FB{i}, fw0_FB{i}]         = pwelch(rpmFB, window, noverlap, nfft, fs); 
end

P1_FBFF  = cell(1, nSeeds);
fw0_FBFF = cell(1, nSeeds);

% FBFF remove mean
for i = 1:nSeeds
    rpmFBFF = FBFF{i}.TwrBsMyt(StartIndex:end);
    rpmFBFF = rpmFBFF - mean(rpmFBFF);
    
    [P1_FBFF{i}, fw0_FBFF{i}]     = pwelch(rpmFBFF, window, noverlap, nfft, fs);  
end


% plot Tower base moment PSD
for i = 1:nSeeds
    figure('Name', sprintf('Tower Base Moment PSD - Seed %02d', i));

    semilogy(fw0_FB{i},   P1_FB{i},   'DisplayName', sprintf('FB   seed %02d', i));
    hold on; grid on; box on;
    semilogy(fw0_FBFF{i}, P1_FBFF{i}, 'DisplayName', sprintf('FBFF seed %02d', i));

    title(sprintf('Tower Base Moment PSD - Seed %02d', i));
    xlabel('f [Hz]');
    ylabel('P_1(f) [(kNm)^2/Hz]');
    xlim([0 1]);
    ylim([5e6 5e8])
    legend('Location','best');
end

%% pitch angle PSD

% FB remove mean 
for i = 1:nSeeds
    rpmFB = FB{i}.BldPitch1(StartIndex:end);
    rpmFB = rpmFB - mean(rpmFB);
    
    [P1_FB{i}, fw0_FB{i}]         = pwelch(rpmFB, window, noverlap, nfft, fs); 
end

P1_FBFF  = cell(1, nSeeds);
fw0_FBFF = cell(1, nSeeds);

% FBFF remove mean
for i = 1:nSeeds
    rpmFBFF = FBFF{i}.BldPitch1(StartIndex:end);
    rpmFBFF = rpmFBFF - mean(rpmFBFF);
    
    [P1_FBFF{i}, fw0_FBFF{i}]     = pwelch(rpmFBFF, window, noverlap, nfft, fs);  
end


% plot Pitch angle PSD
for i = 1:nSeeds
    figure('Name', sprintf('Pitch Angle PSD - Seed %02d', i));

    semilogy(fw0_FB{i},   P1_FB{i},   'DisplayName', sprintf('FB   seed %02d', i));
    hold on; grid on; box on;
    semilogy(fw0_FBFF{i}, P1_FBFF{i}, 'DisplayName', sprintf('FBFF seed %02d', i));

    title(sprintf('Pitch Angle PSD - Seed %02d', i));
    xlabel('f [Hz]');
    ylabel('P_1(f) [(deg)^2/Hz]');
    xlim([0 1]);
    ylim([1e-3 1e2])
    legend('Location','best');
end