% Paths
rootPath= pwd;
SpmatFilesStruct = dir(fullfile(rootPath, 'Normalised', '**', 'Sp', '**', '*.mat')); % Wildcard file structure for accessing SP mat files
organisedPath = fullfile(rootPath, 'OrganisedFiles');

% Create directory if it doesn't exist
if ~exist(organisedPath, 'dir')
    mkdir(organisedPath);
end

% Initialise empty container template for dataset-specific structs
datasetStructTemplate = struct('FileName', {}, 'Class', {}, 'Tool', {}, 'Num', {}, 'Iteration', {}, ...
                            'NormalisedResult', {}, 'RealImg', {}, 'RealResult', {}, 'Binmask', {});

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

    if strcmp(type, 'Sp')
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
    end
    % Save the updated dataset to file
    save(savePath, 'currentDataset', '-v7.3');
end
