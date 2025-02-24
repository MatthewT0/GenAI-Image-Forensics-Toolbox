@echo off
:: =========================================
::  TruFor Local Execution Script (Windows)
:: =========================================

:: Set the input and output directories
set INPUT_DIR=%CD%\..\images
set OUTPUT_DIR=%CD%\..\output

:: Ensure output directory exists
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Run the Python script - Python version 3.13.1
py trufor_test.py -gpu 0 -in "%INPUT_DIR%" -out "%OUTPUT_DIR%"

echo ==============================
echo TruFor execution completed!
echo Output saved in %OUTPUT_DIR%
echo ==============================
pause
