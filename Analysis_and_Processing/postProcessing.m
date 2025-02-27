function postProcessing()
    % Flags
    overwriteFlag = false; % set to True to overwrite the Output directory
    removeProcessedFiles = false; % set to true to remove Output, Normalised files when struct made
    
    % Paths
    rootPath = pwd;
    inputData = char(fullfile(rootPath, 'Output'));
    organisedPath = fullfile(rootPath, 'OrganisedFiles');
    
    % Create new directories for outputs if they don't exist
    if not(isfolder(organisedPath))
        mkdir(organisedPath);
    end

    % Run functions to normalise then organise normalised data into a struct
    disp('[*] Starting to normalise the data');
    normalisedPath = normaliseData(rootPath,inputData,overwriteFlag);
    disp('[*] Starting to add manipulated images to the organised struct');
    organiseFiles(organisedPath, normalisedPath);
    disp('[*] Starting to add authentic images to the organised struct');
    auAddition(rootPath, organisedPath, normalisedPath);

    % remove directories if option selected to remove output and normalised data on struct creation
    if removeProcessedFiles == true && overwriteFlag == true
        rmdir(normalisedPath,'s')
    elseif removeProcessedFiles == true && overwriteFlag == false
        rmdir(normalisedPath,'s')
        rmdir(inputData,'s')
    end
end

% ------------------------------------------------------------------------------------------------

function[normalisedPath]=normaliseData(rootPath, inputData, overwriteFlag)
    % Normalise the data from EvaluateAlgorithm.m and created a new "normalised" directory for them instead of overwriting the original copies.
    % The values are normalised between 0 and 1 using the min max method, 
    % and each algorithms lowest and highest values are outputted to the command window, alongside the total files processed for verification.

    % Declare paths
    AumatFilesStruct = dir(fullfile(inputData, '**', 'Au', '**', '*.mat')); % Wildcard file structure for accessing Au mat files
    SpmatFilesStruct = dir(fullfile(inputData, '**', 'Sp', '**', '*.mat')); % Wildcard file structure for accessing SP mat files
    matFilesStruct = [SpmatFilesStruct; AumatFilesStruct];

    % Checks if the program is to overwrite the output or not
    if overwriteFlag == false
        % normalised path if required
        normalisedPath = char(fullfile(rootPath, 'Normalised'));
        % makes normalised directory
        if not(isfolder(normalisedPath))
            mkdir(normalisedPath);
        end
    else
        normalisedPath = inputData;
    end

    % Initialise containers for tracking global min and max per algorithm
    algMinMax = containers.Map('KeyType', 'char', 'ValueType', 'any');
    counter = 0; % Total number of files processed

    % Process all the files to identify the global min and max per algorithm
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


    % Normalise all files and add the associated BinMask
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

            % for each algorithm check file path,
            % delete if already exists and replace with new normalised files 
            outputFilePath = fullfile(normalisedPath, algorithmName, type, class);
            if not(isfolder(outputFilePath))
                mkdir(outputFilePath); % Ensure output directory exists
            elseif isfolder(outputFilePath) && overwriteFlag == true
                delete(fullfile(outputFilePath, splitPath{end})) % remove the output dir and files
            end
            save(fullfile(outputFilePath, splitPath{end}), 'normalisedResult', 'BinMask'); % Save normalised data and BinMask
        end
    end
end

% ------------------------------------------------------------------------------------------------

function organiseFiles(organisedPath, normalisedPath)
    % organises files by creating a structured dataset (struct)
    % that includes the key information such as filename, class, tool, 
    % normalised evaluation results, and other data required for result analysis.

    % Declare paths
    SpmatFilesStruct = dir(fullfile(normalisedPath, '**', 'Sp', '**', '*.mat')); % Wildcard file structure for accessing SP mat files

    % Initialise empty container template for dataset-specific structs
    datasetStructTemplate = struct('FileName', {}, 'Class', {}, 'Tool', {}, 'Num', {}, 'Iteration', {}, ...
                                'NormalisedResult', {}, 'RealImg', {}, 'RealResult', {}, 'Binmask', {});
    
    % loop through each file and add it to the struct
    for j = 1:length(SpmatFilesStruct)
        matFilePath = fullfile(SpmatFilesStruct(j).folder, SpmatFilesStruct(j).name);
        data = load(matFilePath); % Load the .mat file
        %disp(matFilePath);
    
        % Extract the dataset (algorithm) name from the folder structure
        % Assuming the structure is: Normalised\DatasetName+Alg\Sp\CategoryName\File.mat
        splitPath = strsplit(matFilePath, filesep);
        datasetAlgName = splitPath{end-3}; % Algorithm folder (e.g., DatasetADQ1)
        CategoryName = splitPath{end-1};
        type = splitPath{end-2}; % Sp or Au folder
        filename = splitPath{end};
        
        % Define save path for the current dataset
        savePath = fullfile(organisedPath, strcat(datasetAlgName, '.mat'));
    
        % Load existing dataset file if it exists
        if isfile(savePath)
            loadedData = load(savePath);
            currentDataset = loadedData.currentDataset;
        else
            currentDataset = datasetStructTemplate; 
        end
    
        % Parse SP file components
        splitFile = strsplit(filename, '_');
        tool = splitFile{1};
        class = splitFile{2};
        num = splitFile{4};
        iterationSplit = strsplit(splitFile{5}, '.');
        iteration = iterationSplit{1};

        % Extract data from SP file
        normalisedResult = data.normalisedResult; 
        binmask = data.BinMask; 
        realImgName = strcat('real_', num, '.jpg');

        % Append entry to the dataset
        newEntry = struct('FileName', filename, 'Class', class, 'Tool', tool, ...
                        'Num', num, 'Iteration', iteration, ...
                        'NormalisedResult', normalisedResult, ...
                        'RealImg', realImgName, 'RealResult', [], 'Binmask', binmask);
        currentDataset = [currentDataset; newEntry];
        % Save the updated dataset to file
        save(savePath, 'currentDataset', '-v7.3');
    end
end

% ------------------------------------------------------------------------------------------------

function auAddition(organisedPath, normalisedPath)
    % Adds authentic reference data into the structured dataset (struct)

    % Declare paths
    AumatFilesStruct = dir(fullfile(normalisedPath, '**', 'Au', '**', '*.mat')); % Wildcard file structure for accessing Au mat files

    % Loop through authentic images and add to struct
    for j = 1:length(AumatFilesStruct)
        % Load the current Au .mat file
        matFilePath = fullfile(AumatFilesStruct(j).folder, AumatFilesStruct(j).name);
        data = load(matFilePath); 
        realResult = data.normalisedResult;
        %disp(matFilePath);
    
        % Extract the dataset (algorithm) name from the folder structure
        splitPath = strsplit(matFilePath, filesep);
        datasetAlgName = splitPath{end-3}; % Algorithm folder (e.g., DatasetADQ1)
        CategoryName = splitPath{end-1};
        type = splitPath{end-2}; % Sp or Au folder
        realFileName = splitPath{end}; % Filename of the current real file
        realFileName = erase(realFileName, '.mat'); % Remove .mat extension
        
        % Load the corresponding dataset file (e.g., DatasetADQ1.mat)
        savePath = fullfile(organisedPath, strcat(datasetAlgName, '.mat'));
        loadedData = load(savePath); % Load the dataset .mat file
        currentDataset = loadedData.currentDataset; % Extract the dataset struct
        
        % Loop through the dataset and update realResult where matching
        for k = 1:length(currentDataset)
            % Check if CategoryName and realFileName match
            if strcmp(currentDataset(k).Class, CategoryName) && strcmp(currentDataset(k).RealImg, realFileName)
                currentDataset(k).RealResult = realResult; % Add realResult to the field
            end
        end
        
        % Save the updated dataset back to the .mat file
        save(savePath, 'currentDataset', '-v7.3');
    end
end