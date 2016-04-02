function dirvec_w = getdirectionVector(p_im, K, R)
%% p_im, K, R
% p_im = [px_im;py_im;1];

dirvec = pinv(K)*p_im;

dirvec = dirvec/norm(dirvec)*500;

dirvec_w = R'*dirvec; % rotated only
end