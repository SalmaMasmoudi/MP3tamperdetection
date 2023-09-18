function [val_0 val_1 val_2 val_3 length_code] = count1_parser( input_code , select_bit)
    persistent count_tableA count_tableB;
    match_flag = 0;
    if (select_bit == 0)
        if isempty(count_tableA)
            count_tableA(1,1:11) = [0 0 0 0 1 1 0 0 0 0 0];
            count_tableA(2,1:11) = [0 0 0 1 4 0 1 0 1 0 0];
            count_tableA(3,1:11) = [0 0 1 0 4 0 1 0 0 0 0];
            count_tableA(4,1:11) = [0 0 1 1 5 0 0 1 0 1 0];
            count_tableA(5,1:11) = [0 1 0 0 4 0 1 1 0 0 0];
            count_tableA(6,1:11) = [0 1 0 1 6 0 0 0 1 0 1];
            count_tableA(7,1:11) = [0 1 1 0 5 0 0 1 0 0 0];
            count_tableA(8,1:11) = [0 1 1 1 6 0 0 0 1 0 0];
            count_tableA(9,1:11) = [1 0 0 0 4 0 1 1 1 0 0];
            count_tableA(10,1:11)= [1 0 0 1 5 0 0 0 1 1 0];
            count_tableA(11,1:11)= [1 0 1 0 5 0 0 1 1 0 0];
            count_tableA(12,1:11)= [1 0 1 1 6 0 0 0 0 0 0];
            count_tableA(13,1:11)= [1 1 0 0 5 0 0 1 1 1 0];
            count_tableA(14,1:11)= [1 1 0 1 6 0 0 0 0 1 0];
            count_tableA(15,1:11)= [1 1 1 0 6 0 0 0 0 1 1];
            count_tableA(16,1:11)= [1 1 1 1 6 0 0 0 0 0 1];
            count_tableA = int16(count_tableA);
        end
        temp_iter=1;
        while (match_flag==0 && temp_iter<=16)
            length_code = count_tableA(temp_iter,5);
            if (input_code(1:length_code) == count_tableA(temp_iter, 6:length_code+5))
                match_flag = 1;
                val_0 = count_tableA(temp_iter,1);
                val_1 = count_tableA(temp_iter,2);
                val_2 = count_tableA(temp_iter,3);
                val_3 = count_tableA(temp_iter,4);
                length_code = double (count_tableA(temp_iter,5));
            else
                temp_iter = temp_iter+1;
            end               
        end
    else
        length_code = double(4);
        if isempty(count_tableB)
            count_tableB(1,1:8) = [0 0 0 0 1 1 1 1];
            count_tableB(2,1:8) = [0 0 0 1 1 1 1 0];
            count_tableB(3,1:8) = [0 0 1 0 1 1 0 1];
            count_tableB(4,1:8) = [0 0 1 1 1 1 0 0];
            count_tableB(5,1:8) = [0 1 0 0 1 0 1 1];
            count_tableB(6,1:8) = [0 1 0 1 1 0 1 0];
            count_tableB(7,1:8) = [0 1 1 0 1 0 0 1];
            count_tableB(8,1:8) = [0 1 1 1 1 0 0 0];
            count_tableB(9,1:8) = [1 0 0 0 0 1 1 1];
            count_tableB(10,1:8)= [1 0 0 1 0 1 1 0]; 
            count_tableB(11,1:8)= [1 0 1 0 0 1 0 1];
            count_tableB(12,1:8)= [1 0 1 1 0 1 0 0];
            count_tableB(13,1:8)= [1 1 0 0 0 0 1 1];
            count_tableB(14,1:8)= [1 1 0 1 0 0 1 0];
            count_tableB(15,1:8)= [1 1 1 0 0 0 0 1];
            count_tableB(16,1:8)= [1 1 1 1 0 0 0 0];
            count_tableB = int16(count_tableB);
        end
        temp_iter=1;
        while (match_flag==0 && temp_iter<=16)
            if (input_code(1:length_code) == count_tableB(temp_iter, 5:8))
                match_flag = 1;
                val_0 = count_tableB(temp_iter,1);
                val_1 = count_tableB(temp_iter,2);
                val_2 = count_tableB(temp_iter,3);
                val_3 = count_tableB(temp_iter,4);                
            else
                temp_iter = temp_iter+1;
            end               
        end
    end
end