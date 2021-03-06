function res = ASF_readExpInfo(expinfo)
%function res = ASF_readExpInfo(expinfo)

if isfield(expinfo, 'TrialInfo')
    %NEW VERSION has different field names 
    res = ASF_readExpInfoNEW(expinfo);
else
    %OLD VERSION
    res = ASF_readExpInfoOLD(expinfo);
end

function res = ASF_readExpInfoNEW(expinfo)
%function res = ASF_readExpInfo(expinfo)
%PACK DATA FROM EXPINFO INTO A MATRIX
%ROW -> trial
%COL 1: CODE
%COL 2: RT
%COL 3: KEY
%COL 4: CORRECTRESPONSE
%COL 5: EVALUATION (KEY==CORRECTRESPONSE)
nTrials = length(expinfo.TrialInfo);
if nTrials == 0
    fprintf(1, 'WARNING NO TRIALS SAVED!\n')
    res = [];
else
    res(nTrials, 3) = 0;
    for i=1:nTrials
        res(i, 1) = expinfo.TrialInfo(i).trial.code;
        thisResponse = expinfo.TrialInfo(i).Response;
        if isempty(thisResponse.RT)
            res(i, 2) = NaN;
            res(i, 3) = NaN;
        else
            res(i, 2) = thisResponse.RT(1); %MULTIPLE RESPONSES NEED SPECIAL TREATMENT JVS20130329
            if isempty(thisResponse.key)
                res(i, 3) = NaN;
            else
                res(i, 3) = thisResponse.key(1); %IF YOU WANT MULTIPLE KEYS MAKE IT A CELL
            end
        end
        res(i, 4) = expinfo.TrialInfo(i).trial.correctResponse; %REQUESTED RESPONSE
        res(i, 5) = res(i, 3) == res(i, 4);

        
%         if isfield(expinfo.TrialInfo(i), 'startRTMeasurement')
%             res(i, 5) = expinfo.TrialInfo(i).startRTMeasurement; %ABSOLUTE TIME OF START OF RT MEASUREMENT; diff(res(:, 5)) gives you trial onset asynchrony  
%         else
%             res(i, 5) = 0;
%         end
        
        %OBSOLETE, ALREADY CONTAINED IN COLUMN 3
%         if isempty(expinfo.TrialInfo(i).Response.key)
%             res(i, 6) = NaN;
%         else
%             res(i, 6) = expinfo.TrialInfo(i).Response.key;
%         end
    end
end

%old version
function res = ASF_readExpInfoOLD(expinfo)
%function res = ASF_readExpInfo(expinfo)
%PACK DATA FROM EXPINFO INTO A MATRIX
%ROW -> trial
%COL 1: CODE
%COL 2: RT
%COL 3: KEY
%COL 4: CORRECTRESPONSE
nTrials = length(expinfo.trialinfo);
if nTrials == 0
    fprintf(1, 'WARNING NO TRIALS SAVED!\n')
    res = [];
else
    res(nTrials, 3) = 0;
    for i=1:nTrials
        res(i, 1) = expinfo.trialinfo(i).trial.code;
        thisResponse = expinfo.trialinfo(i).response;
        if isempty(thisResponse.RT)
            res(i, 2) = NaN;
            res(i, 3) = NaN;
        else
            res(i, 2) = thisResponse.RT;
            if isempty(thisResponse.key)
                res(i, 3) = NaN;
            else
                res(i, 3) = thisResponse.key(1); %IF YOU WNAT MULTIPLE KEYS MAKE IT A CELL
            end
        end
        if isfield(expinfo.trialinfo(i).trial, 'CorrectResponse')
            res(i, 4) = expinfo.trialinfo(i).trial.CorrectResponse; %REQUESTED RESPONSE
        else
            res(i, 4) = NaN;
        end
    end
end