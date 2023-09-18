function output_data = IMDCT( input_data, block_type, blocksplit_flag, switch_point)
global cos_imdct_long cos_imdct_short sin_window_0 sin_window_1 sin_window_2 sin_window_3;
output_data(1:4,1:576) = double(0);
output_holder(1:36) = double(0);
block_type2_sum(1:3,1:12) = 0;
persistent overlap_adder skipper;

if isempty(overlap_adder)
    overlap_adder = zeros(2,576);
    skipper = zeros(1,18);
end

for iter = 1:4
    %decide channel to use the appropriate overlap_adder
    if mod(iter,2) == 1;
        channel = 1;
    else
        channel = 2;
    end    
    if blocksplit_flag(iter) && block_type(iter) == 2        
        current_start = 1;
        if switch_point(iter)
            %do long transform for first 2 sub_bands.
            while current_start <= 36
                output_holder(:) = 0;
                temp_data = input_data(iter, current_start:current_start+17);
                if temp_data == skipper
                else
                    for i = 1:36
                        output_holder(i) = sum( temp_data .* cos_imdct_long(i,:) );                
                    end
                    
                    %Windowing Operation (only block type 0 window required)
                    output_holder = output_holder .* sin_window_0; 
                end               

                %Overlap Add Operation
                output_holder(1:18) = output_holder(1:18) + overlap_adder(channel,current_start:current_start+17);
                overlap_adder(channel,current_start:current_start+17) = output_holder (19:36);

                output_data(iter, current_start : current_start + 17) = output_holder(1:18);                       
                current_start = current_start + 18;            
            end
        end
        while current_start <= 576
            output_holder(:) = 0;
            block_type2_sum(:,:) = 0;
            temp_data = input_data(iter, current_start:current_start+17);            
            
            if temp_data == skipper
            else
                for window=1:3
                    selected_samples = temp_data(window:3:18);
                    for i = 1:12
                        block_type2_sum(window, i) = sum( selected_samples .* cos_imdct_short(i,:) );                
                    end
                end              
                
                %Block Type 2 Windowing Operation.
                for window = 1:3
                    block_type2_sum(window,:) = block_type2_sum(window,:) .* sin_window_2;
                end

                %making 36 point output of IMDCT from 3 12 point windows.
                output_holder(1:6)   = 0;
                output_holder(7:12)  = block_type2_sum(1, 1:6);
                output_holder(13:18) = block_type2_sum(1, 7:12) + block_type2_sum(2, 1:6);
                output_holder(19:24) = block_type2_sum(2, 7:12) + block_type2_sum(3, 1:6);
                output_holder(25:30) = block_type2_sum(3, 7:12);
                output_holder(31:36) = 0;      
            end

            %Overlap Add Operation
            output_holder(1:18) = output_holder(1:18) + overlap_adder(channel,current_start:current_start+17);
            overlap_adder(channel,current_start:current_start+17) = output_holder (19:36);

            output_data(iter, current_start : current_start + 17) = output_holder(1:18);  
            current_start = current_start + 18;
        end
    else
        current_start = 1;
        while current_start <= 576
            output_holder(:) = 0;
            temp_data = input_data(iter, current_start:current_start+17);
            if temp_data == skipper
            else
                for i = 1:36
                    output_holder(i) = sum( temp_data .* cos_imdct_long(i,:));                
                end
                
                %Windowing Operation
                if block_type(iter) == 0
                    output_holder = output_holder .* sin_window_0;                              

                elseif block_type(iter) == 1
                    output_holder = output_holder .* sin_window_1;                                    

                elseif block_type(iter) == 3
                    output_holder = output_holder .* sin_window_3;                                    

                end
            end               
            
            %Overlap Add Operation
            output_holder(1:18) = output_holder(1:18) + overlap_adder(channel,current_start:current_start+17);
            overlap_adder(channel,current_start:current_start+17) = output_holder (19:36);

            output_data(iter, current_start : current_start+17) = output_holder(1:18);                       
            current_start = current_start + 18;            
        end
    end
end        
end