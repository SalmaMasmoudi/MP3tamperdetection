
function [is_double_compressed, previous_bitrate_est, dist] = MP3_double_encoding_detector(infile, path_to_lame, plot)

if nargin<3
    plot = 0;
end

training_file = 'knn_training_data.mat';
assert(exist(infile,'file')>0,sprintf('Cannot find file %s\n',infile));
assert(exist(path_to_lame,'file')>0,sprintf('Cannot find Lame executable, expected position: %s\n',path_to_lame));
path_to_lame_log = './';

addpath(genpath(cd));

% Main directory
[main_dir filename dummy] = fileparts(infile);
decfile = fullfile(main_dir,[filename '.wav']);

%%%% STEP 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We use Parameter_extractor to:                                                                                    %
% 	1) Obtain the quantization pattern, stored in the .mat with the same filename of the input                   %
%   2) Obtain the decoded PCM signal, returned by the function, with n samples cutted from the front             %
%	3) Obtain the quantized MDCT coefficient, stored in the same .mat, affected by double-compressione forgeries %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[file_path file_name file_ext] = fileparts(infile);

% Call Matlab MP3 decoder (© by Ahmed Hassan)
[PCM fs bitrate original_mat] = Parameter_extractor(infile);

%% Cut some samples for performing calibration
n=10; % number of samples to cut (can be any value, small values are suggested)

if DecompressAudio(infile, decfile, path_to_lame)
    [y fs] = wavread(decfile);
    delete(decfile);
else
    error('Cannot decompress file %s.\n',infile);
end
y_cutted = y(n+1:end,:);

temp = fullfile(main_dir, 'temp.wav');

wavwrite(y_cutted,fs,temp);

%%%% STEP 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we use the LAME_encoders's filterbank and MDCT trasnform and we extract the unquantized MDCT coefficients,    %
% 	obtained by the TEMP.wav files created in step 1, which we can delete after the extraction.                     %
% Then we quantize the extracted unquantized values with the quantization pattern from the original double-         %
% 	compressed file.                                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[cutted_mat] = Extract_MDCT_unquantized(temp,bitrate, path_to_lame, path_to_lame_log, main_dir);
delete(temp);

%% Lame add a number of coefficients at the end for "flush" all the values,
%% so we cut

if(length(cutted_mat) ~= length(original_mat))
	cutted_mat = cutted_mat(1:end-(length(cutted_mat) - length(original_mat)));
end

gain = (original_mat(:,3) - 210) / 4;
scale = original_mat(:,4);
x = double(gain - scale);

new_quantized = sign(cutted_mat) .* round((((abs(cutted_mat)) .* 2 .^(-x))).^(3/4));

%%%% STEP 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We can now plot the quantized values stored in the original double-compressed file and the new quantized values    %
%	just computed.							                                             %
% The relative histograms will be saved 									     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

H_obs = double(hist(original_mat(:,1),-1000:1000));
H_shf = double(hist(new_quantized,-1000:1000));

if(plot)
    figure();
    subplot(1,2,1);
    bar(H_obs);
    xlim( [700,1300]);xlabel('Quantized Coefficient Value');
    ylim( [0,1500]);
    title('Examined file','FontSize',14);

    subplot(1,2,2);
    bar(H_shf);
    xlim( [700,1300]);xlabel('Quantized Coefficient Value');
    ylim( [0,1500]);
    title('Estimated with calibration','FontSize',14);

end

%%%% STEP 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We compute the distance between the two histograms    		                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dist = Distances(H_obs,H_shf);

is_double_compressed = dist(2) >= 0.0126;
if is_double_compressed %put check on double compression detection
    fprintf('Double MP3 compression detected!\n');    
    fprintf('\tChi-Square Distance = %.4f  ----  Kullback-Leibler Divergence = %.4f\n',dist(2),dist(1));    
    test = [NaN 0 bitrate dist(1) dist(2)];
    [previous_bitrate_est] = bitrate_classification(test, training_file);
    fprintf('\tPrevious bitrate estimate: %.d\n\n',previous_bitrate_est);
else
    previous_bitrate_est = NaN;
    fprintf('No double MP3 compression detected\n');    
    fprintf('\tChi-Square Distance = %.4f  ----  Kullback-Leibler Divergence = %.4f\n\n',dist(2),dist(1));    
    
end


end

