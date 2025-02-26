function [OutputMap, Feature_Vector, coeffArray] = detectDQ_JPEG( im )
    % Copyright (C) 2016 Markos Zampoglou
    % Information Technologies Institute, Centre for Research and Technology Hellas
    % 6th Km Harilaou-Thermis, Thessaloniki 57001, Greece
    %
    % This function produces a tampering probability map by detecting
    % single-quantized blocks in double-quantized images. It accepts as
    % input a struct that has been generated by jpeg_read
    
    % How many DCT coeffs to take into account
    MaxCoeffs=15;
    % JPEG zig-zag sequence
    coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
    
    % Which channel to take: always keep Y only
    channel=1;
    coeffArray = im.coef_arrays{channel};
    if mod(im.image_height,8)~=0
        coeffArray=coeffArray(1:end-8,:);
    end
    if mod(im.image_width,8)~=0
        coeffArray=coeffArray(:,1:end-8);
    end
    
    for coeffIndex=1:MaxCoeffs
        coe = coeff(coeffIndex);
        startY = mod(coe,8);
        if startY == 0
            startY = 8;
        end
        startX=ceil(coe/8);
        % with startx and starty move in 8x8 blocks
        selectedCoeffs=coeffArray(startX:8:end, startY:8:end);
        % turn 2d to 1d array
        coeffList=reshape(selectedCoeffs,1,numel(selectedCoeffs));
        
        minHistValue=min(coeffList)-1;
        maxHistValue=max(coeffList)+1;
        
        coeffHist=hist(coeffList,minHistValue:maxHistValue);
        if numel(coeffHist>0)
            % find the most frequent value in coeffHist and its index
            [MaxHVal,s_0]=max(coeffHist); 
            % store the index of the most frequent value for current coeff
            s_0_Out(coeffIndex)=s_0; 
            % gets the number of indexes in the coefHist for the current coeff
            dims(coeffIndex)=length(coeffHist);
            % initilialise H to store smoothed values, with length being a guarted of the coeffhist
            H=zeros(floor(length(coeffHist)/4),1);
            % loop through the length of variable
            for coeffInd=1:(length(coeffHist)-1) 
                % select values around the most frequent value both forward and backword by coeffInd steps
                vals=[coeffHist(s_0:coeffInd:end) coeffHist(s_0-coeffInd:-coeffInd:1)];
                % store the average of selected values in H
                H(coeffInd)=mean(vals);
            end
            % save the smoothed data for current coeff
            H_Out{coeffIndex}=H;
            % store the index of the highest value in H
            [~,p_h_avg(coeffIndex)]=max(H);
        else
            % if coefHist is empty or has no meaningful data, set default values 
            s_0_Out(coeffIndex)=0;
            dims(coeffIndex)=0;
            H_Out{coeffIndex}=[];
            p_h_avg(coeffIndex)=1;
        end
        
        % Find period by max peak in the FFT minus DC term
        % FFT is frequency domain representation, which frequencies are present and their amplitudes
        % Calculate the FFT of coefHist and take the absolute value to get amplitude of each frequency
        FFT=abs(fft(coeffHist));
        % Store FFT result in FFT_Out
        FFT_Out{coeffIndex}=FFT;

        if ~isempty(FFT)
            DC=FFT(1);
            
            %Find first local minimum, to remove DC peak
            FreqValley=1;
            while (FreqValley<length(FFT)-1) && (FFT(FreqValley)>= FFT(FreqValley+1))
                FreqValley=FreqValley+1;
            end
            
            FFT=FFT(FreqValley:floor(length(FFT)/2));
            FFT_smoothed{coeffIndex}=FFT;
            [maxPeak,FFTPeak]=max(FFT);

            FFTPeak=FFTPeak+FreqValley-1-1; % -1 because FreqValley appears twice, and -1 for the 0-freq DC term

            % check peak is significant enough to represent
            % It must be at least the threshold 1/5 of the DC component 
            % The smallest FFT value should not be more than 90% of maxPeak to ensure a distinct peak
            if isempty(FFTPeak) || maxPeak<DC/5 || min(FFT)/maxPeak>0.9 
                % if no significant peak set default value of 1
                p_h_fft(coeffIndex)=1;
            else
                % if a significant peak, calculate and store the domininat period length 
                p_h_fft(coeffIndex)=round(length(coeffHist)/FFTPeak);
            end
        else
            % if no FFT store default values
            FFT_Out{coeffIndex}=[];
            FFT_smoothed{coeffIndex}=[];
            p_h_fft(coeffIndex)=1;
        end
        
        %period is the minimum of the two methods
        p_final(coeffIndex)=p_h_fft(coeffIndex);

        %calculate per-block probabilities
        % if value is more than 1, has a peak
        if p_final(coeffIndex)~=1
            % make all vlaues positive
            adjustedCoeffs=selectedCoeffs-minHistValue+1;
            period_start=adjustedCoeffs-(rem(adjustedCoeffs-s_0_Out(coeffIndex),p_final(coeffIndex)));
            % iterate through each 8x8 block 
            for kk=1:size(period_start,1) % x axis
                for ll=1:size(period_start,2) % y axis
                    % checks if aligned coefficient in period_start is greater than or equal to the most frequent value (s_0_Out)
                    if period_start(kk,ll)>=s_0_Out(coeffIndex)
                        % defining the range 
                        period=period_start(kk,ll):period_start(kk,ll)+p_final(coeffIndex)-1;
                        if period_start(kk,ll)+p_final(coeffIndex)-1>length(coeffHist)
                            period(period>length(coeffHist))=period(period>length(coeffHist))-p_final(coeffIndex);
                        end
                        % Store the histogram count for the specific coefficient in num
                        num(kk,ll)=coeffHist(adjustedCoeffs(kk,ll));
                        % Store sum of histogram counts over defined period
                        denom(kk,ll)=sum(coeffHist(period));
                    % if the aligned coefficent isnt greater than the most frequent value
                    else
                        % define the range
                        period=period_start(kk,ll):-1:period_start(kk,ll)-p_final(coeffIndex)+1;
                        if period_start(kk,ll)-p_final(coeffIndex)+1<= 0
                            period(period<=0)=period(period<=0)+p_final(coeffIndex);
                        end
                        % Store the histogram count for the specific coefficient in num
                        num(kk,ll)=coeffHist(adjustedCoeffs(kk,ll));
                        % Store sum of histogram counts over defined period
                        denom(kk,ll)=sum(coeffHist(period));
                        
                    end
                end
            end
            % P_u probability of untampered - likelihood that coeff matches expected pattern
            P_u=num./denom;
            % P_t probability of tampered for - smaller period suggests higher likelihood of tampering
            P_t=1./p_final(coeffIndex);

            % normalising the values
            P_tampered(:,:,coeffIndex)=P_t./(P_u+P_t);
            P_untampered(:,:,coeffIndex)=P_u./(P_u+P_t);

        % else value does not have a peak
        else
            P_tampered(:,:,coeffIndex)=ones(ceil(size(coeffArray,1)/8),ceil(size(coeffArray,2)/8))*0.5;
            P_untampered(:,:,coeffIndex)=1-P_tampered(:,:,coeffIndex);
        end
    end
    
    P_tampered_Overall=prod(P_tampered,3)./(prod(P_tampered,3)+prod(P_untampered,3));
    P_tampered_Overall(isnan(P_tampered_Overall))=0;

    % Set overall tampered matric to the outputmap variable to be passed out
    OutputMap=P_tampered_Overall;

    s=var(reshape(P_tampered_Overall,numel(P_tampered_Overall),1));
    for T=0.01:0.01:0.99
        Class0=P_tampered_Overall<T;
        Class1=~Class0;
        s0=var(P_tampered_Overall(Class0));
        s1=var(P_tampered_Overall(Class1));
        Teval(round(T*100))=s/(s0+s1);
    end
    
    [val,Topt]=max(Teval);
    Topt=Topt/100-0.01;
    
    Class0=P_tampered_Overall<Topt;
    Class1=~Class0;
    
    s0=var(P_tampered_Overall(Class0));
    s1=var(P_tampered_Overall(Class1));
    
    Class1_filt=medfilt2(Class1,[3 3]);
    Class0_filt=medfilt2(Class0,[3 3]);
    
    e_i=(Class0_filt(1:end-2,2:end-1)+Class0_filt(2:end-1,1:end-2)+Class0_filt(3:end,2:end-1)+Class0_filt(2:end-1,3:end)).*Class1_filt(2:end-1,2:end-1);
    
    if sum(sum(Class0)) > 0 && sum(sum(Class0)) < numel(Class0)
        K_0=sum(sum(max(e_i-2,0)))/sum(sum(Class0));
    else
        K_0=1;
        s0=0;
        s1=0;
        
    end
    Feature_Vector=[Topt, s, s0+s1, K_0];
