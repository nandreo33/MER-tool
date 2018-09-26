function export_point_data(handles)
%EXPORT_POINT_DATA
%   TODO in dev

section_path = getappdata(handles.traj_axes,'SectionPath');

t = APMReadData(section_path);

name = get(handles.name_disp,'String');
surgery = get(handles.surgery_disp,'String');
date = datestr(now,'yyyy-mm-dd_HH;MM;ss');

save([date '.mat'],'t');

end

