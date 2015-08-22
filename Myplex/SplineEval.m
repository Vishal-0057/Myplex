//
//  SplineEval.m
//  SplineExperiment
//
//  Created by Igor Ostriz on 3.9.2013..
//  Copyright (c) 2013. Igor Ostriz. All rights reserved.
//

#import "SplineEval.h"

@interface SplineEval () {
    int N;
    double *xs, *ys, *ks, *ksinv;
}

@end

@implementation SplineEval

double* zerosMat(int r, int c) {
    double *A = (double *) malloc(r * c * sizeof(double));

    for (int i = 0; i < r; ++i) {
        for (int j=0; j < c; ++j) {
            *(A + i * c + j) = 0;
        }
    }
    
    return A;
}

void swapRows(double *A, int c, int k, int l) {
    for (int i = 0; i < c; ++i) {
        double t = *(A + k * c + i);
        *(A + k * c + i) = *(A + l * c + i);
        *(A + l * c + i) = t;
    }
}

void solve(double *A, int m, int c, double *x)
{
    for (int k = 0; k < m; ++k) {
        // pivot for column
        int i_max = 0;
        double vali = DBL_MIN;
        
        int i;
        for (i = k; i < m; ++i) {
            if (*(A + i * c + k) > vali) {
                i_max = i;
                vali = *(A + i * c + k);
            }
        }
        swapRows(A, c, k, i_max);
        
        if (*(A + i_max * c + i) == 0) {
            NSLog(@"matrix is singular!");
        }
        
        // for all rows below pivot
        for (i = k + 1; i < m; ++i) {
            for(int j = k + 1; j < m + 1; ++j) {
                *(A + i * c + j) = *(A + i * c + j) - *(A + k * c + j) * (*(A + i * c + k) / *(A + k * c + k));
            }
            *(A + i * c + k) = 0;
        }
    }
    
    for (int i = m - 1; i >= 0; --i) { // rows = columns
        double v = *(A + i * c + m) / *(A + i * c + i);
        x[i] = v;
        for (int j = i - 1; j >= 0; --j) { // rows
            *(A + j * c + m) -= *(A + j * c + i) * v;
            *(A + j * c + i) = 0;
        }
    }
}

void getNaturalKs(double *xs, double *ys, double *ks, int N) {
	int n = N - 1;
    int r = n + 1;
    int c = n + 2;
    double* A = zerosMat(r, c);
    
    for(int i = 1;  i < n; ++i) {
        *(A + i * c + i - 1) = 1 / (xs[i] - xs[i-1]);
        *(A + i * c + i) = 2 * (1 / (xs[i] - xs[i - 1]) + 1 / (xs[i + 1] - xs[i])) ;
        *(A + i * c + i + 1) = 1 / (xs[i + 1] - xs[i]);
        *(A + i * c + n + 1) = 3 * ((ys[i] - ys[i - 1]) / ((xs[i] - xs[i - 1]) * (xs[i] - xs[i - 1])) + (ys[i + 1] - ys[i]) / ((xs[i + 1] - xs[i]) * (xs[i + 1] - xs[i])));
    }
    
    *(A + 0 * c + 0) = 2 / (xs[1] - xs[0]);
    *(A + 0 * c + 1) = 1 / (xs[1] - xs[0]);
    *(A + 0 * c + n + 1) = 3 * (ys[1] - ys[0]) / ((xs[1] - xs[0]) * (xs[1] - xs[0]));
    
    *(A + n * c + n - 1) = 1 / (xs[n] - xs[n-1]);
    *(A + n * c + n) = 2 / (xs[n] - xs[n-1]);
    *(A + n * c + n + 1) = 3 * (ys[n] - ys[n-1]) / ((xs[n] - xs[n - 1]) * (xs[n] - xs[n - 1]));
    
    solve(A, r, c, ks);
}

double evalSpline(double x, double *xs, double *ys, double *ks, int N) {
    int i = 1;
    while (i < N && xs[i] < x) {
        ++i;
    }
    
    if (i == N) {
        // linear interpolation
        return ys[N - 1] + (x - xs[N - 1]) * (ys[N - 1] - ys[N - 2]) / (xs[N - 1] - xs[N - 2]);
    }
    
    double t = (x - xs[i - 1]) / (xs[i] - xs[i - 1]);
    
    double a =  ks[i - 1] * (xs[i] - xs[i - 1]) - (ys[i] - ys[i - 1]);
    double b = -ks[i    ] * (xs[i] - xs[i - 1]) + (ys[i] - ys[i - 1]);
    
    double q = (1 - t) * ys[i - 1] + t * ys[i] + t * (1 - t) * (a * (1 - t) +b * t);
    return q;
}

-(id)initWithPoints:(double *)points numPoints:(size_t)numPoints {
    self = [super init];
    if (self) {
        N = numPoints;

        xs = (double *)malloc(N * sizeof(double));
        ys = (double *)malloc(N * sizeof(double));
        ks = (double *)malloc(N * sizeof(double));

        for (int i = 0; i < N; ++i) {
            xs[i] = (double)i;
            ys[i] = points[i];
        }

        getNaturalKs(xs, ys, ks, N);

        ksinv = (double *)malloc(N * sizeof(double));
        getNaturalKs(ys, xs, ksinv, N);
    }
    return self;
}

-(double) eval:(double)x {
    return evalSpline(x, xs, ys, ks, N);
}

-(double) evalInverse:(double)y {
    return evalSpline(y, ys, xs, ksinv, N);
}


@end
