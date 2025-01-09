# GenAI-Image-Forensics-Toolbox <!-- omit from toc -->
GenAI-Image-Forensics-Toolbox is a MATLAB-based project designed for analysing and evaluating the integrity of images. This is adapted from the Image Forensics MATLAB Toolbox, which consists of 16 localisation algorithms for splicing detection. The code has been adapted to run on inpainting modified images, which have a similar modification technique to splicing and use 13 of the 16 included algorithms.

The base code was primarily adapted from the [Image Forensics Toolbox](https://github.com/MKLab-ITI/image-forensics/blob/master/matlab_toolbox/), and individual citations for each algorithm can be found within the corresponding algorithm directories README. Additionally, a list of citations used within this implementation of the framework can be found in the [Citation](#citations) section.  
This code was amended, written, and tested using MATLAB R2024a in both Windows 10 and 11.

This README provides detailed instructions for setting up the repository, guidance on its usage, and an overview of directory structure and its contents.
- For details on code modifications refer to [developer_guidelines](docs/developer_guidelines.md).
- For information about upcoming changes or updates to the repository, refer to the [road map](#roadmap-and-future-changes)


## Table of Contents <!-- omit from toc -->
- [Roadmap and Future Changes](#roadmap-and-future-changes)
- [Setup Instructions](#setup-instructions)
  - [Prerequisites](#prerequisites)
  - [Install the required MATLAB packages](#install-the-required-matlab-packages)
  - [Unzip the jpeg\_toolbox.rar](#unzip-the-jpeg_toolboxrar)
  - [Run the Setup Script](#run-the-setup-script)
  - [Add Images to Corresponding Directories](#add-images-to-corresponding-directories)
  - [Set File Paths](#set-file-paths)
- [MATLAB Script Run Order](#matlab-script-run-order)
- [Directory Structure](#directory-structure)
  - [Dataset](#dataset)
    - [Mask Requirement](#mask-requirement)
  - [Other Directories](#other-directories)
- [Citations](#citations)

## Roadmap and Future Changes
We are continuously improving this project. Key planned updates include:
- Removing the need for user input in directory paths.
- Merging post-processing scripts to create a more user-friendly and automated process.
- Optimising code for improved performance and scalability.
- Expanding support to include analysis for fully generated images.

## Setup Instructions
To setup this project the following needs to be completed:
<!-- no toc -->
1. [Prerequisites](#prerequisites)
2. [Install the required MATLAB packages](#1-install-the-required-matlab-packages)
3. [Unzip the jpeg_toolbox.rar](#2-unzip-the-jpeg_toolboxrar)
4. [Run the Setup Script](#3-run-the-setup-script)
5. [Add Images to Corresponding Directories](#4-add-images-to-corresponding-directories)
6. [Set File Paths](#5-set-filepaths-within-the-evaluatealgorithmsm)


### Prerequisites
Before setting up the project, ensure you have:
- MATLAB R2024a installed on your system.
- A git clone of the GenAI-Image-Forensics-Toolbox repository.
- The required toolbox files (jpeg_toolbox.rar) within the Util directory.


### Install the required MATLAB packages
For this code to run, some MATLAB packages are required. These can be installed by going to the Environment section on the Home tab of the MATLAB toolstrip and clicking on Add-Ons. The following packages should be installed:
- Image Processing Toolbox
- Wavelet Toolbox
- Statistics and Machine Learning Toolbox
- Parallel Computing Toolbox
- Signal Processing Toolbox

### Unzip the jpeg_toolbox.rar
The jpeg_toolbox.rar within Util directory will need to be unzipped and the paths added into MATLAB. This directory provides required functions for the code to correctly run.
1. Locate and unzip the jpeg_toolbox.rar file in the Util directory.
2. The jpegtbx_1.4 directory within this should also be unzipped.
3. From the project root directory add the following paths `./Util`, `./Util/jpeg_toolbox`, `./Util/jpeg_toolbox/jpegtbx_1.4`, and `./Analysis_and_Processing` in MATLAB.
    - Navigate to the Environment section on the Home tab of the MATLAB toolstrip.
    - Click Set Path.
    - Click Add folder and locate the above highlighted paths.

### Run the Setup Script
There is a provided setup script to create the needed directory structure. Depending on which operating system you use, both a Windows bat script and Linux bash script have been included. These need to be run in the terminal from the directory they are placed in.

You should ensure you are in the root directory of GenAI-Image-Forensics-Toolbox within the terminal:
```powershell
# check current directory
pwd

# if you need to move directory
cd GenAI-Image-Forensics-Toolbox
```
Then execute the setup script depending on your operating system
```powershell
# Windows:
.\setup.bat

# Linux:
.\setup.sh
```

This should create the following directory structure:
```
.
├── Dataset
│   ├── Tampered
│   ├── Authentic
│   └── Masks
```
More information on each directory can be found in the [Directory Structure](#directory-structure) section.


### Add Images to Corresponding Directories
This code is written on the assumption that the naming syntax of the images is:  
`[ToolOfManipulation]_[Class]_inpaint_[NumID]_[IterationNum]`.

For example,  
**GLIDE_Animals_inpaint_1_1.jpg** is an image edited with GLIDE of an animal which can be directly linked to real_1 and real_mask_1 and the first iteration.

All images should be added into the corresponding directories with the correct naming convention for the code to run correctly. Additionally, within the directories it is expected that there is a further directory breakdown for classes such as:
```
.
├───Dataset
│   ├───Authentic
│   │   ├───Animals
│   │   ├───Objects
│   │   ├───Person
│   │   └───Scenery
│   ├───Masks
│   │   ├───Animals
│   │   ├───Objects
│   │   ├───Person
│   │   └───Scenery
│   ├───Tampered
│   │   ├───Animals
│   │   ├───Objects
│   │   ├───Person
│   │   └───Scenery
```
The classes can be any subject class of your choice as long as they match the classes within the filenames.

It is recommended to read the [Mask Requirement](#mask-requirement) of this documentation and follow option 1 to fill the dataset directory correctly.

**IMPORTANT:** If you are not splitting your images up by classes then refer to the [developer_guidelines](docs/developer_guidelines.md) for guidelines on how to adapt the code for this layout.

### Set File Paths
Make sure all rootPath variables end with path separator! ("/" or "\\" depending on your system). All rootPath variables should have the absolute path to the root folder of the repository for the code to work.

Within each script the rootPath **must** be changed to the absolute path of this repo for the code to run. For each script it can be found on the following lines:

- In ./EvaluateAlgorithm.m on line 6
- In ./Analysis_and_Processing/normalised.m on line 2
- In ./Analysis_and_Processing/organiseFiles.m on line 2
- In ./Analysis_and_Processing/AuAddition on line 2
- In ./Analysis_and_Processing/CalculatingThresholds on line 2
- In ./Analysis_and_Processing/graphing on line 2
- In ./Analysis_and_Processing/graphingExcel on line 2

## MATLAB Script Run Order
The MATLAB sripts should be run in the following order:
<!-- no toc -->
- [EvaluateAlgorithms](#evaluatealgorithmsm)
- [normalised](#normalisedm)
- [OrganiseFiles](#organisefilesm)
- [AuAddition](#auadditionm)
- [CalculatingThresholds](#calculatingthresholdsm)
- [graphingExcel](#graphingexcelm)

### EvaluateAlgorithms.m  <!-- omit from toc -->
This script can be found in the root directory.

This is the main script used to evaluate the images with the different localisation algorithms, amended from the [Image Forensics Toolbox](https://github.com/MKLab-ITI/image-forensics/blob/master/matlab_toolbox/).

It is recommended that you read the section about [Mask selection](#mask-requirement) before running this script.

Upon running this script an Output directory should be made with subsequent directories for each algorithm names "Dataset_ALG", where ALG is the algorithm that was run on the images. Additionally, a directory called Evals will be created in the Output directory.

### normalised.m <!-- omit from toc -->

This script can be found within the `./Analysis_and_Processing` directory.

This script takes the output from the previous one and normalises the values so that they can be analysed and compared. The values are normalised between 0 and 1 using the min max method, and each algorithms lowest and highest values are outputted to the command window, alongside the total files processed for verification.

These files are then resaved in the Normalised directory, with the same file structure as the Output directory.

### OrganiseFiles.m <!-- omit from toc -->

This script can be found within the `./Analysis_and_Processing` directory.

The script organises files by created a structured dataset (struct) that includes the key information such as filename, class, tool, normalised evaluation results, and other data required for result analysis.

For large datasets, the script may take some time to complete. To monitor progress and confirm it is running correctly you can uncomment line 21 to enable progress output.

The script outputs a .mat file for each algorihtm, containing the organised structs. These files are saved in the OrganisedFiles directory, where they are used for further anlaysis.

### AuAddition.m <!-- omit from toc -->

This script can be found within the `./Analysis_and_Processing` directory.

The script processes the structured data created by the previous script (OrganiseFiles.m) and allocated each tampered image with its reference authentic image and the output values corresponding to it.

Similarly to the previous script, for larger datasets this script can take some time to complete. To monitor its progress and ensure it is running correctly you can uncomment line 12.

The updated structured dataset (struct) overwrites the .mat files saved in the OrganisedFiles directory, for future analysis.

### CalculatingThresholds.m <!-- omit from toc -->

This script can be found within the `./Analysis_and_Processing` directory.

The script processes the organised .mat files with a pre-set threshold of the reference authentic image evaluation values. It uses this analysis to calculate some evaluation metrics such as the mean and median for the images.

These values are written to a structured dataset (struct) and saved in the Threshold directory within OrganisedFiles.

### graphingExcel.m <!-- omit from toc -->

This script can be found within the `./Analysis_and_Processing` directory.

This is the final script which will analyse all values across the files for each algorithm and class. Then, a summary is saved to a spreadsheet (xlsx) for viewing. These values can be used to create graphs or further analysis.

The outputted file can be found within the OrganisedFiles\Graphing directory.

If a .mat file is preferred the graphing script can be used instead of graphingExcel. If a different split analysis than classes is needed refer to the [developer_guidelines](docs/developer_guidelines.md) for information on the implementation.

## Directory Structure
The key components of the directory structure include:
```
.
├── Algorithms
├── Dataset
│   ├── Tampered
│   ├── Authentic
│   └── Masks
├── Analysis_and_Processing
├── Util
├── Output
├── Normalised
├── OrganisedFiles
```

These have been split into two subsections to explain the dataset layout and summarise the other directories functionality:
- [Dataset](#dataset)
- [Other Directories](#other-directories)

### Dataset
The Dataset directory consists of three subdirectories of Tampered, Authentic, and Masks. These directories contain all the images that will be processed and analysed.
- The **Tampered** directory is the images that have been modified.
- The **Authentic** directory are the starting reference images with no changes.
- Then **Masks** directory is the binary masks showing what areas of the authentic images has been tampered with.

#### Mask Requirement

Masks are required for spliced or inpainted images and can be organised in one of the following ways:

1. **Folder Structure Matching Images (Recommended)**:  
   This is the recommended option, as it is the setup on which this code has been tested. Place the masks in a folder structure that mirrors the `Tampered` directory. Each mask should have a filename that matches the corresponding tampered image's identifier (the first number). For example:

    ```
    ├───Dataset
    │   ├───Tampered
    │   │   └───Animals
    │           └───GalaxyAI_Animals_inpaint_1_2.jpg
    │   ├───Masks
    │   │   └───Animals
    │           └───real_mask_1.png
    ```

    If you use this option ensure line 14 is set to true. If you use one of the other two options this should be set to false.

2. **Single Mask for Entire Dataset**:  
   Use a single PNG image located in the root folder as a universal mask for all images in the dataset.

    If you use this option ensure line 14 is set to false.

1. **Multiple Masks Matching Multiple Images**:  
   Use multiple mask files, each corresponding to a specific spliced image in the dataset.

    If you use this option ensure line 14 is set to false.

### Other Directories
- **Algorithms**: The Algorithms directory contains all the code for the 16 included algorithms, of which 13 are used in this image evaluation.
- **Analysis_and_Processing**: This directory contains all the additional scripts for processing the output results.
- **Util**: This contains the necessary packages for the base code to run. These should not need to be amended.
- **Output**: This directory holds the original output from the modified base code, which is used for the analysis of the files in later scripts
- **Normalised**: This contains the output values normalised between 0 and 1 for ease of analysis.
- **OrganisedFiles**: This directory contains all other outputs from the analysis scripts.


## Citations
The main framework paper and 13 localisation algorithms papers can be found detailed below, for other localisation algorithms inclusion please refer to the relevant readme within the algorithm directory.

### The main framework paper:   <!-- omit from toc -->
Markos Zampoglou, Symeon Papadopoulos, and Yiannis Kompatsiaris. 2017.
Large-scale evaluation of splicing localization algorithms for web images. Mul-
timedia Tools and Applications 76, 4 (Feb. 2017), 4801–4834. https://doi.org/10.1007/s11042-016-3795-2

### The algorithms papers:   <!-- omit from toc -->
**ADQ1** - Zhouchen Lin, Junfeng He, Xiaoou Tang, and Chi-Keung Tang. 2009. Fast,
automatic and fine-grained tampered JPEG image detection via DCT coefficient
analysis. Pattern Recognition 42, 2492–2501. https://doi.org/10.1016/j.patcog.2009.03.019

**ADQ2** - Tiziano Bianchi, Alessia De Rosa, and Alessandro Piva. 2011. Improved DCT
coefficient analysis for forgery localization in JPEG images. In 2011 IEEE Inter-
national Conference on Acoustics, Speech and Signal Processing (ICASSP). IEEE 2444–2447. https://doi.org/10.1109/ICASSP.2011.5946978 ISSN: 2379-190X

**ADQ3** - Irene Amerini, Rudy Becarelli, Roberto Caldelli, and Andrea Del Mastio. 2014. Splicing forgeries localization through the use of first digit features. In 2014 IEEE International Workshop on Information Forensics and Security (WIFS). IEEE, 143–148. https://doi.org/10.1109/WIFS.2014.7084318 ISSN: 2157-4774.

**BLK** - Weihai Li, Yuan Yuan, and Nenghai Yu. 2009. Passive detection of doctored
JPEG image via block artifact grid extraction. Signal Processing 89, 1821–1829. https://doi.org/10.1016/j.sigpro.2009.03.025

**CAGI** - Chryssanthi Iakovidou, Markos Zampoglou, Symeon Papadopoulos, and Yiannis
Kompatsiaris. 2018. Content-aware detection of JPEG grid inconsistencies for
intuitive image forensics. Journal of Visual Communication and Image Represen-
tation 54, 155–170. https://doi.org/10.1016/j.jvcir.2018.05.011

**CFA1** - Pasquale Ferrara, Tiziano Bianchi, Alessia De Rosa, and Alessandro Piva. 2012. Image Forgery Localization via Fine-Grained Analysis of CFA Artifacts. IEEE
Transactions on Information Forensics and Security 7, 1566–1577.
https://doi.org/10.1109/TIFS.2012.2202227 

**CFA3** - Ahmet Emir Dirik and Nasir Memon. 2009. Image tamper detection based
on demosaicing artifacts. In 2009 16th IEEE International Conference on Image
Processing (ICIP). IEEE, 1497–1500. https://doi.org/10.1109/ICIP.2009.5414611
ISSN: 2381-8549 

**DCT** - Shuiming Ye, Qibin Sun, and Ee-Chien Chang. 2007. Detecting Digital Image
Forgeries by Measuring Inconsistencies of Blocking Artifact. In 2007 IEEE Inter-
national Conference on Multimedia and Expo. IEEE, 12–15. https://doi.org/10.1109/ICME.2007.4284574 ISSN: 1945-788X.

**ELA** - Neal Krawetz. 2007. A Picture’s Worth: Digital Image Analysis and Forensics. Black Hat USA,, 1 to 31. https://blackhat.com/presentations/bh-dc-08/Krawetz/Whitepaper/bh-dc-08-krawetz-WP.pdf

**NADQ** - Tiziano Bianchi and Alessandro Piva. 2012. Image Forgery Localization via
Block-Grained Analysis of JPEG Artifacts. IEEE Transactions on Information
Forensics and Security 7, 1003–1017. https://doi.org/10.1109/TIFS.2012.2187516 

**NOI1** - Babak Mahdian and Stanislav Saic. 2009. Using noise inconsistencies for blind image forensics. Image and Vision Computing 27, 1497–1503.
https://doi.org/10.1016/j.imavis.2009.02.001

**NOI4** - Jonas Wagner. 2015. Noise Analysis for Image Forensics. http://29a.ch/2015/08/21/noise-analysis-for-image-forensics

**NOI5** - Hui Zeng, Yifeng Zhan, Xiangui Kang, and Xiaodan Lin. 2017. Image splicing
localization using PCA-based noise level estimation. Multimedia Tools and
Applications 76, 4783–4799. https://doi.org/10.1007/s11042-016-3712-8