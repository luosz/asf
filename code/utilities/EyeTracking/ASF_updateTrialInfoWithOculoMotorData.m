function [updatedTrialInfo, sampleData] = ASF_updateTrialInfoWithOculoMotorData(thisTrialInfo, thisTrialInfoOculoMotor, startRTPage, nSamples, nPre)
%function [updatedTrialInfo, sampleData] = updateTrialInfoWithOculoMotorData(thisTrialInfo, thisTrialInfoOculoMotor, startRTPage, nSamples, nPre)
%%Updates TrialInfo from logfile with saccadic reaction time and a key
%%Code. Here we use a simple mapping (left 1, right 3). Users need to
%%implement their own mapping.
%%The function returns saccadic traces timelocked to the start of measuring
%%the saccadicreaction time.
%%nSamples is the number of samples returned,
%%nPre determines when with respect to the start of rt measurement to start
%%with returning samples, i.e. the prePeriod
%%The function needs to be called trial by trial
%
%%20110227 jens.schwarzbach@unitn.it
%
%%
%%EXAMPLE CALL:
%trialNo = 3;
%thisTrialInfo = ExpInfo.TrialInfo(trialNo); %ExpInfo comes from ASF's log file
%thisTrialInfoOculoMotor = TrialInfoOculoMotor(trialNo);
%%TrialInfoOculoMotor comes from parsing eyetracking data such as in
%%[results, TrialInfoOculoMotor] = ASF_EyeParseAscii('JVS_MPEH01.asc', {'MSG', 'EFIX', 'ESACC', 'EBLINK'})
%
%startRTPage = 4; %just an example; consider also startRTPage = thisTrialInfo.trial.startRTonPage;
%
%nSamples = 1000; %one second worth of data (if sampled at at 1000Hz)
%nPre = 250; %start returning samples 250ms before reactions are allowed
%[updatedTrialInfo, sampleData] = ASF_updateTrialInfoWithOculoMotorData(thisTrialInfo, thisTrialInfoOculoMotor, startRTPage, nSamples, nPre)

Cfg.doPlot = 0;
sampleData = [];
updatedTrialInfo = thisTrialInfo;
saccadeStartTimes = [thisTrialInfoOculoMotor.sacEvents.sacStart];

%WE CAN DO SOME CONSISTENCY CHECKING BETWEEN THE TIMESTAMPS FORM ASF LOG
%AND EYETRACKER HERE
t0 = thisTrialInfoOculoMotor.pageOnset(startRTPage);

%ANY SACCADE BEFORE CRITICAL PAGE?
if any(saccadeStartTimes < t0)
    %discard trial
else
    %CALCULATE SACCADIC REACTION TIME
    srt = saccadeStartTimes(1) - t0;
    updatedTrialInfo.Response.RT = srt;
    
    %CLASSIFY INTO LEFT OR RIGHT
    %WE MAY WANT TO ADD ADDITIONAL CRITERIA FOR WHAT COUNTS AS A SACCADE
    if (thisTrialInfoOculoMotor.sacEvents(1).sacPosEndX - thisTrialInfoOculoMotor.sacEvents(1).sacPosStartX) > 0
        updatedTrialInfo.Response.key = 3; %RIGHT
    else
        updatedTrialInfo.Response.key = 1;%LEFT
    end
    
    %GET GAZE TRACES
    tOnsetTrace = thisTrialInfoOculoMotor.pageOnset(startRTPage) - nPre;
    casesTrace = find(thisTrialInfoOculoMotor.samples(:, 1) >= tOnsetTrace);
    casesTrace= casesTrace(1:nSamples);
    
    t = (1:nSamples) - (nPre+1);
    sampleData = [t(:), thisTrialInfoOculoMotor.samples(casesTrace, 2), thisTrialInfoOculoMotor.samples(casesTrace, 3)];
    
    if Cfg.doPlot
        plot(sampleData(:, 1), sampleData(:, 2:3))
    end
end  

