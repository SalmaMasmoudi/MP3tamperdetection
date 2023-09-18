function output_data = frequency_inverter(input_data)
output_data(1:4,1:576) = 0;
inv_val = [1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1];
for iter = 1:4
    for inner = 0:31
        if mod(inner,2)==1
            output_data(iter, inner*18+1:inner*18+18) = inv_val .* input_data(iter, inner*18+1:inner*18+18);
        else
            output_data(iter, inner*18+1:inner*18+18) = input_data(iter, inner*18+1:inner*18+18);
        end
    end
end
end