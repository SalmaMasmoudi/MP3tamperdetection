function [output_huff M] = requantizer(input_huff, scalefac, scale_distro, block_type, blocksplit_flag, global_gain, subblock_gain, preflag, scalefac_scale, switch_point) 

% REQUANTIZER rescales frequency lines.
%   Frequency lines have to be reconstructed while paying special attention
%   to block_type, blocksplit_flag and switch_point. Because these
%   parameters control the organization of the scalefac parameter which
%   stores the scalefactors.
%   Input paramter   = 576 huffman decoded values.
%   Output Parameter = 576 Requantized values.

    % Variable Declaration:
    output_huff (1:576) = 0;
    pretab = double([0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 2 2 3 3 3 2 0]);  %Pre-tab array to be used, only when pretab = 1, for amplifying higher frequencies.
    M = [];
    
    %converting the input data types to double because the requantization
    %formula outputs decimal values and if it is fed paramters of integer
    %type, the output becomes 0.
    scalefac = cast(scalefac, 'double');
    global_gain = double(global_gain);
    subblock_gain = cast(subblock_gain, 'double');
    preflag = cast(preflag, 'double');
    block_type = cast(block_type, 'double');
    blocksplit_flag = cast(blocksplit_flag, 'double');
    switch_point = cast(switch_point, 'double');
    
    % Iterators
    cb = 1; % Critical Bands Variable ( value ranges from 1 to 21)     
    scale = 1; % Frequency Lines Iterator ( takes on values in the 1 to 576 range).
    
    % Scalefactors Rescaling
    if scalefac_scale == 0
        scalefac_multiplier = 0.5;
    else
        scalefac_multiplier = 1;
    end
    
    % Main Requantization Routine
    if (blocksplit_flag && block_type == 2)        
        if switch_point %mix block type. rescale 1st 8 cb using long blocks' formula
            C = 2 ^ (0.25 * (global_gain - 210));        
            while cb<=8            
                while ( scale>=scale_distro(cb,1) && scale<=scale_distro(cb,2))
                    D = - (scalefac_multiplier *( scalefac(cb,1) + preflag * pretab(cb)));                
                    output_huff(scale) = sign(input_huff(scale)) * (abs(input_huff(scale))^(4/3)) * C * (2^D);       

		    J = global_gain;
		    K = scalefac_multiplier *( scalefac(cb,1) + preflag * pretab(cb));

		    %info4frame = sprintf('Blocco mix per il valore numero %d nella critical band %d con scalefactor %d',scale,cb,K);
		    %fprintf(file,info4frame);
		    %fprintf(file,'\n');

		    %frame_counter gr ch (scale-1) 
		    v = [input_huff(scale) output_huff(scale) J K];
		    M = [M; v];

  		    scale = scale + 1;

                end
                cb = cb + 1;
            end
            max_cb = uint8(18);  %setting the maximum number of critical bands to be allowed.
        else
            max_cb = uint8(13);  %if ~switch_point then only short blocks i.e. cb = 1 to 12.
        end    
        %If switch_point  = 1 then cb will now be 9 else it will be 1.
        %rescale for short blocks here on till max_cb.
        for outer= cb:max_cb
            length_sb = (scale_distro(cb,2) - scale_distro(cb,1) + 1)/3; %Length of one window inside the cb.
            for window = 1:3
                A = 2 ^ (0.25 * (global_gain - 210 - (8 * subblock_gain(window))));
                for iter = 1:length_sb
                    B = - (scalefac_multiplier * scalefac(cb,window));
                    output_huff(scale) = sign(input_huff(scale)) * (abs(input_huff(scale))^(4/3)) * A * (2^B);

		    J = global_gain - (8 * subblock_gain(window));
		    K = scalefac_multiplier * scalefac(cb,window);

		    %info4frame = sprintf('Blocco short per il valore numero %d nella critical band %d e finestra %d con scalefactor %d',scale,cb,window,K);
		    %fprintf(file,info4frame);
		    %fprintf(file,'\n');

		    %frame_counter gr ch (scale-1) 
		    v = [input_huff(scale) output_huff(scale) J K];
		    M = [M; v];

		    scale = scale + 1;

                end
            end
            cb = cb + 1;
        end
    else
        % block_type is either 0,1 or 3 i.e. only long blocks. cb = 1:21
        C = 2 ^ (0.25 * (global_gain - 210));        
        while cb<=22            
            while ( scale>=scale_distro(cb,1) && scale<=scale_distro(cb,2))
                D = - (scalefac_multiplier *( scalefac(cb,1) + preflag * pretab(cb)));      
                output_huff(scale) = sign(input_huff(scale)) * (abs(input_huff(scale))^(4/3)) * C * (2^D);       

		J = global_gain;
		K = scalefac_multiplier *( scalefac(cb,1) + preflag * pretab(cb));
          
                %info4frame = sprintf('Blocco long per il valore numero %d nella critical band %d con scalefactor %d',scale,cb,K);
		%fprintf(file,info4frame);
		%fprintf(file,'\n');

		%frame_counter gr ch (scale-1) 
		v = [input_huff(scale) output_huff(scale) J K];
		M = [M; v];

		scale = scale + 1;

            end
            cb = cb + 1;
        end
    end
end
