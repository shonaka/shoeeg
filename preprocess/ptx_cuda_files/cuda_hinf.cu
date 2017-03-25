/* CUDA H-infinity */

/*
Created by Sho Nakagome
snakagome@uh.edu

Algorithchfroch"A robust adaptive denoising framework for real-time artifact
removal in scalp EEG measurements"
Source: http://iopscience.iop.org/article/10.1088/1741-2560/13/2/026013/meta

NumCh = total number of EEG channels without EOGs
NumSamp = total number of samples

Input:
	EEG: NumSamp (samples) x NumCh (channels without EOGs)
	EOG: NumSamp (samples) x 3 (2 columns of EOG and bias)
	gpu_sh_hinf: NumSamp (samples) x NumCh (channels without EOGs)
	output: NumSamp (samples) x NumCh (channels without EOGs)
	NumCh: total number of EEG channels without EOGs
	NumSamp: total number of samples
	qhinf: deviation factor frochgamma (1e-10)
	gamma: controls suppression (near to 1 is good)
*/

// matrix inversion for 3 x 3 matrix
__device__ void invMat3x3(double *A, double *output) {
	// calculate the determinant first
	double det = 0;
	det += A[0] * (A[4] * A[8] - A[7] * A[5])
		- A[1] * (A[3] * A[8] - A[5] * A[6])
		+ A[2] * (A[3] * A[7] - A[4] * A[6]);
	// then calculate inverse
	output[0] = (A[4] * A[8] - A[7] * A[5]) / det;
	output[1] = (A[2] * A[7] - A[1] * A[8]) / det;
	output[2] = (A[1] * A[5] - A[2] * A[4]) / det;
	output[3] = (A[5] * A[6] - A[3] * A[8]) / det;
	output[4] = (A[0] * A[8] - A[2] * A[6]) / det;
	output[5] = (A[2] * A[3] - A[0] * A[5]) / det;
	output[6] = (A[3] * A[7] - A[4] * A[6]) / det;
	output[7] = (A[1] * A[6] - A[0] * A[7]) / det;
	output[8] = (A[0] * A[4] - A[1] * A[3]) / det;
}

// H-infinity using CUDA (Using global memory instead of registers without using pragma unroll
__global__ void cuda_hinf(double *output, double *EEG, double *EOG, double *gpu_sh_hinf, const int NumCh, const int NumSamp, double q, double g) {
	// define const length
	const int lenvec3 = 3; // a vector of size 3 x 1 has length 3
	const int lenmat3 = 9; // a matrix of size 3 x 3 has length 9

	// define parameters
	const double qhinf = q; // (1e-10) // deviation factor frochgamma <= 1 condition for time varying
	const double gamma = g; // controls suppression
	double gpu_g[lenvec3] = { 0 };
	double gpu_r[lenvec3] = { 0 };
	double gpu_atempvec[lenvec3] = { 0 };

	// specify channel index
	size_t ch = blockDim.x * blockIdx.x + threadIdx.x;

	// initialize
	// Pt = filter error covariance
	double gpu_Pt[lenmat3] = { 0.5, 0, 0, 0, 0.5, 0, 0, 0, 0.5 };
	double gpu_PP[lenmat3] = { 0 };
	// filter coefficients
	double gpu_wh[lenvec3] = { 0 };
	// eye matrix
	double gpu_eye[lenmat3] = { 1, 0, 0, 0, 1, 0, 0, 0, 1 };

	// run h-infinity
	for (int samp = 0; samp < NumSamp; samp++) { // run through samples
    // get sample by sample data
    // this is actully si in the equation
		double gpu_y = EEG[samp * NumCh + ch];

		for (int i = 0; i < lenvec3; i++) {
			gpu_r[i] = EOG[samp * lenvec3 + i];
		}
		// remove bias and drift
		gpu_r[2] = 1.0;

		// calculate PP for error covariance matrix d1 = r * r'
		double gpu_d1[lenmat3] = { 0 };
		for (int j1 = 0; j1 < lenvec3; j1++) { // row
			for (int j2 = 0; j2 < lenvec3; j2++) { // col
				gpu_d1[j1 * lenvec3 + j2] = gpu_r[j1] * gpu_r[j2];
			}
		}

		double gpu_etemp1[lenmat3] = { 0 };
		invMat3x3(gpu_Pt, gpu_etemp1);

		double gpu_temp[lenmat3] = { 0 };
		for (int i = 0; i < lenmat3; i++) {
			gpu_temp[i] = gpu_etemp1[i] - (1.0 / (gamma * gamma)) * gpu_d1[i];
		}
		invMat3x3(gpu_temp, gpu_PP);

		// update filter gains
		double gpu_atemp1[lenvec3] = { 0 };
		double gpu_atemp2 = 0;
		for (int i = 0; i < lenvec3; i++) {
			gpu_atemp1[i] = gpu_PP[lenvec3 * i + 0] * gpu_r[0]
				+ gpu_PP[lenvec3 * i + 1] * gpu_r[1]
				+ gpu_PP[lenvec3 * i + 2] * gpu_r[2];
		}
		gpu_atemp2 = 1.0 + gpu_r[0] * gpu_atemp1[0]
			+ gpu_r[1] * gpu_atemp1[1]
			+ gpu_r[2] * gpu_atemp1[2];

		for (int i = 0; i < lenvec3; i++) {
			gpu_atempvec[i] = gpu_atemp1[i] / gpu_atemp2;
		}
		for (int i = 0; i < lenvec3; i++) {
			gpu_g[i] = gpu_atempvec[i];
		}

		// calculate prediction
		double gpu_btemp1 = 0;
		gpu_btemp1 = gpu_r[0] * gpu_wh[0]
			+ gpu_r[1] * gpu_wh[1]
			+ gpu_r[2] * gpu_wh[2];
		double gpu_zh = 0;
		gpu_zh = gpu_btemp1;

		// calculate error
		// this is actually yi in the equation
		gpu_sh_hinf[NumCh * samp + ch] = gpu_y - gpu_zh;

		// update filter weights
		for (int i = 0; i < lenvec3; i++) {
			gpu_wh[i] += gpu_g[i] * gpu_sh_hinf[NumCh * samp + ch];
		}

		// update error covariance matrix
		double gpu_ptinv[lenmat3] = { 0 };
		invMat3x3(gpu_Pt, gpu_ptinv);
		double gpu_tempPT[lenmat3] = { 0 };
		for (int i = 0; i < lenmat3; i++) {
			gpu_tempPT[i] = gpu_ptinv[i] + (1.0 - (1.0 / (gamma * gamma))) * gpu_d1[i];
		}
		double gpu_tempPTinv[lenmat3] = { 0 };
		invMat3x3(gpu_tempPT, gpu_tempPTinv);
		for (int i = 0; i < lenmat3; i++) {
			gpu_Pt[i] = gpu_tempPTinv[i] + qhinf * gpu_eye[i];
		}
	}

	// copy to the column of the output
	for (int i = 0; i < NumSamp; i++) {
		output[NumCh * i + ch] = gpu_sh_hinf[NumCh * i + ch];
	}
}
