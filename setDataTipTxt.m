function output_txt = setDataTipTxt(~,evt)
    pos = get(evt,'Position');
    idx = get(evt,'DataIndex');
    output_txt = { ...
        %'*** !! Event !! ***' , ...
        ['at Time : '  num2str(pos(1),4)] ...
        ['Value: '   , num2str(pos(2),8)] ...
        ['Data index: ',num2str(idx)] ...
                };
end