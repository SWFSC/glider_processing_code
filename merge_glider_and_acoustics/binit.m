function binned = binit(x, y, edges, f)
% binned = binit(x, y, edges, f)
% BINIT bin data into bins of predefined size based on another variable
% inputs: x: vector to determine which bin values of y will be placed into
%         y: vector of values to be placed into bins
%         edges: vector of bin edges
%         f: function handle to operate on bins. Default: @nanmean
% If there are multiple values per bin, function f will be applied to the values
% Bins without any values will be NaN
%
% D. Nowacki nowacki@uw.edu 2011-04-21
% 2014-06-25 preallocate variables for speed, add function handle syntax

numbins = length(edges) - 1;

[~, bin] = histc(x, edges);

if nargin < 4, f = @nanmean; end

binned = nan(1,numbins);

for i = 1:numbins
    flagmembers = (bin == i);
    binmembers = y(flagmembers);
    binned(i) = f(binmembers);
end

end