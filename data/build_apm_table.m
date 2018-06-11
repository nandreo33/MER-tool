function ApmDataTable = build_apm_table(apmPath)
%BUILD_APM_TABLE
%
%TODO variable # of sections

tF = dir([apmPath '\**\Waveform*.apm']);

folder = {tF.folder};
folder = natsort(folder); % library

N = size(folder,2)-1; %FIXME this ignores sec 0
startN = 1;
sections = startN:N;

% initialise very informative progress bar
w = waitbar(0,sprintf('Extracting APM data (1/%d)',N),'Name','Progress');
% remove any unintended formatting in progress bar text
myString = findall(w,'String','Starting Conversion');
set(myString,'Interpreter','none');

for i = 1:length(sections)
    waitbar(i/N,w,sprintf('Extracting APM data (%d/%d)',i,N));
    section = sections(i);
    path = string(strcat(folder(i+1),'\WaveformData-Ch1.apm'));
    t = APMReadData(path); %FIXME will this work?
    dist = t.drive_data.depth;
    disp(dist)
        % TODO PREALLOCATE THIS
    ApmDataTable.depth(section) = dist(2);
    ApmDataTable.path(section) = path;
end

close(w)
end

