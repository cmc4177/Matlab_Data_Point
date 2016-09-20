%% TC-48-20 Data Plotter

clear all; close all; clc
% Set and Obtain Screen Size
set(0,'Units','pixels')
Pix_SS = get(0,'screensize');
%Position Center At 90 percent screen in vector form :[left bottom width height]
width = Pix_SS(3)*.90;
height = Pix_SS(4)*.90;
taskbar = 40;
left = (Pix_SS(3)-width-Pix_SS(1))/2;
bottom = (Pix_SS(4)-height-Pix_SS(2))/2+taskbar;
pos_size = [left bottom width height-taskbar];

fid = -1;
errmsg = '';
while fid < 0 
   disp(errmsg);
   [FileName,PathName,FilterIndex] = uigetfile('*.txt','TC-48-20 Data File');
   path = [PathName FileName];
   [fid,errmsg] = fopen(path);
end
%specify incoming formats for first row of headers
formatSpec = '%s%s%f%f%f%f%f';
% create a matlab table
T = readtable(path,'Delimiter','\t', 'MultipleDelimsAsOne',true, ...
    'Format',formatSpec);
%close file now that finished reading from it
fclose(fid);

% %Reference variable names
% data = T.Properties.VariableNames;
% T(1) =  Date; string
% T(2) = Time; string
% T(3) = elapsed time; sec
% T(4) = temp sensor 1; degrees C
% T(5) = temp sensor 2; degrees C
% T(6) = set temp; degrees C
% T(7) = percent power; %

time = table2array(T(:,3)); %elapsed time
temp = table2array(T(:,4)); % temp sensor 1
settemp = table2array(T(:,6)); % set temp
power = table2array(T(:,7)); % power %

%Open a new figure and name it
fig = figure('OuterPosition',pos_size,'PaperPositionMode','auto');
fig.Name = [FileName '_' 'TE-127-1.4-2.5P'];
%Changes Paper Print Orientation to landscape on a per figure basic
orient landscape
%Output plots to called figure
subplot(2,2,3:4)
p(1) = plot(time,temp,'LineWidth',3.0); title({'Temperature','Sensor 1'});xlabel('Time (sec)');ylabel('Temperature (°C)'); grid on;
subplot(2,2,1)
p(2) = plot(time,power,'LineWidth',3.0); title({'Power','Setting'});xlabel('Time (sec)');ylabel('Power (%)'); grid on;
subplot(2,2,2)
p(3) = plot(time,settemp,'LineWidth',3.0); title({'Set','Temperature'});xlabel('Time (sec)');ylabel('Temperature (°C)'); grid on;
name = [temp,power,settemp];

%% Find if there are multiple set points and correct for them; Work in Progress
% changes = logical(diff(settemp));
% 
% cidx = find(changes == 1)
% if isempty(cidx)
%     min = settemp(1);
% else
%     cidx = find(changes == 0)
%     for i=1:length(cidx)
%         settemp(cidx)
%     end
% end

%% Create Datatips Programattically 
% First get the figure's data-cursor mode, activate it, and set some of its properties
cursorMode = datacursormode(fig);
set(cursorMode, 'enable','on', 'UpdateFcn',@setDataTipTxt);
% Note: the optional @setDataTipTxt is used to customize the data-tip's appearance
state = input('Are you cooling(1) or restoring to room temp(2): ');
mini = input('Please enter min desired temp (°C): \n');
room = input('Please enter room temp (°C): \n');
idx_min = find( name(:,1) <= mini,1) ;%// find the index of the corresponding time
idx_room = find( name(:,1) >=room,1) ;%// find the index of the corresponding time
ch = 1;
if isempty(idx_min) % check to make sure it actually reached setpoint if not plots the lowest
    ch = 2;
    idx_min = find(name(:,1)== min(name(:,1)),1);
    if isempty(idx_room) % check to make sure it actually reached room if not plots the max temp
    ch = 4;
    idx_room = find(name(:,1)== max(name(:,1)),1);
    end
else if isempty(idx_room) % check to make sure it actually reached room if not plots the max temp
    ch = 3;
    idx_room = find(name(:,1)== max(name(:,1)),1);
    end
end
    
% Note: the following code was adapted from %matlabroot%\toolbox\matlab\graphics\datacursormode.m
% And I adapted it from the website further; Clair Cunningham
for i = 1:length(p)
% Create a new data tip
hTarget = handle(p(i));
hDatatip = cursorMode.createDatatip(hTarget);
 
% Create a copy of the context menu for the datatip:
set(hDatatip,'UIContextMenu',get(cursorMode,'UIContextMenu'));
set(hDatatip,'HandleVisibility','off');
set(hDatatip,'Host',hTarget);
%set(hDatatip,'DisplayStyle','datatip');
 
% Set the data-tip orientation to top-right rather than auto
set(hDatatip,'OrientationMode','auto');
%set(hDatatip,'Orientation','topright');
set(hDatatip,'Draggable','off');
 
% Update the datatip marker appearance
set(hDatatip, 'MarkerSize',5, 'MarkerFaceColor','none', ...
              'MarkerEdgeColor','k', 'Marker','o', 'HitTest','off');
 

% Move the datatip to the crossover point of min desired temp
hDatatip.Position = [time(idx_min) , name(idx_min,i) ,1 ];
% update(hDatatip, position); update function no longer accepted
%Settling Time
end

for i = 1:length(p)
hTarget = handle(p(i));
hDatatip = cursorMode.createDatatip(hTarget);
 
% Create a copy of the context menu for the datatip:
set(hDatatip,'UIContextMenu',get(cursorMode,'UIContextMenu'));
set(hDatatip,'HandleVisibility','off');
set(hDatatip,'Host',hTarget);
%set(hDatatip,'DisplayStyle','datatip');
 
% Set the data-tip orientation to top-right rather than auto
set(hDatatip,'OrientationMode','auto');
%set(hDatatip,'Orientation','topright');
set(hDatatip,'Draggable','off');
 
% Update the datatip marker appearance
set(hDatatip, 'MarkerSize',5, 'MarkerFaceColor','none', ...
              'MarkerEdgeColor','k', 'Marker','o', 'HitTest','off');
 
% Move the datatip to the crossover point of room temp

hDatatip.Position = [time(idx_room) , name(idx_room,i) ,1 ];
% update(hDatatip, position); update function no longer accepted

end

%% Output time to cool or time to raise to room temp
time_cool = time(idx_min)-time(idx_room);
time_warm = time(idx_room)-time(idx_min);
% if time_cool < 0 | time_warm <0
%     fprintf('Wrong direction of heat transfer selected now exiting');
%     break;
% else
% end
switch ch
    case 1
    switch state
        case 1
            fprintf('Time to cool to desired temp from room: %.3g (sec) or %.3g (min).\n',time_cool,time_cool/60);
            mTextBox = uicontrol('style','text');
            set(mTextBox,'String',['Time to cool to desired min temp from room: ' num2str(time_cool) ' (sec) or ' num2str(time_cool/60) ' (min).']);
            set(mTextBox,'Position',[width/2-left height/5 width*0.13360053440213760855043420173681 height*0.04920049200492004920049200492005])
        case 2
            fprintf('Time to warm to room temp from desired: %.3g (sec) or %.3g (min).\n',time_warm,time_warm/60);
            mTextBox = uicontrol('style','text');
            set(mTextBox,'String',['Time to warm from desired min temp: ' num2str(time_warm) ' (sec) or ' num2str(time_warm/60) ' (min).']);
            set(mTextBox,'Position',[width/2-left height/5 width*0.13360053440213760855043420173681 height*0.04920049200492004920049200492005])
    end
    case 2
        switch state
        case 1
            fprintf('Time to cool to actual min temp from room: %.3g (sec) or %.3g (min).\n',time_cool,time_cool/60);
            mTextBox = uicontrol('style','text');
            set(mTextBox,'String',['Time to cool to actual min temp from room: ' num2str(time_cool) ' (sec) or ' num2str(time_cool/60) ' (min).']);
            set(mTextBox,'Position',[width/2-left height/5 width*0.13360053440213760855043420173681 height*0.04920049200492004920049200492005])
        case 2
            fprintf('Time to warm to room temp from min: %.3g (sec) or %.3g (min).\n',time_warm,time_warm/60);
            mTextBox = uicontrol('style','text');
            set(mTextBox,'String',['Time to warm to room temp from min: ' num2str(time_warm) ' (sec) or ' num2str(time_warm/60) ' (min).']);
            set(mTextBox,'Position',[width/2-left height/5 width*0.13360053440213760855043420173681 height*0.04920049200492004920049200492005])
        end
    case 3
        switch state
        case 1
            fprintf('Time to cool to desired min temp from room: %.3g (sec) or %.3g (min).\n',time_cool,time_cool/60);
            mTextBox = uicontrol('style','text');
            set(mTextBox,'String',['Time to cool to desired min temp from room: ' num2str(time_cool) ' (sec) or ' num2str(time_cool/60) ' (min).']);
            set(mTextBox,'Position',[width/2-left height/5 width*0.13360053440213760855043420173681 height*0.04920049200492004920049200492005])
        case 2
            fprintf('Time to warm to max "room" temp from min: %.3g (sec) or %.3g (min).\n',time_warm,time_warm/60);
            mTextBox = uicontrol('style','text');
            set(mTextBox,'String',['Time to warm to max "room" temp from min: ' num2str(time_warm) ' (sec) or ' num2str(time_warm/60) ' (min).']);
            set(mTextBox,'Position',[width/2-left height/5 width*0.13360053440213760855043420173681 height*0.04920049200492004920049200492005])
        end
    case 4
        switch state
        case 1
            fprintf('Time to cool to actual min temp from room: %.3g (sec) or %.3g (min).\n',time_cool,time_cool/60);
            mTextBox = uicontrol('style','text');
            set(mTextBox,'String',['Time to cool to actual min temp from room: ' num2str(time_cool) ' (sec) or ' num2str(time_cool/60) ' (min).']);
            set(mTextBox,'Position',[width/2-left height/5 width*0.13360053440213760855043420173681 height*0.04920049200492004920049200492005])
        case 2
            fprintf('Time to warm to max "room" temp from min: %.3g (sec) or %.3g (min).\n',time_warm,time_warm/60);
            mTextBox = uicontrol('style','text');
            set(mTextBox,'String',['Time to warm to max "room" temp from min: ' num2str(time_warm) ' (sec) or ' num2str(time_warm/60) ' (min).']);
            set(mTextBox,'Position',[width/2-left height/5 width*0.13360053440213760855043420173681 height*0.04920049200492004920049200492005])
        end
end

%% Output to Picture
set(fig,'PaperPositionMode', 'manual', 'PaperUnits','Inches', 'Paperposition',[0.0 0.0 11 8.5]) 
name = [strrep(fig.Name,' ','_')];
print(fig,'-dsvg','-painters',[PathName name '.svg']); % Prints out svg format
print(fig,'-dpdf','-painters',[PathName name '.pdf']); % Prints out pdf format