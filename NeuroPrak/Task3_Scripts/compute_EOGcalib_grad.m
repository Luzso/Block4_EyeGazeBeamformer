function[calib_grad] = compute_EOGcalib_grad(Vcalib,theta,fname)

calib_grad = (theta(2)-theta(1))/(Vcalib(2)-Vcalib(1));
save(fname,'calib_grad');