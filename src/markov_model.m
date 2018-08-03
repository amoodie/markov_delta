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

% figure()
% [x, y] = meshgrid(bc, bc);
% surface(x, y, mmcs, 'EdgeColor', 'k')


%% evaluate the model 1 time
RSLR = 0.25; % need to make sure to add RSLR on each step to make a net aggradation
BL = 0; % base level
z = 0; 
dz = 0; % random value for initial from within interval

colfig = figure();
box on
hold on
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
    
%     stairs(ts, zs)
%     drawnow
    
end

%% make figure for comparing models and data

% loop model elevation for strat
m_strat = NaN(size(zs)); % preallocate
m_strat(end) = zs(end);
for t = T(end-1:-1:1)
    m_strat(t) = min([zs(t), m_strat(t+1)]);
    
end

% plot the columsn from experiment
load(fullfile('..', 'data', 'rcols.mat'))
rcols.ts = T;
fitvars = size(rcols.rxs);
m = size(rcols.rxs);
for p = 1:size(rcols.rys, 1)
    stairs(rcols.ts, rcols.strat(:, p), 'Color', [0.8 0.8 0.8])
    fitvars = polyfit(rcols.ts', rcols.strat(:,p), 1);
    m(p) = fitvars(1);
end

average_slope = nanmean(m);
stairs(T, m_strat, 'Color', 'red', 'LineWidth', 2)
fitvars_b = polyfit(ts, zs, 1);
m_b = fitvars_b(1);


%% do gaussian distribution model
figure()
sigma = 2;
center = 0;
[x, y] = meshgrid(be, be);
gaus_mat = fspecial('gaussian', 29, sigma);
gaus_mat = gaus_mat(10:end, 10:end);
gaus_mat = gaus_mat ./ sum(sum(gaus_mat));

surf(x, y, gaus_mat);
xlabel('next state', 'FontSize', 14)
ylabel('current state', 'FontSize', 14)
xlim([min(bc), max(bc)])
ylim([min(bc), max(bc)])
cb = colorbar;
cb.Label.String = 'probability';
cb.Label.FontSize = 14;
caxis([0, max(max(gaus_mat))])
view([0 90])
axis square

RSLR = 0.25; % need to make sure to add RSLR on each step to make a net aggradation
BL = 0; % base level
gz = 0; 
gdz = 0; % random value for initial from within interval
for t = T
    % store
    gzs(t) = gz;
    gts(t) = t;
    
    % find the bin
    cidx = find(gdz <= be, 1, 'first') - 1; % first greater than minus one is idx

    % generate a random number in interval [0 1]
    newrand = rand(1);

    % determine which prob bin it falls in to
    dzidx = find(mmcs(:, cidx) < newrand, 1, 'first');
    if isempty(dzidx)
        dzidx = 1; % SLOPPY HANDLING of case
    end
    gdz = bc(dzidx);
    
    % go that far in z
    gz = gz + gdz;
    
    % add RSLR in z
    gz = gz + RSLR;
    
%     stairs(ts, zs)
%     drawnow
    
end

% loop gaussian model elevation for strat
gm_strat = NaN(size(gzs)); % preallocate
gm_strat(end) = gzs(end);
for t = T(end-1:-1:1)
    gm_strat(t) = min([gzs(t), gm_strat(t+1)]);
    
end

figure(colfig)
stairs(T, gm_strat, 'Color', 'green', 'LineWidth', 2)
fitvars_b = polyfit(gts, gzs, 1);
mg_b = fitvars_b(1);

%% do uniform distribution model
figure()
sigma = 2;
center = 0;
[x, y] = meshgrid(be, be);
uni_mat = repmat(29*29/1, 29);
uni_mat = uni_mat(10:end, 10:end);
uni_mat = uni_mat ./ sum(sum(uni_mat));

surf(x, y, uni_mat);
xlabel('next state', 'FontSize', 14)
ylabel('current state', 'FontSize', 14)
xlim([min(bc), max(bc)])
ylim([min(bc), max(bc)])
cb = colorbar;
cb.Label.String = 'probability';
cb.Label.FontSize = 14;
caxis([0, max(max(uni_mat))])
view([0 90])
axis square

RSLR = 0.25; % need to make sure to add RSLR on each step to make a net aggradation
BL = 0; % base level
uz = 0; 
udz = 0; % random value for initial from within interval
for t = T
    % store
    uzs(t) = uz;
    uts(t) = t;
    
    % find the bin
    cidx = find(udz <= be, 1, 'first') - 1; % first greater than minus one is idx

    % generate a random number in interval [0 1]
    newrand = rand(1);

    % determine which prob bin it falls in to
    dzidx = find(mmcs(:, cidx) < newrand, 1, 'first');
    if isempty(dzidx)
        dzidx = 1; % SLOPPY HANDLING of case
    end
    udz = bc(dzidx);
    
    % go that far in z
    uz = uz + udz;
    
    % add RSLR in z
    uz = uz + RSLR;
    
%     stairs(ts, zs)
%     drawnow
    
end

% loop gaussian model elevation for strat
um_strat = NaN(size(uzs)); % preallocate
um_strat(end) = uzs(end);
for t = T(end-1:-1:1)
    um_strat(t) = min([uzs(t), um_strat(t+1)]);
    
end

figure(colfig)
stairs(T, um_strat, 'Color', 'blue', 'LineWidth', 2)
fitvars_b = polyfit(uts, uzs, 1);
mu_b = fitvars_b(1);


%% finalize plot
xlabel('Time (hours)', 'FontSize', 14)
ylabel('Z (mm)', 'FontSize', 14)
text(0.05,0.6, ['Markov slope=' num2str(round(m_b,2))], 'units', 'normalized', 'fontsize', 16, 'Color', 'red')
text(0.05,0.7, ['Gaussian slope=' num2str(round(mg_b,2))], 'units', 'normalized', 'fontsize', 16, 'Color', 'green')
text(0.05,0.8, ['Uniform slope=' num2str(round(mu_b,2))], 'units', 'normalized', 'fontsize', 16, 'Color', 'blue')
text(0.20, 0.05, ['expt. mean slope =' num2str(round(average_slope,2))], 'units', 'normalized', 'fontsize',16, 'Color', [0.8 0.8 0.8])
print('-dpng', '-r300', fullfile('..', 'figs', 'model_out.png'));
 

%% evaluate 1000 times and compute stats