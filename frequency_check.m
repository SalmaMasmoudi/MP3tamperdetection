function frequency = frequency_check( func_var)
%FREQUENCY_CHECK
%   Maps func_var to appropriate sampling frequency as defined by 11172-3
%   Returns '0' in case of invalid func_var

    frequency_LUT = [44.1 48 32 0]; %sampling frequency look-up table as defined by ISO 11172-3    
    frequency = frequency_LUT(1, func_var+1);
end
             