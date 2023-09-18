function bit_rate = bit_rate_check ( func_var )
%BIT_RATE_CHECK
%   Maps func_var to appropriate bit_rate as defined by 11172-3
%   Returns '0' in case of free format bit rate
%   Returns '15' in case of invalid func_var

    bit_rate_LUT = [32 40 48 56 64 80 96 112 128 160 192 224 256 320]; %bit rate look-up table as defined by ISO 11172-3
    if func_var == 0
        bit_rate = 0;
    elseif func_var == 15
        bit_rate = 15;
    else
        bit_rate = bit_rate_LUT(1, func_var);
    end
end