function fill_windows()
global cos_imdct_long cos_imdct_short sin_window_0 sin_window_1 sin_window_2 sin_window_3 cos_filterbank;

%COS FUNCTION FOR IMDCT OF LONG BLOCKS.
for i = 0:35
    for k = 0:17
        cos_imdct_long(i+1,k+1) = cos( (2*i+19) * (2*k+1) * (pi/72)); 
    end
end

%COS FUNCTION FOR IMDCT OF SHORT BLOCKS.
for i = 0:11
    for k = 0:5
        cos_imdct_short(i+1,k+1) = cos (pi/24 * (2*i + 7) * (2*k + 1));
    end
end

%IMDCT WINDOWING FUNCTION FOR LONG BLOCKS (BLOCK_TYPE = 0)
temp = 0:35;
sin_window_0(temp+1) = sin(pi/36 * (temp + 0.5));

%IMDCT WINDOWING FUNCTION FOR LONG BLOCKS (BLOCK_TYPE = 1)
temp = 0:17;
sin_window_1(temp+1) = sin(pi/36 * (temp + 0.5));  
sin_window_1(19:24) = 1;
temp = 24:29;
sin_window_1(temp+1) = sin(pi/12 * (temp - 17.5));                    
sin_window_1(31:36) = 0;

%IMDCT WINDOWING FUNCTION FOR SHORT BLOCKS (BLOCK_TYPE = 2)
temp = 0:11;
sin_window_2(temp+1) = sin(pi/12 * (temp + 0.5));

%IMDCT WINDOWING FUNCTION FOR LONG BLOCKS (BLOCK_TYPE = 3)
sin_window_3(1:6) = 0;
temp = 6:11;
sin_window_3(temp+1) = sin(pi/12 * (temp - 5.5)); 
sin_window_3(13:18) = 1;
temp = 18:35;
sin_window_3(temp+1) = sin(pi/36 * (temp + 0.5));                    

%COS FUNCTION FOR FILTERBANK
for i = 0:63
    for k = 0:31                
        cos_filterbank(i+1,k+1) = cos((16+i)*(2*k+1)*(pi/64));
    end
end
end