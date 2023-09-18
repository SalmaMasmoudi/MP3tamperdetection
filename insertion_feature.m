function [y,tab,Binvect1]= insertion_feature(file,x,tatoue,watermark,C)
load data.mat index_bg_region bg_region indice1 tab_len_frame
% insertion et collect des positions d'insertion
clc;
y=x;
g=1;
%message1=md5(file)
%pause
%message=message1(1:8)%length(message1)/4)

% tic
% for m=1:length(watermark)
%     m
%     
%                 ascii_msg(m)=double(watermark(m))
%                % pause
%                 msg(:,m)=+(dec2binvec(ascii_msg(m),8))
%               %  pause
% end     
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ascii_msg
%  msg
%  length(msg)
% pause
%  
%  [pp q]=size(msg)
%  pause
% xBin=1;
% for iBin = 1:q
%  for kBin = 1:pp
%    Binvect1(xBin)=msg(kBin,iBin);
%   xBin=xBin+1;
%  end
% end
Binvect1=watermark;
%pause
fr=1;

pq=length(Binvect1);
%pause
%indice1(100:pq+101)
%pause
ii=1;
pp=2;
length(indice1)
length(C)
%indice111=indice1(C(2:length(C)));
tr=1
% for kk=1:length(indice1)
%   
%     for ll=1:4
%       % if indice1(ll,kk)~=0
%        % indice111(kk)=indice1(ll,kk);
%        indice111(tr)=indice1(ll,kk);
%        tr=tr+1;
%       % end
%     end
% end
pos_ins11(1)=indice1(1);
while ((ii<=length(indice1))&&(pp<=pq))
    
    if ((indice1(ii)~= 0)&&(indice1(ii)~=pos_ins11(pp-1)))
 pos_ins11(pp)=indice1(ii);
 pp=pp+1;
    end
    ii=ii+1;
end
pos_ins11
%pause

while(g<=pq)
                      
                  % y(pos_ins2(g))=Binvect1(g)
                   g
                   pos_ins11(g)
                    freq_ins11= x(pos_ins11(g))
                   

                    freq_ins11(1)=Binvect1(1,g);
                              
                              %  freq_tatou1=freq_ins1(1);
                                ffreq(fr)=freq_ins11;
%tab(fr)=indice111(g);
tab(fr)=pos_ins11(g);
fr=fr+1;
                    % y(1,xxx)=freq_tatou1
%                     pause
                   % g=g+4
                   g=g+1;
                    %pause
                
end
% g
 tab
% pause


for jjj=1:length(tab)
   % for iii=1:size(tab,2)
    indice_t=tab(jjj);
    y(indice_t)=Binvect1(jjj);
   % end
end
%                 for jjj=1:size(pos_ins1,2)
%                     indice1=pos_ins2(jjj)
%                     pause
%     y(indice1)=ffreq(jjj);
% 
%                 end
toc
disp(sprintf('Total Time Spent In insertion %s : %f',toc));
%pause
 fid1 = Openmp3Write(tatoue);
   uint8(fwrite(fid1,y,'ubit1')');  %File Read Bit By Bit and converted to uint8 format for conserving memory
    disp('INSERTION COMPLETE');
   % disp(sprintf('Total Time Spent In Decoding %s : %f',file_name,total_time));
    save  data.mat index_bg_region bg_region tab Binvect1 watermark indice1 x
end