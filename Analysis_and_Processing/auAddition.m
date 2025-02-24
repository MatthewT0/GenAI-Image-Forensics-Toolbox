% Set paths
rootPath = pwd;
organisedPath = char(fullfile(rootPath,'OrganisedFiles'));
AumatFilesStruct = dir(fullfile(rootPath, 'Normalised', '**', 'Au', '**', '*.mat')); % Wildcard file structure for accessing Au mat files

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
