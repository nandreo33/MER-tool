CrwData = extract_crw_data('/home/max/Research/Left GPI.crw');
DbsData = load('/home/max/Research/Barfield-LGPI.mat');

fig = figure;
[x,y,z] = plotter1(CrwData,DbsData);
T = str2double(DbsData.data1(:,2)');
depth = max(T) - [0 T];
plot3(x,y,z)
title('Patient Name: ' + string(DbsData.firstname) + ' ' + string(DbsData.middlename) + ' ' + string(DbsData.lastname) + newline + 'Surgery: ' + string(DbsData.surgery));
dcm_obj = datacursormode(fig);
set(dcm_obj,'UpdateFcn',{@myupdatefcn,depth})


function [txt] = myupdatefcn(~,event_obj,depth)
% Customizes text of data tips
pos = get(event_obj,'Position');
I = get(event_obj, 'DataIndex');
txt = {['LT: ',num2str(pos(1))],...
       ['AP: ',num2str(pos(2))],...
       ['AX: ',num2str(pos(3))],...
       ['Depth: ',num2str(depth(I))],...
       ['Data Index: ', num2str(I)],};
end