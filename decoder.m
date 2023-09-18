function [out_PCM_samples frequency] = decoder( file_name )
    clc;
    %File Read Operation
    tic
    fid = fopen( file_name, 'r', 'b'); %Setting Up File For Reading in Big Endian Format
    x = uint8( fread(fid, 'ubit1')');  %File Read Bit By Bit and converted to uint8 format for conserving memory
    file_op = toc;
    disp(sprintf('File Read Operation of %s Completed in: %f seconds',file_name,file_op)); 
    
    %Variables Required in Decoding
    frame_counter = 1;
    sync_word = uint8([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1]);
    scsfi = uint8 (zeros(2,21) );
    part2_3_length(1:4,1) = double(0);
    part2_length(1:4,1) = double(0);
    big_values(1:4,1) = uint16(0);
    global_gain(1:4,1) = uint8(0);
    scalefac_compress(1:4,1) = uint8(0);
    slen1(1:4,1) = uint8(0);
    slen2(1:4,1) = uint8(0);
    blocksplit_flag(1:4,1) = uint8(0);
    block_type(1:4,1) = uint8(0);
    switch_point(1:4,1) = uint8(0);
    switch_point_l(1:4,1) = uint8(0);
    switch_point_s(1:4,1) = uint8(0);
    table_select(1:4,1:3) = uint8(0);
    subblock_gain(1:4,1:3) = uint8(0);
    pre_flag(1:4) = uint8(0);
    scalefac_scale(1:4) = uint8(0);                            
    scalefac(1:22,1:3) = uint8(0);
    saved_scalefac(1:22,1:2) = uint8(0);
    region_address1(1:4,1) = uint8(0);
    region_address2(1:4,1) = uint8(0);
    count1table_select(4,1) = uint8(0);
    huffman_decoded_bits(1:4,1:576) = double(0);
    out_PCM_samples = [];
    
    %Functions Filling Global variables.
    fill_D();
    fill_windows();

    %Loading Frequency Inverter Array Instead Of Calculating During
    %Run-Time (Variable = freq_inv);
    load freq_inv; 
  
    %Decoding Process Begins From Here.
    i = 1; %File array traverser variable.
    total_time = 0;
    while ( i+31 <= numel(x) ) %loops untill the read file is not ended        
        %byte align i
        if mod(i - 1,8) ~= 0
            %Find the next byte aligned value for buf_i
            temp = mod(i,8);
            temp = 8 - temp;
            i = i + 1 + temp;
        end
    %checking the first 15 bits for sync word
        if( x(i:i+14) == sync_word)
            flag=1;
            % if this point reached header found..now finding out header info
            %Crc Protection Check
            if( x(i+15) == 0)
                crc_protection = 1; %'CRC Protected';
            else
                crc_protection = 0; %'Not CRC Protected';
            end                   

            if(flag)
                bit_rate = bit_rate_check(bit_conv ( x(i+16:i+19)));
                if(bit_rate~=15)
                    % Valid Bitrate Extracted
                else
                    % Invalid Bitrate = Invalid Header
                    flag = 0;
                end
            end
            if(flag)
                frequency = frequency_check(bit_conv ( x(i+20:i+21)));
                if(frequency~=0)
                    % Valid Sampling Frequency Extracted
                else
                    % Invalid Sampling Frequency = Invalid Header
                    flag = 0;
                end
            end
            if(flag)
                tic
                info4frame = sprintf('Decoding Frame No. %d With Bitrate %d & Sampling Frequency %2.1f kHz',frame_counter,bit_rate,frequency);
                disp(info4frame);
                %Padding Bit Check. It will be 1 if frequency is 44.1KHZ.
                if( x(i+22) == 0)
                    padding = 0;
                else
                    padding = 1;
                end
                %24th bit of Header not required for Decoding.
                %Mode Check
                mode_check = bit_conv( x( i+24:i+25));
                if( mode_check == 0)
                    mode = 'stereo';
                elseif (mode_check == 1)
                    mode = 'joint_stereo';
                elseif (mode_check == 2)
                    mode = 'dual_channel';
                else
                    mode = 'single_channel';
                end
                %Mode Extension Check (Intensity Stereo or Mid Size Stereo)
                mode_extension_check = bit_conv( x(i+26:i+27));
                if (mode_extension_check == 0)
                    intensity_stereo = uint8(0);
                    ms_stereo = uint8(1);
                elseif (mode_extension_check == 1)
                    intensity_stereo = uint8(1);
                    ms_stereo = uint8(0);
                elseif (mode_extension_check == 2)
                    intensity_stereo = uint8(0);
                    ms_stereo = uint8(1);
                elseif (mode_extension_check == 3)
                    intensity_stereo = uint8(1);
                    ms_stereo = uint8(1);
                end
            end                
            if( flag ) %header info extracted
                current_header_BIT = i;
                if(crc_protection == 0)
                    flb = floor(144 * bit_rate/frequency + padding) - 4; %frame length - header size (w/o crc)
                    i = i + 31;
                else
                    flb = floor(144 * bit_rate/frequency + padding) - 6; %frame length - header size (w crc)
                    i = i + 31 + 16;
                end
                i = i + 1;                    
                
                % Decoding of Side Information
                if ( strcmp(mode,'single_channel') )                        
                else %mode is stereo, dual channel or joint stereo.
                    main_data_end = double (bit_conv ( x(i:i+8)));
                    %skipping private_bits as they are not needed for
                    %decoding.
                    temp = i+12;
                    scsfi(1,1:4) = x (temp    :temp + 3);
                    scsfi(2,1:4) = x (temp + 4:temp + 7);
                    temp = temp+8;
                    scsfi = scsfi_expander(scsfi);
                    %extracting info for the granules. ri is row index.
                    ri = 1;
                    for gr=1:2
                        for ch=1:2
                            part2_3_length(ri) = uint16( bit_conv (x(temp:temp+11)));
                            big_values(ri) = uint16( bit_conv (x(temp+12:temp+20)));
                            global_gain(ri) = uint8( bit_conv (x(temp+21:temp+28)));
                            scalefac_compress(ri) = uint8( bit_conv (x(temp+29:temp+32)));                                
                            [slen1(ri) ,slen2(ri)] = scale_compress2slens ( scalefac_compress(ri) );
                            blocksplit_flag(ri) = uint8(x(temp+33));
                            temp = temp + 34;
                            if ( blocksplit_flag(ri))
                                % Explicitly Set Parameters
                                block_type(ri) = uint8( bit_conv (x(temp:temp+1)));
                                switch_point(ri) = uint8(x(temp+2));
                                temp = temp + 3;
                                for region=1:2
                                    table_select(ri,region) = uint8( bit_conv (x(temp:temp+4)));
                                    temp = temp + 5;
                                end
                                for window=1:3
                                    subblock_gain(ri,window) = uint8( bit_conv (x(temp:temp+2)));
                                    temp = temp + 3;
                                end

                                %Implicitly Set Parameters
                                if( block_type(ri) == 1 || block_type(ri,:) == 3)
                                    part2_length(ri) = 11*slen1(ri) + 10*slen2(ri);
                                    region_address1(ri) = uint8( 8 );
                                elseif ( block_type(ri,:) == 2 && ~switch_point (ri) )
                                    switch_point_l(ri) = uint8(0);
                                    switch_point_s(ri) = uint8(1);%using 1 instead of 0 because it will be used as an index while decoding scalefactors.
                                    cb_max = 12;
                                    part2_length(ri) = 18*slen1(ri) + 18*slen2(ri);
                                    region_address1(ri) = uint8( 3 );
                                elseif ( block_type(ri,:) == 2 && switch_point (ri) )
                                    switch_point_l(ri) = uint8(8);
                                    switch_point_s(ri) = uint8(9);
                                    cb_max = 17;
                                    region_address1(ri) = uint8( 8 );
                                    part2_length(ri) = 17*slen1(ri) + 18*slen2(ri);
                                end
                                region_address2(ri,:) = uint8( 0 ); %No region2 in case of block_type ~= 0;                             
                            else
                                %Explicilty Set Parameters                                    
                                for region=1:3
                                    table_select(ri,region) = uint8( bit_conv (x(temp:temp+4)));
                                    temp = temp + 5;
                                end
                                region_address1(ri) = uint8( bit_conv (x(temp:temp+3)));
                                region_address2(ri) = uint8( bit_conv (x(temp+4:temp+6)));                                    
                                temp = temp + 7;

                                %Implicilty Set Parameters
                                block_type (ri) = uint8(0);
                                switch_point (ri) = uint8(0); %not in standard, added here because of scale_lengths function.
                                part2_length(ri,1) = 11*slen1(ri,1) + 10*slen2(ri,1);                                    
                            end
                            pre_flag(ri) = uint8(x(temp));
                            scalefac_scale(ri) = uint8(x(temp+1));
                            count1table_select(ri,1) = uint8(x(temp+2));
                            temp = temp + 3;
                            ri = ri + 1;
                        end %end of for ch = 1:2
                    end %end of for gr = 1:2                    

                    %Calculation of Beginning Point of Main Data                        
                    current_header_end_BIT = temp - 1;
                    if ( main_data_end == 0)
                        i = temp;
                        next_header = current_header_BIT + ((flb * 8) + 32 + (crc_protection * 16)) - 1;
                    else
                        info4frame = sprintf('Destructive Decoding Required For Frame # %d',frame_counter);
                        disp(info4frame);
                        info4frame = sprintf('No. Of Bytes In Previous Frame: %d', main_data_end);
                        disp(info4frame);
                        i = current_header_BIT - (main_data_end*8);
                        %remove header and side info based on variables                            
                        x(current_header_BIT:current_header_end_BIT) = []; 
                        next_header = current_header_BIT + ((flb * 8) - (32 * 8)) - 1;
                    end

                    %Decoding Of Scalefactors & Huffman Data. Also
                    %Requantization & Re-ordering.                            
                    ri = 1; 
                    for gr = 1:2
                        for ch= 1:2                            
                            bg_val = 2 * big_values(ri);
                            if ( part2_3_length(ri) == 0 )
                                %No main data to decode
                            else
                                % Scalefactors Decoding
                                channel_main_data_end = i + part2_3_length(ri) - 1;
                                scale_lengths = scale_length_selec( block_type(ri), switch_point(ri), slen1(ri), slen2(ri) );                                
                                if ( blocksplit_flag(ri) && block_type(ri) == 2 )
                                    for cb = 1:switch_point_l(ri,1) %because we used switch_pt_l = 0,this loop will be skipped when switch_pt=0;        
                                        scalefac(cb,:) = uint8(bit_conv (x(i : i+scale_lengths(cb)-1)));
                                        i = i + scale_lengths(cb); %not using -1 because then it will pt to the last bit of the current scalefac  
                                    end
                                    for cb = switch_point_s(ri,1):cb_max % switch_point_s either 1 or 9.
                                        for window = 1:3
                                            scalefac(cb,window) = uint8( bit_conv (x(i : i+scale_lengths(cb)-1)));
                                            i = i + scale_lengths(cb);                                                        
                                        end
                                    end
                                else
                                    for cb=1:21
                                        if( scsfi(ch,cb) == 0 || gr == 1 )
                                            scalefac(cb,1) = uint8( bit_conv (x(i : i+scale_lengths(cb)-1) ));                                            
                                            i = i + scale_lengths(cb);
                                        else
                                            scalefac(cb,1) = saved_scalefac(cb,ch);
                                        end
                                    end
                                    %MAKE DECISION ON WHETHER TO SAVE CURRENT
                                    %SCALEFACTORS OR NOT. BASED ON SCSFI.
                                    if (gr == 1)
                                        if (scsfi(ch,1) ~= 0 || scsfi(ch,7) ~= 0 || scsfi(ch,12) ~= 0 || scsfi(ch,17) ~= 0)
                                            %SAVE SCALEFACTORS OF THIS CHANNEL
                                            saved_scalefac(:,ch) = scalefac(:,1);
                                        end
                                    end 
                                end

                                %HUFFMAN DECODING
                                scale_distro = scalefac_range(block_type(ri), blocksplit_flag(ri),switch_point(ri), frequency);
                                huf_iter = 1;
                                if ( region_address1(ri) ~= 0 )
                                    if block_type(ri) == 0
                                        add1_range = scale_distro( region_address1(ri)+1, 1:2);
                                    else %block_type 1,2 or 3.
                                        add1_range = scale_distro( region_address1(ri), 1:2);
                                    end                                            
                                else
                                    add1_range = [0 0];
                                end
                                if (blocksplit_flag(ri,1) == 1 && block_type(ri) == 2)
                                    [huf_tab_region0 linbits_region0 max_cl0] = huffman_tables (table_select(ri,1));
                                    [huf_tab_region1 linbits_region1 max_cl1] = huffman_tables (table_select(ri,2));                                    
                                    add2_range = [0 bg_val];                     %No region2
                                else
                                    [huf_tab_region0 linbits_region0 max_cl0] = huffman_tables (table_select(ri,1));
                                    [huf_tab_region1 linbits_region1 max_cl1] = huffman_tables (table_select(ri,2));
                                    [huf_tab_region2 linbits_region2 max_cl2] = huffman_tables (table_select(ri,3));
                                    if block_type(ri) == 0
                                        add2_range = scale_distro (region_address1(ri) + region_address2(ri) + 2, :);
                                    elseif block_type(ri) == 1 || block_type (ri) == 3
                                        add2_range = [0 bg_val];
                                    end
                                end
                                while (huf_iter < bg_val && i <= channel_main_data_end)       
                                    if huf_iter >= 1 && huf_iter <= add1_range (1,2)
                                        if table_select(ri,1) ~= 0
                                            [val_x val_y length_code] = huffman_parser ( x (i:i+max_cl0-1) , huf_tab_region0);
                                            linbits = linbits_region0;
                                        else %Table zero used for this region, assign 0 to all values and skip to next region
                                            huffman_decoded_bits(ri, 1:add1_range(1,2)-2) = 0;
                                            huf_iter = add1_range(1,2) - 1; 
                                            val_x = 0;
                                            val_y = 0;
                                            length_code = 0;
                                            linbits = 0;
                                        end
                                    elseif huf_iter > add1_range(1,2) && huf_iter <= add2_range(1,2)
                                        if table_select(ri,2) ~= 0
                                            [val_x val_y length_code] = huffman_parser ( x (i:i+max_cl1-1) , huf_tab_region1);
                                            linbits = linbits_region1;
                                        else %Table zero used for this region, assign 0 to all values and skip to next region
                                            huffman_decoded_bits(ri, add1_range(1,2)+1:add2_range(1,2)-2) = 0;
                                            huf_iter = add2_range(1,2) - 1;
                                            val_x = 0;
                                            val_y = 0;
                                            length_code = 0;
                                            linbits = 0;
                                        end   
                                    elseif huf_iter > add2_range(1,2) && huf_iter <= bg_val
                                        if table_select(ri,3) ~= 0
                                            [val_x val_y length_code] = huffman_parser ( x (i:i+max_cl2-1) , huf_tab_region2);
                                            linbits = linbits_region2;
                                        else %Table zero used for this region, assign 0 to all values and skip to coun1_region
                                            huffman_decoded_bits(ri, add2_range(1,2)+1:bg_val-2) = 0;
                                            huf_iter = bg_val - 1;
                                            val_x = 0;
                                            val_y = 0;
                                            length_code = 0;
                                            linbits = 0;
                                        end
                                    end
                                    i = i + length_code;

                                    if (val_x == 15 && linbits~=0)
                                        val_x = val_x + bit_conv (x (i : i+linbits-1) );
                                        i = i + linbits;
                                    end 
                                    if (val_x ~= 0)
                                        if (x(i))
                                            val_x = - val_x;
                                        end
                                        i = i + 1;
                                    end
                                    if (val_y == 15 && linbits~=0)
                                        val_y = val_y + bit_conv (x (i : i+linbits-1) );
                                        i = i + linbits;
                                    end
                                    if (val_y ~= 0)
                                        if ( x(i))
                                            val_y = - val_y;
                                        end
                                        i = i + 1;
                                    end

                                    huffman_decoded_bits (ri,huf_iter: huf_iter+1) = [val_x val_y];
                                    huf_iter = huf_iter+2;                                        
                                end
                                while (i <= channel_main_data_end && huf_iter <= 573)
                                    [val_0 val_1 val_2 val_3 length_code] = count1_parser( x(i:i+5) ,count1table_select(ri));
                                    i = i + length_code;
                                    if (val_0 ~= 0)
                                        if ( x(i) )
                                            val_0 = - val_0;
                                        end
                                        i = i + 1;
                                    end
                                    if (val_1 ~= 0)
                                        if ( x(i) )
                                            val_1 = - val_1;
                                        end
                                        i = i + 1;
                                    end
                                    if (val_2 ~= 0)
                                        if ( x(i) )
                                            val_2 = - val_2;
                                        end
                                        i = i + 1;
                                    end
                                    if (val_3 ~= 0)
                                        if ( x(i) )
                                            val_3 = - val_3;
                                        end
                                        i = i + 1;
                                    end
                                    huffman_decoded_bits(ri , huf_iter:huf_iter+3) = [val_0 val_1 val_2 val_3];
                                    huf_iter = huf_iter + 4;                                    
                                end
                                if huf_iter > 576
                                    huffman_decoded_bits(:,577:end) = [];
                                end

                                i = channel_main_data_end + 1; %Just a fail safe statement.
                    
                                %Requantization
                                huffman_decoded_bits(ri,:) = requantizer(huffman_decoded_bits(ri,:), scalefac, scale_distro, block_type(ri), blocksplit_flag(ri), global_gain(ri), subblock_gain(ri,:), pre_flag(ri), scalefac_scale(ri), switch_point(ri));
                                    
                                %Reordering of critical bands using
                                %short blocks.
                                if blocksplit_flag(ri) && block_type(ri)==2
                                    huffman_decoded_bits(ri,:) = reorder_spectrum(huffman_decoded_bits(ri,:), scale_distro, switch_point(ri));
                                end

                            scalefac(:,:) = 0; %resetting scale factors for next channel/granule
                            end
                            ri = ri + 1;
                        end  % end of for ch = 1:2
                    end % end of for gr = 1:2

                    %Joint Stereo Processing
                    if strcmp(mode,'joint_stereo');
                        huffman_decoded_bits = stereo_processing(huffman_decoded_bits, intensity_stereo, ms_stereo);
                    end
                    
                    %Alias Correction Based on block_type, switch_point
                    %and blocksplit_flag
                    huffman_decoded_bits = alias_reduction(huffman_decoded_bits, block_type, blocksplit_flag, switch_point);
                    out_PCM_samples=[out_PCM_samples huffman_decoded_bits];
%                     %IMDCT Module
%                     temp_PCM_samples     = IMDCT(huffman_decoded_bits , block_type, blocksplit_flag, switch_point);    
%                     
%                     %Frequency inversion Using Loaded Variable freq_inv
%                     temp_PCM_samples     = temp_PCM_samples .* freq_inv;
% 
%                     %Synthesis Filterbank Module
%                     temp_PCM_samples     = filterbank(temp_PCM_samples);                  
%                     
%                     %convert two granules into left and right channel to
%                     %send to speakers.
%                     if isempty(out_PCM_samples)
%                         out_PCM_samples(1,1:1152) = [temp_PCM_samples(1,:) temp_PCM_samples(3,:)]; %channel 1
%                         out_PCM_samples(2,1:1152) = [temp_PCM_samples(2,:) temp_PCM_samples(4,:)]; %channel 2
%                     else
%                         length_PCM = numel(out_PCM_samples(1,:));
%                         out_PCM_samples(1,length_PCM+1:length_PCM+1152) = [temp_PCM_samples(1,:) temp_PCM_samples(3,:)]; %channel 1
%                         out_PCM_samples(2,length_PCM+1:length_PCM+1152) = [temp_PCM_samples(2,:) temp_PCM_samples(4,:)]; %channel 2
%                     end
                    %clear variables for next iteration
                    scsfi(:,:) = 0;
                    huffman_decoded_bits(:,:) = 0;
                    saved_scalefac(:,:) = 0;
                    if frame_counter == 100
                        disp('wow');
                    end
                    frame_counter = frame_counter+1;
                    
                    time_spent = toc;
                    info4frame = sprintf('Time Taken To Decode Frame: %f Seconds',time_spent);                   
                    disp(info4frame);
                    total_time = total_time + time_spent;
                    disp('-----------------------------------------------------------------');                     
                end
                i = next_header;
            end
        end
        i = i + 1;        
    end
    disp('DECODING COMPLETE');
    disp(sprintf('Total Time Spent In Decoding %s : %f',file_name,total_time));
end
