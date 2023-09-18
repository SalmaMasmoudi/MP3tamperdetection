function scale_lengths = scale_length_selec( block_type,switch_point,slen1,slen2)
    if ( block_type == 2)        
        if(switch_point == 1)
            scale_lengths = zeros(1,17);
            i = 1:11;
            scale_lengths(i) = slen1;
            i = 12:17;
            scale_lengths(i) = slen2;            
        else
            scale_lengths = zeros(1,12);
            i = 1:6;
            scale_lengths(i) = slen1;
            i = 7:12;
            scale_lengths(i) = slen2;            
        end
    else
        scale_lengths = zeros(1,21);
        i = 1:11;
        scale_lengths(i) = slen1;
        i = 12:21;
        scale_lengths(i) = slen2;        
    end    
end