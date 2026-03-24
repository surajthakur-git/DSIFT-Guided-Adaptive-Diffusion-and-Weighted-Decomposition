function [jhist_out] = joint_hist_fn(x1, x2)

% Ensure both images are of same size
assert(isequal(size(x1), size(x2)), 'Input images must be the same size');

% Convert to uint8 and clip values to [0, 255]
x1 = uint8(min(max(x1, 0), 255));
x2 = uint8(min(max(x2, 0), 255));

% Initialize joint histogram
jhist_out = zeros(256, 256);

% Compute joint histogram
[p, q] = size(x1);
for ii = 1:p
    for jj = 1:q
        a = x1(ii, jj) + 1;
        b = x2(ii, jj) + 1;
        jhist_out(a, b) = jhist_out(a, b) + 1;
    end
end
