% paths and starting variable declarations
rootPath = pwd;
organisedPath = char(fullfile(rootPath, 'OrganisedFiles'));
thresholdDirs = {'Threshold'};
outputPath = char(fullfile(organisedPath, 'Graphing'));

% Ensure the output directory exists
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

for t = 1:length(thresholdDirs)
    thresholdPath = fullfile(organisedPath, thresholdDirs{t});
    thresholdName = thresholdDirs{t};
    
    thresholdFilesStruct = dir(fullfile(thresholdPath, '*.mat'));
    
    OverallAlgStats = struct('Algorithm', [], 'MeanNR', [], 'MedianNR', [], ...
                             'MeanRR', [], 'MedianRR', [], ...
                             'MeanTP', [], 'MeanTN', [], 'MeanFP', [], 'MeanFN', []);
    
    % initialise struct
    OverarchingStruct = struct('Baseline', [], 'Classes', struct());
    classes = {'Animals', 'Objects', 'Person', 'Scenery'};

    for classNum = 1:length(classes)
        OverarchingStruct.Classes.(classes{classNum}) = OverallAlgStats;
    end  

    for i = 1:length(thresholdFilesStruct)
        matFilePath = fullfile(thresholdFilesStruct(i).folder, thresholdFilesStruct(i).name);
        loadedData = load(matFilePath);
        thresholdFile = loadedData.analysisResults;
        Alg = thresholdFilesStruct(i).name;

        % Calculate baseline stats
        BaselineAlgMeanNR = mean([thresholdFile.MeanNR]);
        BaselineAlgMedianNR = median([thresholdFile.MedianNR]);
        BaselineAlgMeanRR = mean([thresholdFile.MeanRR]);
        BaselineAlgMedianRR = median([thresholdFile.MedianRR]);
        BaselineAlgMeanTP = mean([thresholdFile.TP]);
        BaselineAlgMeanTN = mean([thresholdFile.TN]);
        BaselineAlgMeanFP = mean([thresholdFile.FP]);
        BaselineAlgMeanFN = mean([thresholdFile.FN]);
        
        OverarchingStruct.Baseline(i).Algorithm = Alg;
        OverarchingStruct.Baseline(i).MeanNR = BaselineAlgMeanNR;
        OverarchingStruct.Baseline(i).MedianNR = BaselineAlgMedianNR;
        OverarchingStruct.Baseline(i).MeanRR = BaselineAlgMeanRR;
        OverarchingStruct.Baseline(i).MedianRR = BaselineAlgMedianRR;
        OverarchingStruct.Baseline(i).MeanTP = BaselineAlgMeanTP;
        OverarchingStruct.Baseline(i).MeanTN = BaselineAlgMeanTN;
        OverarchingStruct.Baseline(i).MeanFP = BaselineAlgMeanFP;
        OverarchingStruct.Baseline(i).MeanFN = BaselineAlgMeanFN;

        % Loop through classes
        for classNum = 1:length(classes)
            currentClass = classes{classNum};
            classRows = strcmp({thresholdFile.Class}, currentClass);

            if any(classRows)
                classMeanNR = mean([thresholdFile(classRows).MeanNR]);
                classMedianNR = median([thresholdFile(classRows).MedianNR]);
                classMeanRR = mean([thresholdFile(classRows).MeanRR]);
                classMedianRR = median([thresholdFile(classRows).MedianRR]);
                classMeanTP = mean([thresholdFile(classRows).TP]);
                classMeanTN = mean([thresholdFile(classRows).TN]);
                classMeanFP = mean([thresholdFile(classRows).FP]);
                classMeanFN = mean([thresholdFile(classRows).FN]);
                
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

    % Convert baseline stats to table and write to Excel
    baselineTable = struct2table(OverarchingStruct.Baseline);
    excelFileName = fullfile(outputPath, [thresholdName, '_Results.xlsx']);
    writetable(baselineTable, excelFileName, 'Sheet', 'Baseline');
    
    % Convert each class stats to table and write to Excel
    for Num = 1:length(classes)
        currentCat = classes{Num};
        catStruct = OverarchingStruct.Classes.(currentCat);
        
        % Ensure the struct is not empty before converting to table
        if ~isempty([catStruct.Algorithm])
            catTable = struct2table(catStruct);
            writetable(catTable, excelFileName, 'Sheet', currentCat);
        end
    end
    
    disp(['Results saved to Excel file: ', excelFileName]);
end
