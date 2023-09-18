function[D1, D2,D3,D4]=distance(out_MDCT1,out_MDCT2)
taille=min(length(out_MDCT1),length(out_MDCT2));
out_MDCT1=out_MDCT1(:,2:taille);
out_MDCT2=out_MDCT2(:,2:taille);
Dist=out_MDCT1-out_MDCT2;
j=1;
i=1;
while (i<=size( Dist,2)/576)
    D1(i,1:576)=Dist(1,j:j+576-1);
    D2(i,1:576)=Dist(2,j:j+576-1);
    D3(i,1:576)=Dist(3,j:j+576-1);
    D4(i,1:576)=Dist(4,j:j+576-1);
    i=i+1;
    j=j+576;
end
end
