function [OutputMap]=run_trufor(imPath)   
    % This function runs the TruFor Python script and extracts the output map.

    % set directories for the python script to run correctly
    scriptDir = fileparts(mfilename('fullpath'));  % Directory of this .m file
    srcPath = fullfile(scriptDir, 'src');  % Full path to the src folder
    truforScript = fullfile(srcPath, 'trufor_test.py');  % Path to trufor_test.py

    % Ensure the srcPath uses correct slashes for Windows
    srcPath = strrep(srcPath, '\', '/'); 
    truforScript = strrep(truforScript, '\', '/');

    % Construct the Python command with working directory
    pythonCmd = sprintf('cd /d "%s" && py "%s" -gpu 0 -in "%s"', srcPath, truforScript, imPath);

    % Run the Python command and capture output
    [status, cmdout] = system([pythonCmd, ' 2> nul']); % Redirect STDERR to NULL

    % Check for errors
    if status ~= 0
        error('Error running TruFor: %s', cmdout);
    end

    cmdout = strtrim(cmdout); % Trim extra spaces

    % Ensure the first character is '[' (indicating a valid JSON array)
    if ~startsWith(cmdout, '[')
        error('Unexpected output from Python. Output received: %s', cmdout);
    end

    % Decode JSON output to get the numerical matrix
    OutputMap = jsondecode(cmdout);

    % Convert to MATLAB double
    OutputMap = double(OutputMap);
end