function ApmDataTable = build_apm_table(CrwData,DbsData,apm)
%BUILD_APM_TABLE
%
%TODO variable folder path, variable # of sections

N = 128;
startN = 1;
sections = startN:N;
for i = 1:length(sections)
    section = sections(i);
    t = APMReadData([apm '\GPi Left\Pass 1\C\Snapshot - 3600.0 sec ' num2str(section) '\WaveformData-Ch1.apm']);
    dist = t.drive_data.depth;
    channel = t.channels(1);
    FS = channel.sampling_frequency;
    start_trial = channel.start_trial;
    end_trial = channel.end_trial;
    disp(dist)
        % TODO PREALLOCATE THIS
    ApmDataTable.depth(section) = dist(2);
    ApmDataTable.start(section) = start_trial/FS;
    ApmDataTable.end(section) = end_trial/FS;
    ApmDataTable.section(section) = section;
end

[x,y,z] = plotter1(CrwData,ApmDataTable.depth);
ApmDataTable.lt = x;
ApmDataTable.ap = y;
ApmDataTable.ax = z;

end

