function [lt,ap,ax] = plotter1(CrwData,DbsData,depths,aH)

%TODO preallocation

%extract T values
max_depth = max(depths);
T = max_depth - depths;

%extract crw data
CTR = CrwData.clineangle ;
ACPC = CrwData.acpcangle ;

%extract track info
%subtract or add?
nPass = size(DbsData.trackinfo,1);
LtTargPoint = zeros(1,nPass);
ApTargPoint = zeros(1,nPass);
AxTargPoint = zeros(1,nPass);
for i = 1:nPass
    if (DbsData.trackinfo(i,2) == 2)
        ApTargPoint(i) = CrwData.functargpoint(1) + 1000*DbsData.trackinfo(i,3);
    elseif (DbsData.trackinfo(i,2) == 3)
        ApTargPoint(i) = CrwData.functargpoint(1) - 1000*DbsData.trackinfo(i,3);
    end
    if (DbsData.trackinfo(i,4) == 2)
        LtTargPoint(i) = CrwData.functargpoint(2) + 1000*DbsData.trackinfo(i,5);
    elseif (Dbs.trackinfo(i,4) == 3)
        LtTargPoint(i) = CrwData.functargpoint(2) - 1000*DbsData.trackinfo(i,5);
    end
    AxTargPoint(i) = CrwData.functargpoint(3);
end

prevT = max_depth;
iPass = 1;
iPoint = 1;

lt = [];
ap = [];
ax = [];

x = [];
y = [];
z = [];

%subtract or add?
for i = 1:length(T)
    if (prevT < T(i) || i == length(T))
        fprintf('plotting pass %d\n',iPass)
        lH = plot3(aH,x,y,z,'-s');
        set(lH,'hittest','off');
        lt = [lt x];
        ap = [ap y];
        ax = [ax z];
        
        x = [];
        y = [];
        z = [];
        
        iPoint = 1;
        
        iPass = iPass + 1;
        x(iPoint) = LtTargPoint(iPass) -(T(i) * sind(CTR)) ; 
        y(iPoint) = (T(i) * cosd(ACPC) * cosd(CTR)) + ApTargPoint(iPass);
        z(iPoint) = (T(i) * sind(ACPC) * cosd(CTR)) + AxTargPoint(iPass);
    else
        x(iPoint) = LtTargPoint(iPass) -(T(i) * sind(CTR)) ; 
        y(iPoint) = (T(i) * cosd(ACPC) * cosd(CTR)) + ApTargPoint(iPass);
        z(iPoint) = (T(i) * sind(ACPC) * cosd(CTR)) + AxTargPoint(iPass);
    end
    iPoint = iPoint + 1;
    prevT = T(i);
end
