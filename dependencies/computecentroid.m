%% extracted from std_dipoleDensity.m
function dipole = computecentroid(alldipoles)
max_r = 0;
len = length(alldipoles);
dipole.posxyz = [ 0 0 0 ];
dipole.momxyz = [ 0 0 0 ];
dipole.rv = 0;
ndip = 0;
count = 0;
numNaN = 0;
warningon = 1;
for k = 1:len 
    if size(alldipoles(k).posxyz,1) == 2
        if all(alldipoles(k).posxyz(2,:) == [ 0 0 0 ])
            alldipoles(k).posxyz(2,:) = [];
            alldipoles(k).momxyz(2,:) = [];
        end;
    end;
    if ~isempty(alldipoles(k).posxyz)
        dipole.posxyz = dipole.posxyz + mean(alldipoles(k).posxyz,1);
        dipole.momxyz = dipole.momxyz + mean(alldipoles(k).momxyz,1);
        if ~isnan(alldipoles(k).rv)
            dipole.rv = dipole.rv + alldipoles(k).rv;
        else
            numNaN = numNaN+1;
        end
        count = count+1;
    elseif warningon
        disp('Some components do not have dipole information');
        warningon = 0;
    end;
end
dipole.posxyz = dipole.posxyz/count;
dipole.momxyz = dipole.momxyz/count;
dipole.rv     = dipole.rv/(count-numNaN);
if isfield(alldipoles, 'maxr')
    dipole.maxr = alldipoles(1).max_r;
end