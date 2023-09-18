function output_data = stereo_processing(input_data, intensity_stereo, ms_stereo)

if ms_stereo
	output_data(1,:) = ( input_data(1,:) + input_data(2,:) ) / sqrt(2);
	output_data(2,:) = ( input_data(1,:) - input_data(2,:) ) / sqrt(2);
	output_data(3,:) = ( input_data(3,:) + input_data(4,:) ) / sqrt(2);
	output_data(4,:) = ( input_data(3,:) - input_data(4,:) ) / sqrt(2);
end

if intensity_stereo
    disp('intensity stereo!!!');
end
end