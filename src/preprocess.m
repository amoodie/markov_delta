% in this code we do any manipulation of the data needed before any other codes

clear variables

z = load(fullfile('..', 'data', 'TDB_12_Dry_z.mat'));
z = z.z; % 900 = t, 455 = x, 391 = y

sl = (1:900) .* 0.25; % sea level at each time t
% time = 2:900; % shouldn't time start at 0 and we index it beyond that?
% topo = permute(z(time, :, :), [2, 3, 1]);
% topoprev = permute(z(time-1, :, :),[2, 3, 1]);
% dtopo = topo - topoprev;
% dtopo2 = dtopo;
% RSLR = 0.25 - dtopo2;
% 
% for i = 2:900
%     x = sl(i);
%     topo = permute(z(i,:,:),[2 3 1]);
%     topo(topo(:)<=x)=NaN;
%     toposave(i,:,:)=permute(topo,[3,1,2]);
% end

T = 0:900; % one element longer than scans
for t = T(2:end)
    slt = sl(t); % sea level at time t
    mart = squeeze( z(t, :, :) < slt ); % what is marine (below sl) at t
    z(t, mart) = NaN; % replace at identified indicies
end

dz = z(2:end, :, :) - z(1:end-1, :, :); % vectorized dz

nbins = 9;

dz16 = quantile(dz(:), 0.16); % 16th percentile
dz84 = quantile(dz(:), 0.84);

dz = dz( and(dz > dz16, dz < dz84) ); % trim the distribution to percentile

figure()
histogram(dz(:), nbins);

[hc] = histcounts(dz(:), nbins);