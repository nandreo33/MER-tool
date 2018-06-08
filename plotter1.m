function [x,y,z] = plotter1(CrwData,depths)
max_depth = max(depths);
T = max_depth - depths;
CTR = CrwData.clineangle ;
ACPC = CrwData.acpcangle ;

LtTargPoint = CrwData.functargpoint(2);
ApTargPoint = CrwData.functargpoint(1);
AxTargPoint = CrwData.functargpoint(3);


for i = 1:length(T)
    x(i) = LtTargPoint -(T(i) * sind(CTR)) ; 
    y(i) = (T(i) * cosd(ACPC) * cosd(CTR)) + ApTargPoint;
    z(i) = (T(i) * sind(ACPC) * cosd(CTR)) + AxTargPoint;
end
