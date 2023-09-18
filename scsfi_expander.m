function scsfi = scsfi_expander(func_var)
    scsfi = uint8(zeros(2,21));
    for ch=1:2
        scsfi(ch,1:6) = func_var (ch,1);
        scsfi(ch,7:11) = func_var (ch,2);
        scsfi(ch,12:16) = func_var (ch,3);
        scsfi(ch,17:21) = func_var (ch,4);
    end
end