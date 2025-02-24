% Set paths
rootPath = pwd;
organisedPath = char(fullfile(rootPath,'OrganisedFiles'));
analysisPath = char(fullfile(organisedPath, 'Threshold'));

% Ensure the analysis directory exists
if ~exist(analysisPath, 'dir')
    mkdir(analysisPath);
end

% Get all .mat files in the OrganisedFiles directory
organisedFilesStruct = dir(fullfile(organisedPath, '*.mat'));

% Loop through each .mat file
for i = 1:length(organisedFilesStruct)
    % Load the .mat file
    matFilePath = fullfile(organisedFilesStruct(i).folder, organisedFilesStruct(i).name);
    loadedData = load(matFilePath);
    currentDataset = loadedData.currentDataset;
    
    % Display the file being processed
    disp(['Processing file: ', organisedFilesStruct(i).name]);
    
    analysisResults = struct('FileName', {}, 'Class', {}, 'Tool', {}, ...
                              'Num', {}, 'Iteration', {}, 'MeanNR', {}, ...
                              'MedianNR', {}, 'RealImg', {}, ...
                              'MeanRR', {}, 'MedianRR', {}, ...
                              'ThreshName', {}, 'ThreshValue', {}, 'ThreshResult', {}, ...
                              'TP', {}, 'TN', {}, 'FP', {}, 'FN', {});

    % Loop through each row of the struct
    for j = 1:length(currentDataset)
        % Access each field of the struct
        row = currentDataset(j);
        
        % set same values
        analysisResults(j).FileName = row.FileName;
        analysisResults(j).Class = row.Class;
        analysisResults(j).Tool = row.Tool;
        analysisResults(j).Num = row.Num;
        analysisResults(j).Iteration = row.Iteration;        
        analysisResults(j).RealImg = row.RealImg;
        
        % temp read in values
        NormalisedResult = row.NormalisedResult;
        RealResult = row.RealResult;
        Binmask = row.Binmask;
        
        % resize result map
        resizedDataNR = imresize(NormalisedResult, size(Binmask), 'nearest'); 
        resizedDataAR= imresize(RealResult, size(Binmask), 'nearest');
        
        % Calculate Mean and Median of the double values not resized
        MeanNR = mean(NormalisedResult(:)); 
        MedianNR = median(NormalisedResult(:)); 
        MeanRR = mean(RealResult(:));
        MedianRR = median(RealResult(:));
        
        Thresh = resizedDataAR;
        % Threshold the resized Result map
        ThresholdedResult = resizedDataNR >= Thresh;

        % Total values
        totalValues = numel(Binmask);
            
        % Calculate the Values
        TP = sum((ThresholdedResult == 1) & (Binmask == 1), 'all');
        TN = sum((ThresholdedResult == 0) & (Binmask == 0), 'all');
        FP = sum((ThresholdedResult == 1) & (Binmask == 0), 'all');
        FN = sum((ThresholdedResult == 0) & (Binmask == 1), 'all');
    
        % Calculate the Values as percents
        TPperc = TP/totalValues * 100;
        TNperc = TN/totalValues * 100;
        FPperc = FP/totalValues * 100;
        FNperc = FN/totalValues * 100;
              
        % Add new values in 
        analysisResults(j).MeanNR = MeanNR;
        analysisResults(j).MedianNR = MedianNR;
        analysisResults(j).MeanRR = MeanRR;
        analysisResults(j).MedianRR = MedianRR;
        analysisResults(j).ThreshName = 'ThreshAR';
        analysisResults(j).ThreshValue = Thresh';
        analysisResults(j).ThreshResult = ThresholdedResult;
        analysisResults(j).TP = TPperc;
        analysisResults(j).TN = TNperc;
        analysisResults(j).FP = FPperc;
        analysisResults(j).FN = FNperc;

    end
    
    % Save the results to the Analysis directory
    saveFileName = fullfile(analysisPath, organisedFilesStruct(i).name);
    save(saveFileName, 'analysisResults', '-v7.3');
    
    % Display save confirmation
    disp(['Saved analysis results to: ', saveFileName]);
end
