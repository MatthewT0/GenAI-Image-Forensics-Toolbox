# Developer Guidelines <!-- omit from toc -->

This is preliminary code which will likely change in future updates, including the merge of multiple post-processing and evaluation scripts.

The base code was primarily adapted from the [Image Forensics Toolbox](https://github.com/MKLab-ITI/image-forensics/blob/master/matlab_toolbox/), and individual citations for each algorithm can be found within the corresponding algorithm directories readme.  
This code was amended, written, and tested using MATLAB R2024a and MATLAB R2024b in both Windows 10 and 11.

## Table of Contents <!-- omit from toc -->
- [Implementing new algorithms and base code framework information](#implementing-new-algorithms-and-base-code-framework-information)
- [Different Directory Structure Implementation](#different-directory-structure-implementation)
  - [postProcessing.m](#postprocessingm)
- [Changing what Algorithms to Run](#changing-what-algorithms-to-run)
  - [TruFor integration](#trufor-integration)
- [Graphing different subdirectory splits](#graphing-different-subdirectory-splits)
  - [graphing.m changes](#graphingm-changes)
  - [graphingExcel.m changes](#graphingexcelm-changes)

## Implementing new algorithms and base code framework information
For new algorithm implementation and further information on the base code framework (Algorithms folder and all .m scripts in the root directory) refer to the [Original Repository README](Original_Repo_Readme.md). 

## Different Directory Structure Implementation
If you are not using subfolders in your tampered images some code may need to be amended. The code modifications and files in which these need to take place can be found below. 
### postProcessing.m
Line 33 and 34 should be replaced with the no subfolder version, removing the wildcard for further directory indentation after Sp/Au:
```Matlab
AumatFilesStruct = dir(fullfile(outputPath, '**', 'Au', '*.mat')); 
SpmatFilesStruct = dir(fullfile(outputPath, '**', 'Sp', '*.mat')); 
``` 

Line 139 should be replaced with the no subfolder version, removing the wildcard for further directory indentation after Sp:
```Matlab
SpmatFilesStruct = dir(fullfile(outputPath, '**', 'Sp', '*.mat')); 
``` 

Lines 154, 156, and 157 may need to be changed depending on your directory structure. Only the number index should need changed on these lines of code.

Line 202 should be replaced with the no subfolder version, removing the wildcard for further directory indentation after Au:
```Matlab
AumatFilesStruct = dir(fullfile(outputPath, '**', 'Au', '*.mat')); 
``` 

Lines 214, 215, and 216 may need to be changed depending on your directory structure. Only the number index should need changed on these lines of code.


## Changing what Algorithms to Run
The name of the algorithm must be the name of a subdirectory in `./Algorithms`.

This code will automatically run on 13 localisation algorithms. However this can be modified to run whatever number of algorithms you want to.

Due to the majority of these localisation algorithms being created for jpegs, using another file type wont work. If you are running the code on pngs, use the reduced algorithm list below:
```matlab
algorithmNames = {'ADQ1', 'BLK', 'CAGI', 'CFA1', ... 
                'CFA3', 'DCT', 'ELA', ...
                'NOI1','NOI4', 'NOI5'}; 
```

The algorithms 'CFA2', 'NOI2', and'GHO' were not used for this experiment and will require further implementation to run. 

### TruFor integration
If you want to run the TruFor integration you will first need to download the relevant weights file for the model and set up your python environment in MATLAB. 
The weights file can be found at: https://www.grip.unina.it/download/prog/TruFor/TruFor_weights.zip and the .pth.tar should be placed in the TruFor directory `weights`.
**Note:** If this link no longer works, refer to the original repo's Dockerfile for an updated link.

To set your python environment inside matlab find your python.exe and add it using the following command in the MATLAB terminal:
```powershell
pyenv('Version', 'C:\Path\to\Python\Python3xx\python.exe');
```
**Note:** MATLAB currently only supports up to Python version 3.12. See [MATLAB Python Documentation](https://uk.mathworks.com/support/requirements/python-compatibility.html) for more details.

The original TruFor README file can be found in the `Algorithms/TruFor` directory, which will be able to provide you with more information on its functionality.  
An analyze.m and run_trufor.m script were added to enable its implementation within this framework/toolbox, and the trufor_test.py was modified to provide the correct output.

## Graphing different subdirectory splits
This code was used for processing tool splits as well as the initial class splits. The code will require some modification for this to be possible, and the changes can be applied to other required splits for image analysis. The breakdown will show how to modify the code for tool use, but the same changes can be implemented for other splits.

Refer to the relevant section for the graphing method you want to modify whether the [graphing.m](#graphingm-changes) for the .mat output, or the [graphingExcel.m](#graphingexcelm-changes) for the xlsx output.

### graphing.m changes
Lines 26 and 27 where the overarching structure is set up should be replaced to the following structure:
```matlab
OverarchingStruct = struct('Baseline', [], 'Tool', struct());
tools = {'GLIDE','GalaxyAI','Photoshop'};
```

In lines 30 - 32 where the structure is initialised with blank values, this should be replaced with the following lines of code:
```matlab
for toolNum = 1:length(tools)
    OverarchingStruct.Tool.(tools{toolNum}) = OverallAlgStats;
end
```
Lines 67 - 96 should be changed to match the new variable names, for example:
```matlab 
% loop through the tools
for toolNum = 1:length(tools)
    currentTool = tools{toolNum};

    % Filter rows by the current tool
    toolRows = strcmp({thresholdFile.Tool}, currentTool);     
            
    % if any of the rows in tools
    if any(toolRows)
        % Compute class-specific stats
        toolMeanNR = mean([thresholdFile(toolRows).MeanNR]);
        toolMedianNR = median([thresholdFile(toolRows).MedianNR]);
        toolMeanRR = mean([thresholdFile(toolRows).MeanRR]);
        toolMedianRR = median([thresholdFile(toolRows).MedianRR]);
        toolMeanTP = mean([thresholdFile(toolRows).TP]);
        toolMeanTN = mean([thresholdFile(toolRows).TN]);
        toolMeanFP = mean([thresholdFile(toolRows).FP]);
        toolMeanFN = mean([thresholdFile(toolRows).FN]);
                
        % Update class-specific structure
        OverarchingStruct.Tool.(currentTool)(i).Algorithm = Alg;
        OverarchingStruct.Tool.(currentTool)(i).MeanNR = toolMeanNR;
        OverarchingStruct.Tool.(currentTool)(i).MedianNR = toolMedianNR;
        OverarchingStruct.Tool.(currentTool)(i).MeanRR = toolMeanRR;
        OverarchingStruct.Tool.(currentTool)(i).MedianRR = toolMedianRR;
        OverarchingStruct.Tool.(currentTool)(i).MeanTP = toolMeanTP;
        OverarchingStruct.Tool.(currentTool)(i).MeanTN = toolMeanTN;
        OverarchingStruct.Tool.(currentTool)(i).MeanFP = toolMeanFP;
        OverarchingStruct.Tool.(currentTool)(i).MeanFN = toolMeanFN;
    end
end
```

### graphingExcel.m changes
Lines 23 - 28 where the overarching structure is set up should be replaced to the following structure:
```matlab
OverarchingStruct = struct('Baseline', [], 'Tool', struct());
tools = {'GLIDE','GalaxyAI','Photoshop'};
    
for toolNum = 1:length(tools)
    OverarchingStruct.Tool.(tools{toolNum}) = OverallAlgStats;
end
```

Then lines 57 - 81, all instances of class and classes should be replaced with the corresponding variable for tools. For example:
```matlab
% loop through the tools
for toolNum = 1:length(tools)
    currentTool = tools{toolNum};

    % Filter rows by the current tool
    toolRows = strcmp({thresholdFile.Tool}, currentTool);     
            
    % if any of the rows in tools
    if any(toolRows)
        % Compute class-specific stats
        toolMeanNR = mean([thresholdFile(toolRows).MeanNR]);
        toolMedianNR = median([thresholdFile(toolRows).MedianNR]);
        toolMeanRR = mean([thresholdFile(toolRows).MeanRR]);
        toolMedianRR = median([thresholdFile(toolRows).MedianRR]);
        toolMeanTP = mean([thresholdFile(toolRows).TP]);
        toolMeanTN = mean([thresholdFile(toolRows).TN]);
        toolMeanFP = mean([thresholdFile(toolRows).FP]);
        toolMeanFN = mean([thresholdFile(toolRows).FN]);
                
        % Update class-specific structure
        OverarchingStruct.Tool.(currentTool)(i).Algorithm = Alg;
        OverarchingStruct.Tool.(currentTool)(i).MeanNR = toolMeanNR;
        OverarchingStruct.Tool.(currentTool)(i).MedianNR = toolMedianNR;
        OverarchingStruct.Tool.(currentTool)(i).MeanRR = toolMeanRR;
        OverarchingStruct.Tool.(currentTool)(i).MedianRR = toolMedianRR;
        OverarchingStruct.Tool.(currentTool)(i).MeanTP = toolMeanTP;
        OverarchingStruct.Tool.(currentTool)(i).MeanTN = toolMeanTN;
        OverarchingStruct.Tool.(currentTool)(i).MeanFP = toolMeanFP;
        OverarchingStruct.Tool.(currentTool)(i).MeanFN = toolMeanFN;
    end
end
```

Then lines 90 - 92 should be changed to say Tool and tools instead of classes:
```Matlab
% Convert each class stats to table and write to Excel
for Num = 1:length(tools)
    currentCat = tools{Num};
    catStruct = OverarchingStruct.Tool.(currentCat);
```
