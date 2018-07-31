% in this code we do any manipulation of the data needed before any other codes

z = load(fullfile('..', 'data', 'TDB_12_Dry_z.mat'))

sl=(1:900)*0.25;
time=2:900;
topo=permute(z(time,:,:),[2 3 1]);
topoprev=permute(z(time-1,:,:),[2 3 1]);
dtopo=topo-topoprev;
dtopo2=dtopo;
RSLR=0.25-dtopo2;



for i=2:900;
    x= sl(i);
    topo = permute(z(i,:,:),[2 3 1]);
    topo(topo(:)<=x)=NaN;
    toposave(i,:,:)=permute(topo,[3,1,2]);
end
    %topo=permute(z(i,:,:),[2 3 1]);
    %(topo(:)==0)=NaN;
    %marsh is anything that is less than sea level and greater than 10mm
    %below sea level
    %strat= double(topo<=x);
    %topo(topo <=x) = NaN;
    %strat =(topo(:)==0)=NaN;



dz = z(2:end, :, :)-z(1:end-1,:,:);
histogram(dz(:))