function [val_x val_y length_code] = huffman_parser ( input_code, table )

    match_flag = 0;
    i = 1;    
    table_length = numel(table(:,1));
    while ( ~match_flag && i<=table_length )
        %Get Length of Ith code in Table
        length_i = table(i,3);
        if (input_code(1:length_i) == table(i, 4:length_i+3))
            %Code Match Found. No Need To Look Through Rest Of The Table As
            %We Are Using HUFFMAN CODING.
            val_x = table(i,1);
            val_y = table(i,2);
            length_code = table(i,3);
            length_code = double(length_code);
            match_flag = 1;
        else
            i = i + 1;
        end
    end
end