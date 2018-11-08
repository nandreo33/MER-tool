function export_point_data(handles)
%EXPORT_POINT_DATA
%   TODO in dev

section_path = getappdata(handles.traj_axes,'SectionPath');

[fpath,fname,fext] = fileparts(section_path)

t = APMReadData(section_path);

name = get(handles.name_disp,'String');
surgery = get(handles.surgery_disp,'String');
date = datestr(now,'yyyy-mm-dd_HH;MM;ss');

save([sprintf('%s',fname) '.mat'],'t');

end