%% Setup
clearvars;close all;clc;
addpath(genpath('..\WetiMatlabFunctions'))
addpath('..\ControlTools\')

%% Setup
SimulationName = 'OPTSyria5MW';

FFPfile = 'ServoData\FFP_v1.IN';
initialStr = '1   	! T_buffer';
TbufferVals = 1.1 : 0.1 : 3.1 ;
TbufferStr  = compose("%.3f     ! T_buffer", TbufferVals);

% Cost values
RotSpeed_0  = 10;     % [rpm]
TwrBsMyt_0  = 8.0374e+04;  % [kNm] 
t_Start     = 0;        % [s]

Result = zeros(length(TbufferVals),2);

%% Run

for i=1:length(TbufferVals)

    ManipulateTXTFile(FFPfile,initialStr,TbufferStr(i));

    dos(['openfast_x64.exe ',SimulationName,'_FBFF.fst']);
    FBFF              = ReadFASTbinaryIntoStruct([SimulationName,'_FBFF.outb']);
    
    Cost_FBFF = (max(abs(FBFF.RotSpeed(FBFF.Time>=t_Start)-RotSpeed_0))) / RotSpeed_0 ...
         + (max(abs(FBFF.TwrBsMyt(FBFF.Time>=t_Start)-TwrBsMyt_0))) / TwrBsMyt_0;

    Result(i,:) = [TbufferVals(i) Cost_FBFF];

    ManipulateTXTFile(FFPfile,TbufferStr(i),initialStr);
end

%% Plot Results

figure;
hold on; grid on; box on
plot(TbufferVals,Result(:,2), "-o");
xlabel("Buffer Time [s]")
ylabel("Cost [-]")



