function smoothed = apply_CED(img)
% APPLY_CED  Coherence-Enhancing Diffusion (CED)
% Fully stable implementation (no giant arrays, no incompatible sizes)

    % ---- Parameters ----
    myalpha = 0.001;     % minimum diffusion
    sigma   = 0.7;       % gradient smoothing scale
    rho     = 2;         % structure tensor smoothing
    C       = 1;         % coherence weighting
    T       = 3;         % total diffusion time
    stepT   = 0.2;       % dt per iteration
    
    im = double(img);
    [H, W] = size(im);

    % Gaussian kernels (separable)
    ks = ceil(2*sigma);
    x1 = -ks:ks;
    kSigma = exp(-x1.^2/(2*sigma^2)); 
    kSigma = kSigma / sum(kSigma);

    kr = ceil(3*rho);
    x2 = -kr:kr;
    kRho = exp(-x2.^2/(2*rho^2));
    kRho = kRho / sum(kRho);

    % Iteration loop
    maxIter = ceil(T/stepT);
    fprintf('CED on detail layers (%d iterations)...\n', maxIter);

    t = 0;
    iter = 0;

    while t < T - eps
        iter = iter + 1;
        fprintf('  CED iteration %2d / %2d\r', iter, maxIter);
        t = t + stepT;

        % ---- 1) Smooth image at scale sigma ----
        usigma = imfilter(imfilter(im, kSigma', 'replicate'), kSigma, 'replicate');

        % ---- 2) Gradients ----
        [uy, ux] = gradient(usigma);

        % ---- 3) Structure tensor ----
        Jxx = imfilter(imfilter(ux.^2    , kRho', 'replicate'), kRho, 'replicate');
        Jxy = imfilter(imfilter(ux.*uy   , kRho', 'replicate'), kRho, 'replicate');
        Jyy = imfilter(imfilter(uy.^2    , kRho', 'replicate'), kRho, 'replicate');

        % ---- 4) Eigenvalues of 2x2 tensor ----
        tr = Jxx + Jyy;
        detv = Jxx.*Jyy - Jxy.^2;
        disc = sqrt(max(tr.^2 - 4*detv, 0));

        lambda1 = 0.5*(tr + disc);
        lambda2 = 0.5*(tr - disc);

        di = abs(lambda1 - lambda2);
        di(di < eps) = eps;

        % ---- 5) Coherence-enhanced eigenvalues ----
        lambda1 = myalpha + (1-myalpha).*exp(-C./(di.^2));
        lambda2 = myalpha;

        % ---- 6) Eigenvectors (v1 corresponds to lambda1) ----
        v1x = Jxy;
        v1y = lambda1 - Jxx;

        nrm = sqrt(v1x.^2 + v1y.^2) + eps;
        v1x = v1x ./ nrm;
        v1y = v1y ./ nrm;

        v2x = -v1y;
        v2y =  v1x;

        % ---- 7) Diffusion tensor ----
        Dxx = lambda1 .* v1x.^2 + lambda2 .* v2x.^2;
        Dxy = lambda1 .* (v1x.*v1y) + lambda2 .* (v2x.*v2y);
        Dyy = lambda1 .* v1y.^2 + lambda2 .* v2y.^2;

        % ---- 8) Safe 9-point discretization update ----
        im = non_neg_discretization(im, Dxx, Dxy, Dyy, stepT);
    end

    fprintf('\nCED finished.\n');
    smoothed = im;
end


% =========================================================================
% ========== SAFE STENCIL: WORKS FOR ANY IMAGE (NO DIMENSION ERRORS) ======
% =========================================================================
function im = non_neg_discretization(im, Dxx, Dxy, Dyy, dt)
    [H, W] = size(im);

    upIdx    = [1, 1:H-1];
    downIdx  = [2:H, H];
    leftIdx  = [1, 1:W-1];
    rightIdx = [2:W, W];

    % Cardinal neighbors
    im_up    = im(upIdx, :);
    im_down  = im(downIdx, :);
    im_left  = im(:, leftIdx);
    im_right = im(:, rightIdx);

    % Diagonal neighbors (safe 2-step slicing)
    im_ur = im(upIdx , :); im_ur = im_ur(:, rightIdx);
    im_ul = im(upIdx , :); im_ul = im_ul(:, leftIdx);
    im_dr = im(downIdx, :); im_dr = im_dr(:, rightIdx);
    im_dl = im(downIdx, :); im_dl = im_dl(:, leftIdx);

    % Shift diffusion fields same way
    Dxx_up    = Dxx(upIdx, :);
    Dxx_down  = Dxx(downIdx, :);
    Dyy_left  = Dyy(:, leftIdx);
    Dyy_right = Dyy(:, rightIdx);

    Dxy_ur = Dxy(upIdx , :); Dxy_ur = Dxy_ur(:, rightIdx);
    Dxy_ul = Dxy(upIdx , :); Dxy_ul = Dxy_ul(:, leftIdx);
    Dxy_dr = Dxy(downIdx, :); Dxy_dr = Dxy_dr(:, rightIdx);
    Dxy_dl = Dxy(downIdx, :); Dxy_dl = Dxy_dl(:, leftIdx);

    % Final update (all matrices H×W)
    flux = ...
          Dxx_up    .* (im_up    - im) + ...
          Dxx_down  .* (im_down  - im) + ...
          Dyy_left  .* (im_left  - im) + ...
          Dyy_right .* (im_right - im) + ...
          0.25 * Dxy_ur .* (im_ur - im) + ...
          0.25 * Dxy_ul .* (im_ul - im) + ...
          0.25 * Dxy_dr .* (im_dr - im) + ...
          0.25 * Dxy_dl .* (im_dl - im);

    im = im + dt * flux;
end
