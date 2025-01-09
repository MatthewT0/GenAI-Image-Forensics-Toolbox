% Paths
rootPath = 'C:\Users\User\Documents\1-Github\GenAI-Image-Forensics-Toolbox\';
normalisedPath = char(fullfile(rootPath, 'Normalised'));
outputPath = char(fullfile(rootPath, 'Output'));

AumatFilesStruct = dir(fullfile(outputPath, '**', 'Au', '**', '*.mat')); % Wildcard file structure for accessing Au mat files
SpmatFilesStruct = dir(fullfile(outputPath, '**', 'Sp', '**', '*.mat')); % Wildcard file structure for accessing SP mat files
matFilesStruct = [SpmatFilesStruct; AumatFilesStruct];

% Create a new directory for normalised outputs
if ~exist(normalisedPath, 'dir')
    mkdir(normalisedPath);
end

% Initialise containers for tracking global min and max per algorithm
algMinMax = containers.Map('KeyType', 'char', 'ValueType', 'any');
counter = 0; % Total number of files processed

% Part 1: Process all files
for j = 1:length(matFilesStruct)
    matFilePath = fullfile(matFilesStruct(j).folder, matFilesStruct(j).name);
    data = load(matFilePath, 'Result'); % Load the .mat file
    
    % Extract the dataset (algorithm) name from the folder structure
    splitPath = strsplit(matFilePath, filesep);
    algorithmName = splitPath{end-3}; % Algorithm folder (e.g., DatasetADQ1) 
    
    % Ensure the Result field exists
    if isfield(data, 'Result')
        currentMin = min(data.Result(:)); % Find min in current file
        currentMax = max(data.Result(:)); % Find max in current file
        
        % Check if the algorithm already has an entry
        if isKey(algMinMax, algorithmName)
            % Update the global min and max for this algorithm
            minMaxValues = algMinMax(algorithmName); % Retrieve current values
            globalMin = min(minMaxValues(1), currentMin); % Update min
            globalMax = max(minMaxValues(2), currentMax); % Update max
            algMinMax(algorithmName) = [globalMin, globalMax]; % Save updated values
        else
            % Add new entry with current min and max
            algMinMax(algorithmName) = [currentMin, currentMax];
        end
    end
    
    % Increment the total file counter
    counter = counter + 1;
end

% Display the results
disp('Algorithm-wise global min and max values:');
keys = algMinMax.keys;
for k = 1:length(keys)
    algorithmName = keys{k};
    values = algMinMax(algorithmName);
    fprintf('%s: Min = %.8f, Max = %.8f\n', algorithmName, values(1), values(2));
end
disp(['Total number of files processed: ', num2str(counter)]);

% Part 2: Normalise all files and add BinMask
for j = 1:length(matFilesStruct)
    matFilePath = fullfile(matFilesStruct(j).folder, matFilesStruct(j).name);
    data = load(matFilePath, 'Result', 'BinMask'); % Load the .mat file with BinMask
    
    % Extract the dataset (algorithm) name from the folder structure
    splitPath = strsplit(matFilePath, filesep);
    algorithmName = splitPath{end-3}; % Algorithm folder (e.g., DatasetADQ1)
    type = splitPath{end-2}; % au or sp

    if  strcmp(type, 'Au')
        class = splitPath{end-1};
    elseif strcmp(type, 'Sp')
        fullFilename = splitPath{end};
        filename = strsplit(fullFilename, '_');
        class = filename{2};
    end

    % Retrieve the global min and max for this algorithm
    if isKey(algMinMax, algorithmName)
        minMaxValues = algMinMax(algorithmName);
        globalMin = minMaxValues(1);
        globalMax = minMaxValues(2);
        
        % Normalise the `Result` field
        if isfield(data, 'Result')
            normalisedResult = (data.Result - globalMin) / (globalMax - globalMin);
        end
        
        % Ensure BinMask exists (create if missing)
        if ~isfield(data, 'BinMask')
            % Define a default BinMask if not present in the input file
            BinMask = ones(size(data.Result)); % Example: default to a matrix of ones
        else
            BinMask = data.BinMask;
        end
        
        % Save the normalised result and BinMask to the new directory
        outputFilePath = fullfile(normalisedPath, algorithmName, type, class);
        if ~exist(outputFilePath, 'dir')
            mkdir(outputFilePath); % Ensure output directory exists
        end
        save(fullfile(outputFilePath, splitPath{end}), 'normalisedResult', 'BinMask'); % Save normalised data and BinMask
    end
end
