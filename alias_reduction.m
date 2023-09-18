function output_data = alias_reduction( input_data , block_type, blocksplit_flag, switch_point)
% ALIAS_REDUCTION: Introduces alias into the signal taken out during
% encoding
%       cs & ca coeffecients have been hardcoded instead on calculating
%       them on each call.
%       affected_values indicates the indices in two sub-bands in which
%       alias has to be introduced. (1st row = 1st sub-band affected
%       indices). (2nd row = 2nd sub-band affected indices).
%       Parameters block_type, blocksplit_flag & switch_point control the
%       frequency lines to be processed via variable max_limit.

cs = [0.8575    0.8817    0.9496    0.9833    0.9955    0.9992    0.9999    1.0000];
ca = [-0.5145  -0.4717   -0.3134   -0.1819   -0.0946   -0.0410   -0.0142   -0.0037];
affected_values = [18 17 16 15 14 13 12 11; 19 20 21 22 23 24 25 26];

for iter = 1:4
    current_start36 = 1;
    if blocksplit_flag(iter) && block_type(iter) == 2 && switch_point(iter) %alias correction only the first 36 frequency lines
        max_limit = 36;    
    elseif blocksplit_flag(iter) && block_type(iter) == 2 && ~switch_point(iter) %no alias correction required.
        max_limit = 0;
    else
        max_limit = 558;
    end
    while current_start36 < max_limit
        % Select 36 values.        
        temp = input_data (iter, current_start36:current_start36+35);
        if (temp == zeros(1,36)) %If all frequency lines are zero, no need to correct alias.
        else
            for iter_inner = 1:8
                in1 = temp(affected_values(1,iter_inner));
                in2 = temp(affected_values(2,iter_inner));
                var_value1 = cs(iter_inner) * in1 - ca(iter_inner) * in2; 
                var_value2 = cs(iter_inner) * in2 + ca(iter_inner) * in1; 
                temp(affected_values(1,iter_inner)) = var_value1;
                temp(affected_values(2,iter_inner)) = var_value2;
            end 
            input_data (iter, current_start36:current_start36+35) = temp;
        end
        % Update Current Start Index
        current_start36 = current_start36 + 18;
    end    
end
output_data = input_data;
end