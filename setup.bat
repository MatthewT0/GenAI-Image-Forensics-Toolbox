@echo off
setlocal enabledelayedexpansion

:: Set the root directory to the current working directory
set "rootdir=%cd%"

:: Define the directory paths
set "dirpaths=%rootdir%\Dataset\Tampered %rootdir%\Dataset\Authentic %rootdir%\Dataset\Masks"

:: Loop through each directory path
for %%d in (%dirpaths%) do (
    if not exist "%%d" (
        mkdir "%%d"
    )
)
