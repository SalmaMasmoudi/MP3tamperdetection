function int_out = bit_conv ( in )
%BIT_CONV: Converts any length bitstream into an integer
%   Used for conversion of various header
%   & side information paramters to integers.

    in = double(in);        %Convert input parameters to 'double'
    int_out = double(0);    %Initializing Output Variable
    i = numel(in);          %i contains # of bits in the bitstream
    exp2 = 0;               %Initializing exponent value of 2
    
    while( i>0 )            %Loop untill bits remain in the bitsream
        int_out = int_out + (in(i) * 2^exp2);   %Multiplication of a bit with appropriate 2^exp2 according to its place in the bitstream
        i = i - 1;                              %One less bit to convert
        exp2 = exp2 + 1;                        %Incrementing exponent value of 2
    end
end