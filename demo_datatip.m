function h = demo_datatip

    %// basic sample curve
    npts = 600 ;
    x = linspace(0,4*pi,npts) ;
    y = sin(x) ;

    %// plot
    h.fig = figure ;
    h.ax = axes ;
    h.plot = plot(x,y) ;

    %// simulate some event times
    time_events = x([25 265 442]) ; %// events type 1 at index 25, 265 and 422

    %// define the target line for the new datatip
    hTarget = handle(h.plot);

    %// Add the datatip array
    h.dtip = add_datatips( time_events , hTarget ) ;
end
    


function hdtip = add_datatips( evt_times , hTarget )
    %// retrieve the datacursor manager
    cursorMode = datacursormode(gcf);
    set(cursorMode, 'UpdateFcn',@customDatatipFunction);

    xdata = get(hTarget,'XData') ;
    ydata = get(hTarget,'YData') ;

    %// add the datatip for each event
    for idt = 1:numel(evt_times)
        hdtip(idt) = cursorMode.createDatatip(hTarget) ;
        set(hdtip(idt), 'MarkerSize',5, 'MarkerFaceColor','none', ...
                  'MarkerEdgeColor','r', 'Marker','o', 'HitTest','off');

        %// move it into the right place
        idx = find( xdata == evt_times(idt) ) ;%// find the index of the corresponding time
        pos = [xdata(idx) , ydata(idx) ,1 ];
        hdtip(idt).Position = pos;
        %update(hdtip(idt), pos);
    end
end

function output_txt = customDatatipFunction(~,evt)
    pos = get(evt,'Position');
    assignin(WS,'evt',evt);
    idx = get(evt,'DataIndex');
    output_txt = { ...
        '*** !! Event !! ***' , ...
        ['at Time : '  num2str(pos(1),4)] ...
        ['Value: '   , num2str(pos(2),8)] ...
        ['Data index: ',num2str(idx)] ...
                };
end