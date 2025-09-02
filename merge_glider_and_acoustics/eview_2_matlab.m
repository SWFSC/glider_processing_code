function [out, mn_lats, mn_lons sv_int_data] = eview_2_matlab(dates, depths, acoustic_data, lats, lons, bins,sv)
% Efficient version of eview_2_matlab
% Bins acoustic data by depth and averages lat/lon per unique date

uni_dates = unique(dates, 'stable');     % preserve original order if needed
ln_uni_dates = length(uni_dates);
nbins = length(bins) - 1;                % number of bins

int_data = nan(nbins, ln_uni_dates);     % preallocate output
mn_lats = nan(1, ln_uni_dates);
mn_lons = nan(1, ln_uni_dates);
sv_int_data = nan(nbins, ln_uni_dates);

for i = 1:ln_uni_dates
    mask = (dates == uni_dates(i));      % logical indexing

    current_depths = depths(mask);
    current_data = acoustic_data(mask);
    current_lats = lats(mask);
    current_lons = lons(mask);
    current_sv = sv(mask);

    mn_lats(i) = mean(current_lats);
    mn_lons(i) = mean(current_lons);

    if nnz(mask) < 2                     % fewer than 2 points
        binned = nan(nbins,1);
    else
        binned = binit(current_depths, current_data, bins, @nanmean);
        binned_sv = binit(current_depths, current_sv, bins, @nanmean);
    end

    int_data(:,i) = binned;
    sv_int_data(:,i) = binned_sv;
end

out = int_data;
end