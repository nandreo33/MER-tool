function status = create_trs_template(Headers,cellIndex,File)
%{
CREATE_TRS_TEMPLATE
    writes Headers.trsHeaders starting at column A, row cellIndex
ARGS
    Headers: structure, contains templates from data\Headers.mat
    cellIndex: int, the row to begin writing the stim_track_headers array
    File: structure, with fields
        path: string, path to output file destination
        name: string, name of output file
        type: string, '.xls' or '.xlsx'
        full: string, [File.path File.name File.type]
RETURNS
    status: logical 1 on success, 0 on failure
%}
    
status = xlswrite(File.full,Headers.trsHeaders,1,['A' num2str(cellIndex)]);
end

