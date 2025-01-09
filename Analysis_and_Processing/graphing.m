% paths and starting variable declarations
rootPath = 'C:\Users\User\Documents\1-Github\GenAI-Image-Forensics-Toolbox\';
organisedPath = char(fullfile(rootPath, 'OrganisedFiles'));
thresholdDirs = {'Threshold'};
outputPath = char(fullfile(organisedPath, 'Graphing\'));

% Ensure the output directory exists
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

% Loop through each threshold directory
for t = 1:length(thresholdDirs)
    thresholdPath = fullfile(organisedPath, thresholdDirs{t});
    thresholdName = thresholdDirs{t};
    
    % Get all .mat files in the current threshold directory
    thresholdFilesStruct = dir(fullfile(thresholdPath, '*.mat'));
    
    % set up structure for statistics
    OverallAlgStats = struct('Algorithm', [], 'MeanNR', [], 'MedianNR', [], ...
                                'MeanRR', [], 'MedianRR', [], ...                              
                                'MeanTP', [], 'MeanTN', [], 'MeanFP', [], 'MeanFN', []);

    % Structure Setup
    OverarchingStruct = struct('Baseline', [], 'Classes', struct());
    classes = {'Animals', 'Objects', 'Person', 'Scenery'};

    % Initialise class-specific structures
    for classNum = 1:length(classes)
         OverarchingStruct.Classes.(classes{classNum}) = OverallAlgStats;
    end
    
    for i = 1:length(thresholdFilesStruct)
        % Load the .mat file
        matFilePath = fullfile(thresholdFilesStruct(i).folder, thresholdFilesStruct(i).name);
        loadedData = load(matFilePath);
        thresholdFile = loadedData.analysisResults;
        Alg = thresholdFilesStruct(i).name;
        
        % display to monitor its working
        disp(matFilePath);
        disp(Alg)

        % calculate baseline stats
        BaselineAlgMeanNR = mean([thresholdFile.MeanNR]);
        BaselineAlgMedianNR = median([thresholdFile.MedianNR]);
        BaselineAlgMeanRR = mean([thresholdFile.MeanRR]);
        BaselineAlgMedianRR =median([thresholdFile.MedianRR]);
        BaselineAlgMeanTP = mean([thresholdFile.TP]);
        BaselineAlgMeanTN = mean([thresholdFile.TN]);
        BaselineAlgMeanFP = mean([thresholdFile.FP]);
        BaselineAlgMeanFN = mean([thresholdFile.FN]);
        
        % set baseline stats
        OverarchingStruct.Baseline(i).Algorithm = Alg;
        OverarchingStruct.Baseline(i).MeanNR = BaselineAlgMeanNR;
        OverarchingStruct.Baseline(i).MedianNR = BaselineAlgMedianNR;
        OverarchingStruct.Baseline(i).MeanRR = BaselineAlgMeanRR;
        OverarchingStruct.Baseline(i).MedianRR = BaselineAlgMedianRR;
        OverarchingStruct.Baseline(i).MeanTP = BaselineAlgMeanTP;
        OverarchingStruct.Baseline(i).MeanTN = BaselineAlgMeanTN;
        OverarchingStruct.Baseline(i).MeanFP = BaselineAlgMeanFP;
        OverarchingStruct.Baseline(i).MeanFN = BaselineAlgMeanFN;
        
        % loop through the classes
        for classNum = 1:length(classes)
            currentClass = classes{classNum};

            % Filter rows by the current class
            classRows = strcmp({thresholdFile.Class}, currentClass);
            temp = thresholdFile(classRows);
            % if any of the rows in classes
            if any(classRows)
                % Compute class-specific stats
                classMeanNR = mean([thresholdFile(classRows).MeanNR]);
                classMedianNR = median([thresholdFile(classRows).MedianNR]);
                classMeanRR = mean([thresholdFile(classRows).MeanRR]);
                classMedianRR = median([thresholdFile(classRows).MedianRR]);
                classMeanTP = mean([thresholdFile(classRows).TP]);
                classMeanTN = mean([thresholdFile(classRows).TN]);
                classMeanFP = mean([thresholdFile(classRows).FP]);
                classMeanFN = mean([thresholdFile(classRows).FN]);
                
                % Update class-specific structure
                OverarchingStruct.Classes.(currentClass)(i).Algorithm = Alg;
                OverarchingStruct.Classes.(currentClass)(i).MeanNR = classMeanNR;
                OverarchingStruct.Classes.(currentClass)(i).MedianNR = classMedianNR;
                OverarchingStruct.Classes.(currentClass)(i).MeanRR = classMeanRR;
                OverarchingStruct.Classes.(currentClass)(i).MedianRR = classMedianRR;
                OverarchingStruct.Classes.(currentClass)(i).MeanTP = classMeanTP;
                OverarchingStruct.Classes.(currentClass)(i).MeanTN = classMeanTN;
                OverarchingStruct.Classes.(currentClass)(i).MeanFP = classMeanFP;
                OverarchingStruct.Classes.(currentClass)(i).MeanFN = classMeanFN;
            end
        end
    end

    % Save the results to the Analysis directory
    saveFileName = fullfile(outputPath, thresholdName);
    disp(saveFileName);
    save(saveFileName, 'OverarchingStruct', '-v7.3');

end
