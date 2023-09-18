function [slen1,slen2] = scale_compress2slens ( func_var )
    scale_compress_LUT = [0 0; 0 1; 0 2; 0 3; 3 0; 1 1; 1 2; 1 3; 2 1; 2 2; 2 3; 3 1; 3 2; 3 3; 4 2; 4 3];
    
    slen1 = uint8( scale_compress_LUT (func_var+1,1) ); %We have added 1 after converting input argument 
%     to decimal because matlab indices start at 1.   
    
    slen2 = uint8( scale_compress_LUT (func_var+1,2) );
end