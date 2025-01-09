function ExtractMaps( Options, one_mask)
    AlgorithmName=Options.AlgorithmName;
    DatasetName=Options.DatasetName;
    SplicedPath=Options.SplicedPath;
    AuthenticPath=Options.AuthenticPath;
    MasksPath=Options.MasksPath;
    
    SplicedOutputPath=[Options.OutputPath DatasetName AlgorithmName filesep 'Sp' filesep];
    AuthenticOutputPath=[Options.OutputPath DatasetName AlgorithmName filesep 'Au' filesep];
    ValidExtensions=Options.ValidExtensions;
    
    SplicedList={};
    AuthenticList={};

    for Ext=1:length(ValidExtensions)
        SplicedList=[SplicedList;getAllFiles(SplicedPath,ValidExtensions{Ext},true)];
        AuthenticList=[AuthenticList;getAllFiles(AuthenticPath,ValidExtensions{Ext},true)];
    end
    warning('off','MATLAB:MKDIR:DirectoryExists');

    addpath(['.' filesep 'Algorithms' filesep AlgorithmName]);
    for FileInd=1:length(SplicedList)
        OutputFile=[strrep(SplicedList{FileInd},SplicedPath,SplicedOutputPath) '.mat'];
        % If the .mat file already exists, skip it. This allows for partial
        % batch extraction. Remove if you intend to overwrite existing files
        if ~exist(OutputFile,'file')
            Result=analyze(SplicedList{FileInd});
            [~,InputName,~]=fileparts(SplicedList{FileInd});
            BinMaskPath=dir([MasksPath InputName '.*']);

            % Mask option 1: One mask covering multiple files with same index number
            % add an option of one mask for multiple files and query based on gen or inpaint
            if one_mask == true
                % split the file name by its defined syntax properties
                properties = regexp(InputName, '_', 'split');
                classes = properties{2}; 
                manip = properties{3}; % either gen or inpaint
                num = properties{4}; % NumID, aka the x from 'x_y'
                
                ClassPath = fullfile(MasksPath, classes, filesep); % amended path for classes

                % check the manipulation type to determine if mask is 100% or a provided image
                if strcmp(manip, 'gen')
                    % Set BinMask to all 1s if manipulation type is 'gen'
                    currentImage = imread(SplicedList{FileInd});
                    [imageHeight, imageWidth, ~] = size(currentImage);
                    BinMask = true(imageHeight, imageWidth); % Set BinMask to all 1s
                    
                elseif strcmp(manip, 'inpaint')
                    BinMaskPath = dir([ClassPath 'real_mask_' num2str(num) '.*']);
                    % remainder of if statement is taken form the other if statements
                    Mask=mean(double(imread([ClassPath BinMaskPath.name])),3);
                    MaskMin=min(Mask(:));
                    MaskMax=max(Mask(:));
                    MaskThresh=MaskMin+MaskMax/2;
                    BinMask=Mask>MaskThresh;
                    
                    % Resizing masks to images
                    % Retrieve the resolution of the current spliced/tampered image
                    currentImage = imread(SplicedList{FileInd});
                    [imageHeight, imageWidth, ~] = size(currentImage);

                    % Resize mask to match the current image dimensions
                    BinMask = imresize(BinMask, [imageHeight, imageWidth], 'nearest');
                    
                end

            % Mask option 2:
            % one option is to have one mask per file with the same name and
            %possibly different extension
            elseif ~isempty(BinMaskPath)
                Mask=mean(double(imread([MasksPath BinMaskPath.name])),3);
                MaskMin=min(Mask(:));
                MaskMax=max(Mask(:));
                MaskThresh=MaskMin+MaskMax/2;
                BinMask=Mask>MaskThresh;
            else
                % Mask option 3:
                % the other is to have one mask in the entire folder, corresponding to
                %the entire dataset (such as the synthetic dataset of Fontani et al.)
                %make it a .png
                BinMaskPath=dir([MasksPath '*.png']);
                if length(BinMaskPath)>1
                    error('Something is wrong with the masks');
                else
                    Mask=mean(double(CleanUpImage([MasksPath BinMaskPath(1).name])),3);
                    MaskMin=min(Mask(:));
                    MaskMax=max(Mask(:));
                    MaskThresh=MaskMin+MaskMax/2;
                    BinMask=Mask>MaskThresh;
                end
            end
            [OutputPath,~,~]=fileparts(OutputFile);
            mkdir(OutputPath);
            save(OutputFile,'Result','AlgorithmName','BinMask','-v7.3');
        end
    end
    
    % the ground truth mask for positive examples is taken from the root,
    % currently the square used in Fontani et al.
    BinMask=mean(double(CleanUpImage('PositivesMask.png')),3)>128;
    for FileInd=1:length(AuthenticList)
        OutputFile=[strrep(AuthenticList{FileInd},AuthenticPath,AuthenticOutputPath) '.mat'];
        % If the .mat file already exists, skip it. This allows for partial
        % batch extraction. Remove if you intend to overwrite existing files
        if ~exist(OutputFile,'file')
            Result=analyze(AuthenticList{FileInd});
            [Path,~,~]=fileparts(OutputFile);
            mkdir(Path);
            save(OutputFile,'Result','AlgorithmName','BinMask','-v7.3');
        end
    end
    
    warning('on','all');
    rmpath(['.' filesep 'Algorithms' filesep AlgorithmName]);
end