function [out, mn_lats, mn_lons] = eview_2_matlab( dates, depths, acoustic_data, lats, lons, bins)
% A function that is used with scr_load_glider_and_acoustic_data.m
% edited 2/13/20 - changed interp1 to binit. Requires function binit.m
uni_dates= unique(dates); % find unique dates

ln_uni_dates = length(uni_dates); % length of unique dates

zbins = bins; % set bins to zbins
sz_zbins = size(zbins); % get the size of zbins

int_data = nan(sz_zbins(2)-1, ln_uni_dates);
mn_lats = nan(1,ln_uni_dates);
mn_lons = nan(1,ln_uni_dates);

for i = 1:ln_uni_dates
aa = find(dates == uni_dates(i));

    if length(aa)<2
      binned = nan(sz_zbins(2)-1,1); % added 2/13/20 had to add -1 so bins were even, changed from zeroes to nan
      mn_lats(i) = mean(lats(aa));
      mn_lons(i) = mean(lons(aa));
      int_data(:,i) = binned';
    else
        mn_lats(i) = mean(lats(aa));
        mn_lons(i) = mean(lons(aa));
        %binned = interp1(depths(aa),acoustic_data(aa),zbins,'nearest'); % replaced with following line
		binned = binit(depths(aa),acoustic_data(aa),zbins, @nanmean);
        int_data(:,i) = binned';
    end
end
out = int_data;