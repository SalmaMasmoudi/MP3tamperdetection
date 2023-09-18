function output_data = filterbank (input_data)

% Variable Definitions %
%--------------------------------------------------------------------------
u(1:512) = double(0);
holder = zeros(1,32);
output_data(1:4,1:576) = double(0);
global D cos_filterbank;
persistent fifo_v;
%--------------------------------------------------------------------------

if isempty (fifo_v)
    fifo_v = zeros(2,1024);
end

for iter = 1:4
    %decide channel to use the appropriate fifo_v
    if mod(iter,2) == 1;
        channel = 1;
    else
        channel = 2;
    end
    
    cur_st_index = 1;
    for inner = 1:18
        selected_samples  = cur_st_index:18:576;
        temp = input_data(iter,selected_samples);        
        fifo_v(channel, 65:1024) = fifo_v(channel, 1:960);
        fifo_v(channel, 1:64) = 0;
        
        for i = 1:64
            fifo_v(channel, i) = sum( temp .* cos_filterbank(i,:));            
        end
        
        %building vector u from fifo_v vectors.
        for i = 0:7
            for j = 0:31
            u( i*64 + j  + 1) = fifo_v(channel, i*128 + j  + 1);
            u( i*64 + 33 + j) = fifo_v(channel, i*128 + 97 + j);
            end
        end

        %windowing
        w = u .* D;
                
        for j = 0:31
            summ = 0;
            for i = 0:15
            summ = summ + w(j + 32 * i + 1);
            end
        holder(j+1) = summ;
        end
        
        output_index = cur_st_index * 32;
        output_data(iter, output_index - 31:output_index ) = holder;
        cur_st_index = cur_st_index + 1;
    end
end
end