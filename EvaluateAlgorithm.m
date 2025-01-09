clear all;
addpath(['.' filesep 'Util' filesep]);
addpath(['.' filesep 'Util/jpeg_toolbox' filesep])
addpath(['.' filesep 'Util/jpeg_toolbox/jpegtbx_1.4' filesep]);

% File Paths:
rootPath='C:\Users\User\Documents\1-Github\GenAI-Image-Forensics-Toolbox\';
Options.SplicedPath=char(fullfile(rootPath, 'Dataset','Tampered\'));
Options.AuthenticPath=char(fullfile(rootPath, 'Dataset','Authentic\'));
Options.MasksPath=char(fullfile(rootPath, 'Dataset', 'Masks\'));
Options.OutputPath=char(fullfile(rootPath, 'Output\'));

% Aditional options:
% This mask dictates option three of the masks, detailed in the README 
one_mask = true; %True if one mask for multiple images. False if not
% The name of the dataset. Only used for naming the output folders, does not
% have to correspond to an existing path.
Options.DatasetName='Dataset';
Options.ValidExtensions={'*.jpg','*.jpeg','*.png'};

algorithmNames = {'ADQ1', 'ADQ2', 'ADQ3', 'BLK', 'CAGI', 'CFA1', ... % option to run all
                'CFA3', 'DCT', 'ELA', 'NADQ', ...
                'NOI1','NOI4', 'NOI5'}; 

%  This is where program starts, you shouldn't need to edit anything below this line unless you are modifying/adapting the code for other purposes
% -----------------------------------------------------------------------------------------------------------------------------------

% loop through all algorithms
for i = 1:length(algorithmNames)
    % Set Options.AlgorithmName to the current algorithm
    Options.AlgorithmName = algorithmNames{i};
    
    %Run the algorithm for each image in the dataset and save the results
    ExtractMaps(Options,one_mask);

    %Estimate the output map statistics for each image, and gather them in one
    %list, then estimate the TP-FP curves
    Curves=CollectMapStatistics(Options);

    % Compact results to a visualisable output
    PresentationCurves.Means=CompactCurve(Curves.MedianPositives,Curves.MeanThreshValues);
    PresentationCurves.Medians=CompactCurve(Curves.MedianPositives,Curves.MedianThreshValues);
    PresentationCurves.KS=CompactCurve(Curves.KSPositives,0:1/(size(Curves.KSPositives,2)-1):1);

    % Plot KS Statistic curve
    figure(i); % Opens a new figure window for each algorithm
    plot(PresentationCurves.KS(2,:),PresentationCurves.KS(3,:));
    axis([0 0.5 0 1]);
    xlabel('False Positives');
    ylabel('True Positives');
    title(['KS Statistic:' Options.AlgorithmName ' ' Options.DatasetName]);

    % Display True Positives at 5% False Positives
    Values05=PresentationCurves.KS(3,PresentationCurves.KS(2,:)>=0.05);
    TP_at_05=Values05(end);
    disp(['True Positives at 5% False Positives: ' num2str(TP_at_05*100) '%']);
    
end

% Remove paths only once after processing all algorithms
rmpath(['.' filesep 'Util/jpegtbx_1.4' filesep]);
rmpath(['.' filesep 'Util' filesep]);

