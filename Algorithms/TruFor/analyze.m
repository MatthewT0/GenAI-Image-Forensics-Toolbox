function [ OutputMap ] = analyze( imPath )
    % Input is a single string containing the full path to an image
    % Returns the algorithms output map
    
    OutputMap = run_trufor(imPath);

end

