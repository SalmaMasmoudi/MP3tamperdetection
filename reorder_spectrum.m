function out_data = reorder_spectrum(input_data, scale_distro, switch_point)
%REORDER_SPECTRUM
%   This module re-orders the critical bands using short blocks. It skips
%   the first 36 frequency lines i.e. 8 long blocks in case when mixed
%   block types are used.

    out_data(1:576) = 0;
    if switch_point
        %Output The First 36 values without any reordering.
        out_data(1:36) = input_data(1:36);
        %Reorder the 3 windows now from input sample 37 onwards.
        cb = 9;
        cb_max = 17;
    else
        cb = 1;
        cb_max = 12;
    end
    while cb<=cb_max
        %Take Samples From input_data equal to scale_distro
        temp_data = input_data(scale_distro(cb,1):scale_distro(cb,2));
        length_cb = numel(temp_data);
        length_window = length_cb/3;
        %Main Reordering Algorithm
        reordered_temp_data = zeros (1, length_cb);
        reordered = 0; % No. of frequency lines re-ordered.
        k = 1;
        while reordered ~= length_cb
            i = k:length_window:length_cb;
            reordered_temp_data( reordered+1 : reordered+3)= temp_data(i);
            k = k+1;
            reordered = reordered + 3;
        end
        out_data(scale_distro(cb,1):scale_distro(cb,2)) = reordered_temp_data;
        cb = cb+1;
    end 
end