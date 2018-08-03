% in this code we evaluate the markov model in a single stratigraphic column

clear variables

%% load vars
disp('loading...')
mm = load(fullfile('..', 'data', 'markov_mat.mat'));
be = mm.mm.be; % bin edges
bc = mm.mm.bc; % bin centers
mm = mm.mm.mm; % markov matrix

%% aux vars
beidx = cumsum(be);
mmcs = cumsum(mm, 1, 'reverse');

T = 1:900;
zs = [];

figure()
[x, y] = meshgrid(bc, bc);
surface(x, y, mmcs, 'EdgeColor', 'k')


%% evaluate the model 1 time
RSLR = 0.25; % need to make sure to add RSLR on each step to make a net aggradation
BL = 0; % base level
z = 0; 
dz = 0; % random value for initial from within interval

figure()
avulct = 0;

for t = T
    % store
    zs(t) = z;
    ts(t) = t;
    
    % find the bin
    cidx = find(dz <= be, 1, 'first') - 1; % first greater than minus one is idx

    % generate a random number in interval [0 1]
    newrand = rand(1);

    % determine which prob bin it falls in to
    dzidx = find(mmcs(:, cidx) < newrand, 1, 'first');
    if isempty(dzidx)
        dzidx = 1; % SLOPPY HANDLING of case
    end
    dz = bc(dzidx);
    
    % go that far in z
    z = z + dz;
    
    % add RSLR in z
    z = z + RSLR;
    
    % add some random chance of avulsion? (by selecting a new dz randomly?)
%     b = 0.05;
%     D = 0.2;
%     arand = b*rand(1,1).^(-1+D);
%     athresh = 0.03;
%     if arand > athresh
%         if arand > length(bc)
%             arand = 26;
%         else
%             ceil(arand);
%         end
%         dz = bc(ceil(arand));
%         avulct = avulct + 1;
%     end
    
%     stairs(ts, zs)
%     drawnow
    
end

%% load strat columns to compare
figure()
load(fullfile('..', 'data', 'rcols.mat'))
hold on

rcols.ts = 1:size(rcols.strat, 1);
fitvars = size(rcols.strat);
m = size(rcols.strat);
for p = 1:size(rcols.strat, 2)
    stairs(rcols.ts, rcols.strat(:, p), 'Color', [0.8 0.8 0.8])
    fitvars = polyfit(rcols.ts', rcols.strat(:,p), 1);
    m(p) = fitvars(1);
end

average_slope = nanmean(m);
stairs(ts, zs, 'Color', 'red', 'LineWidth', 2)
fitvars_b = polyfit(ts, zs, 1);
m_b = fitvars_b(1);

xlabel('Time (hours)')
ylabel('Elevation (mm)')
text(0.3,0.7, ['model slope=' num2str(round(m_b,2))], 'units', 'normalized', 'fontsize', 16)
text(0.45, 0.17, ['expt. mean slope =' num2str(round(average_slope,2))], 'units', 'normalized', 'fontsize',16)

j=1;
 

%% evaluate 1000 times and compute stats