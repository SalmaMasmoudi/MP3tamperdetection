function output = scalefac_range(block_type , blocksplit_flag, switch_flag, frequency)
%SCALEFAC_RANGE Returns the critical bands organization
%   
%   Spectrum organization in case of block_type 2 & switch_point = 0 is
%   calculated taken into account that every critical band contains 3
%   windows each of length 3 times the length of a particular critical band 
%   given in 11172-3.
%
%   Spectrum organization in case of block_type 2 & switch_point = 1 has
%   been calculated on paper and hard coded here according to the following
%   rule:
%           8 long blocks and then 9 short blocks
%   Boundaries of short block critical bands has been calculated taking into
%   account that every critical band contains 3 windows. each of length 3
%   times the length of a particular critical band given in 11172-3.

    if ( blocksplit_flag && block_type == 2 )
        if switch_flag            
            if (frequency == 32)
                output = [1 4; 5 8; 9 12; 13 16; 17 20; 21 24; 25 30; 31 36; 37 48; 49 66; 67 90; 91 126; 127 174; 175 234; 235 312; 313 414; 415 540; 541 576];
            elseif (frequency == 44.1)
                output = [1 4; 5 8; 9 12; 13 16; 17 20; 21 24; 25 30; 31 36; 37 48; 49 66; 67 90; 91 120; 121 156; 157 198; 199 252; 253 318; 319 408; 409 576];
            elseif (frequency == 48)
                output = [1 4; 5 8; 9 12; 13 16; 17 20; 21 24; 25 30; 31 36; 37 48; 49 66; 67 84; 85 114; 115 150; 151 192; 193 240; 241 300; 301 378; 379 576];
            end
        else
            if (frequency == 32)
                output = [1 4; 5 8; 9 12; 13 16; 17 22; 23 30; 31 42; 43 58; 59 78; 79 104; 105 138; 139 180; 181 192];
            elseif (frequency == 44.1)
                output = [1 4; 5 8; 9 12; 13 16; 17 22; 23 30; 31 40; 41 52; 53 66; 67 84; 85 106; 107 136; 137 192];
            elseif (frequency == 48)
                output = [1 4; 5 8; 9 12; 13 16; 17 22; 23 28; 29 38; 39 50; 51 64; 65 80; 81 100; 101 126; 127 192];
            end
            temp = 2:13;
            output(:,2) = output(:,2) .* 3;
            output(temp,1) = output(temp-1,2)+1;
        end
    else
        if (frequency == 32)
            output = [1 4; 5 8; 9 12; 13 16; 17 20; 21 24; 25 30; 31 36; 37 44; 45 54; 55 66; 67 82; 83 102; 103 126; 127 156; 157 194; 195 240; 241 296; 297 364; 365 448; 449 550; 551 576];
        elseif (frequency == 44.1)
            output = [1 4; 5 8; 9 12; 13 16; 17 20; 21 24; 25 30; 31 36; 37 44; 45 52; 53 62; 63 74; 75 90; 91 110; 111 134; 135 162; 163 196; 197 238; 239 288; 289 342; 343 418; 419 576];
        elseif (frequency == 48)
            output = [1 4; 5 8; 9 12; 13 16; 17 20; 21 24; 25 30; 31 36; 37 42; 43 50; 51 60; 61 72; 73 88; 89 106; 107 128; 129 156; 157 190; 191 230; 231 276; 277 330; 331 384; 385 576];
        end
    end
end