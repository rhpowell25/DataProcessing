% Wrapper function for assessing emg data quality - at the file level
%   loads data & computes DQ metrics
%
%   Inputs: fileName, workingFolder, metadata
%
%   Output: 
%       dq              :   dataQuality analysis structure
%       summaryTable    :   Summary of the analyses performed


function[dq, summaryTable] = DataQualityWrapperEmg(file, workingFolder, meta) 

    %[dq.labels, labelIdx, meta.frequency] = loadFile(fileName, workingFolder);
    [data, dq.labels, labelIdx, meta.frequency] = findEmgData(file, workingFolder); %use logic from CDS
    dq.monkey = meta.monkey;
    dq.date = meta.date;
    dq.file = file.name;
    
    params.signalBand = [198 402];
    params.noiseBand = [8 27];
    params.filterWindow = 1000;
    params.highPass = 10;
    params.lowPass = 300;
    params.stdDevs = 2; %defines high-amp artifact
    params.harmonicWindowSize = 8;
    params.frequency = meta.frequency;
    
    for i = 1:length(dq.labels)
    
        dataIdx = labelIdx{i};
        dq.metrics(i).rawData = data(dataIdx,:);

        [dq.metrics(i).sixtyNoise, dq.metrics(i).SNR, dq.metrics(i).baseNoise, ...
            dq.metrics(i).highAmp,dq.metrics(i).shapeScore, dq.metrics(i).Pxx, ...
            dq.metrics(i).Fxx, dq.metrics(i).normPower] = getDQMetrics(data(dataIdx,:), params);
    end
    
    dqAnalysis{1} = dq;
    summaryTable = getSummaryTable(dqAnalysis);
    
end


function summaryTable = getSummaryTable(dqAnalysis)

    %Summary of Analyzed Files
    runningIdx = 0;
    for i = 1:length(dqAnalysis)
        muscleCount = length(dqAnalysis{1,i}.metrics);   
        for j = 1:muscleCount
            idx = runningIdx + j;
            summary{idx, 1} = idx;
            summary{idx, 2} = dqAnalysis{1,i}.monkey;
            summary{idx, 3} = dqAnalysis{1,i}.labels{j};
            summary{idx, 4} = dqAnalysis{1,i}.file;
            summary{idx, 5} = dqAnalysis{1,i}.metrics(j).sixtyNoise;
            summary{idx, 6} = dqAnalysis{1,i}.metrics(j).SNR;
            summary{idx, 7} = dqAnalysis{1,i}.metrics(j).baseNoise;
            summary{idx, 8} = dqAnalysis{1,i}.metrics(j).highAmp;
            summary{idx, 9} = flagMuscle(dqAnalysis{1,i}.metrics(j));
        end
        runningIdx = runningIdx + muscleCount;
        if i == 1
            runningMuscleCount(i) = muscleCount; 
        else
            runningMuscleCount(i) = runningMuscleCount(i-1) + muscleCount;
        end
    end

    summaryTable = array2table(summary);
    summaryTable.Properties.VariableNames = {'Index', 'Monkey', 'Muscle', 'File', 'sixtyNoise', 'SNR', 'baseNoise', 'highAmp', 'flag'};

end