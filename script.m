tF = dir('E:/nandreo33/Downloads/MER_ForNathanMax/MER_ForNathanMax/First_Last/GPi Left/**/Waveform*.apm');
folder = cell(1,size(tF,1));

for i = 1:size(tF,1)
    folder(i) = {tF(i).folder};
end

StF = (folder);