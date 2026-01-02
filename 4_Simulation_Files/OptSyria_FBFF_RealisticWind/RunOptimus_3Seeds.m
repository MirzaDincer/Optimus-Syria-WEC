%% Setup
% initial conditions should be for 20 m/s
% inflow wind input to TurbulentWind/URef20_seed_0x

clearvars;close all;clc;
addpath(genpath('..\WetiMatlabFunctions'))
addpath('..\ControlTools\')
Parameter = OptSyria_Parameters;

% inflowFile = ''

FASTexeFile     = 'openfast_x64.exe';
SimulationName  = 'OPTSyria5MW';
copyfile(['..\OpenFAST\',FASTexeFile],FASTexeFile)

windDir = "TurbulentWind\";
windName = ["URef_20_Seed_01", ...
            "URef_20_Seed_02", ...
            "URef_20_Seed_03"];
windStr = windDir + windName;

%% Run FB + FBB with 3 seeds 

for i =1:3
    ManipulateTXTFile('OPTSyria5MW_Inflow.dat',windStr(1),windStr(i))

    dos(['openfast_x64.exe ',SimulationName,'_FB.fst']);
    dos(['openfast_x64.exe ',SimulationName,'_FBFF.fst']);

    movefile("OPTSyria5MW_FB.outb", windName(i) + "_FB.outb");
    movefile("OPTSyria5MW_FB.RO.dbg", windName(i) + "_FB.RO.dbg");

    movefile("OPTSyria5MW_FBFF.outb", windName(i) + "_FBFF.outb");
    movefile("OPTSyria5MW_FBFF.RO.dbg", windName(i) + "_FBFF.RO.dbg");

    ManipulateTXTFile('OPTSyria5MW_Inflow.dat',windStr(i),windStr(1))
end

%% Clean up
delete(FASTexeFile)

%% Read Results

FB_seed01                = ReadFASTbinaryIntoStruct('URef_20_Seed_01_FB.outb');
FB_seed02                = ReadFASTbinaryIntoStruct('URef_20_Seed_02_FB.outb');
FB_seed03                = ReadFASTbinaryIntoStruct('URef_20_Seed_03_FB.outb');

FBFF_seed01                = ReadFASTbinaryIntoStruct('URef_20_Seed_01_FBFF.outb');
FBFF_seed02                = ReadFASTbinaryIntoStruct('URef_20_Seed_02_FBFF.outb');
FBFF_seed03                = ReadFASTbinaryIntoStruct('URef_20_Seed_03_FBFF.outb');
FBFF_seed01_R              = ReadROSCOtextIntoStruct('URef_20_Seed_01_FBFF.RO.dbg');
FBFF_seed02_R              = ReadROSCOtextIntoStruct('URef_20_Seed_02_FBFF.RO.dbg');
FBFF_seed03_R              = ReadROSCOtextIntoStruct('URef_20_Seed_03_FBFF.RO.dbg');

%% plot Simulations

% seed01
figure('Name','Seed01')

subplot(4,1,1);
title('Seed01')
hold on; grid on; box on
plot(FB_seed01.Time,       FB_seed01.Wind1VelX);
plot(FBFF_seed01_R.Time,     FBFF_seed01_R.REWS_b);
ylabel('[m/s]');
legend('Wind1VelX','REWS_b')

subplot(4,1,2);
hold on; grid on; box on
plot(FB_seed01.Time,       FB_seed01.BldPitch1);
plot(FBFF_seed01.Time,     FBFF_seed01.BldPitch1);
ylabel({'BldPitch1'; '[deg]'});
legend('feedback only','feedback-feedforward')

subplot(4,1,3);
hold on; grid on; box on
plot(FB_seed01.Time,       FB_seed01.RotSpeed);
plot(FBFF_seed01.Time,     FBFF_seed01.RotSpeed);
ylabel({'RotSpeed';'[rpm]'});

subplot(4,1,4);
hold on; grid on; box on
plot(FB_seed01.Time,       FB_seed01.TwrBsMyt/1e3);
plot(FBFF_seed01.Time,     FBFF_seed01.TwrBsMyt/1e3);
ylabel({'TwrBsMyt';'[MNm]'});

xlabel('time [s]')
linkaxes(findobj(gcf, 'Type', 'Axes'),'x');
xlim([0 660])

% seed02
figure('Name','Seed02')

subplot(4,1,1);
title('Seed02')
hold on; grid on; box on
plot(FB_seed02.Time,       FB_seed02.Wind1VelX);
plot(FBFF_seed02_R.Time,     FBFF_seed02_R.REWS_b);
ylabel('[m/s]');
legend('Wind1VelX','REWS_b')

subplot(4,1,2);
hold on; grid on; box on
plot(FB_seed02.Time,       FB_seed02.BldPitch1);
plot(FBFF_seed02.Time,     FBFF_seed02.BldPitch1);
ylabel({'BldPitch1'; '[deg]'});
legend('feedback only','feedback-feedforward')

subplot(4,1,3);
hold on; grid on; box on
plot(FB_seed02.Time,       FB_seed02.RotSpeed);
plot(FBFF_seed02.Time,     FBFF_seed02.RotSpeed);
ylabel({'RotSpeed';'[rpm]'});

subplot(4,1,4);
hold on; grid on; box on
plot(FB_seed02.Time,       FB_seed02.TwrBsMyt/1e3);
plot(FBFF_seed02.Time,     FBFF_seed02.TwrBsMyt/1e3);
ylabel({'TwrBsMyt';'[MNm]'});

xlabel('time [s]')
linkaxes(findobj(gcf, 'Type', 'Axes'),'x');
xlim([0 660])

% seed03
figure('Name','Seed03')

subplot(4,1,1);
title('Seed03')
hold on; grid on; box on
plot(FB_seed03.Time,       FB_seed03.Wind1VelX);
plot(FBFF_seed03_R.Time,     FBFF_seed03_R.REWS_b);
ylabel('[m/s]');
legend('Wind1VelX','REWS_b')

subplot(4,1,2);
hold on; grid on; box on
plot(FB_seed03.Time,       FB_seed03.BldPitch1);
plot(FBFF_seed03.Time,     FBFF_seed03.BldPitch1);
ylabel({'BldPitch1'; '[deg]'});
legend('feedback only','feedback-feedforward')

subplot(4,1,3);
hold on; grid on; box on
plot(FB_seed03.Time,       FB_seed03.RotSpeed);
plot(FBFF_seed03.Time,     FBFF_seed03.RotSpeed);
ylabel({'RotSpeed';'[rpm]'});

subplot(4,1,4);
hold on; grid on; box on
plot(FB_seed03.Time,       FB_seed03.TwrBsMyt/1e3);
plot(FBFF_seed03.Time,     FBFF_seed03.TwrBsMyt/1e3);
ylabel({'TwrBsMyt';'[MNm]'});

xlabel('time [s]')
linkaxes(findobj(gcf, 'Type', 'Axes'),'x');
xlim([0 660])