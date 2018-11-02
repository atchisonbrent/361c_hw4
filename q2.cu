#include <stdio.h>
#include <limits.h>

/* Part A */
__global__ void part_a(int n, int *A, int *B){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride) {
        if (0 <= A[i] && A[i] <= 99) { atomicAdd(B, 1); }
        else if (100 <= A[i] && A[i] <= 199) { atomicAdd(&B[1], 1); }
        else if (200 <= A[i] && A[i] <= 299) { atomicAdd(&B[2], 1); }
        else if (300 <= A[i] && A[i] <= 399) { atomicAdd(&B[3], 1); }
        else if (400 <= A[i] && A[i] <= 499) { atomicAdd(&B[4], 1); }
        else if (500 <= A[i] && A[i] <= 599) { atomicAdd(&B[5], 1); }
        else if (600 <= A[i] && A[i] <= 699) { atomicAdd(&B[6], 1); }
        else if (700 <= A[i] && A[i] <= 799) { atomicAdd(&B[7], 1); }
        else if (800 <= A[i] && A[i] <= 899) { atomicAdd(&B[8], 1); }
        else if (900 <= A[i] && A[i] <= 999) { atomicAdd(&B[9], 1); }
    }
}

/* Part B */
__global__ void part_b(int n, int *A, int *B){
    __shared__ int s[10];
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride) {
        if (0 <= A[i] && A[i] <= 99) { atomicAdd(B, 1); }
        else if (100 <= A[i] && A[i] <= 199) { atomicAdd(&s[1], 1); }
        else if (200 <= A[i] && A[i] <= 299) { atomicAdd(&s[2], 1); }
        else if (300 <= A[i] && A[i] <= 399) { atomicAdd(&s[3], 1); }
        else if (400 <= A[i] && A[i] <= 499) { atomicAdd(&s[4], 1); }
        else if (500 <= A[i] && A[i] <= 599) { atomicAdd(&s[5], 1); }
        else if (600 <= A[i] && A[i] <= 699) { atomicAdd(&s[6], 1); }
        else if (700 <= A[i] && A[i] <= 799) { atomicAdd(&s[7], 1); }
        else if (800 <= A[i] && A[i] <= 899) { atomicAdd(&s[8], 1); }
        else if (900 <= A[i] && A[i] <= 999) { atomicAdd(&s[9], 1); }
    }
    __syncthreads();
    for (int i = 0; i < 10; i++) { atomicAdd(&B[i], s[i]); }
}

/* Part C */
__global__ void part_c(int *B, int *C){
    for (int i = 0; i < 10; i += 1) {
        int sum = 0;
        for (int j = 0; j < i; j++) { sum += B[j]; }
        C[i] += sum;
    }
}

int main() {
    
    /* Open File */
    FILE *fp;
    fp = fopen("inp.txt", "r");
    
    char buff[256];
    const int M = 1<<20;
    const int d = 10;
    int *A = new int[M];
    int *B = new int[d];
    int *B2 = new int[d];
    int *C = new int[d];
    int i, count = 0;
    
    /* Copy to GPU Memory */
    cudaMallocManaged(&A, M * sizeof(int));
    cudaMallocManaged(&B, d * sizeof(int));
    cudaMallocManaged(&B2, d * sizeof(int));
    cudaMallocManaged(&C, d * sizeof(int));
    
    /* Read numbers as integers one by one */
    while (fscanf(fp, "%d", &i) != EOF) {
        A[count++] = i;             // Add number to array
        fscanf(fp, "%s", buff);     // Read until whitespace
    }
    
    /* Close FilePointer */
    fclose(fp);
    
    /**************************************************/
    
    /* Part A */
    int blockSize = 256;
    int numBlocks = (count + blockSize - 1) / blockSize;
    part_a<<<numBlocks, blockSize>>>(count, A, B);
    
    /* Wait for GPU */
    cudaDeviceSynchronize();
    
    /* Part A to File */
    FILE *f = fopen("q2a.txt", "w");
    for (int i = 0; i < d; i++) {
        fprintf(f, "%d", B[i]);
        if (i + 1 != d) { fprintf(f, ", "); }
    } fclose(f);
    
    /* Print B */
    printf("B: ");
    for (int i = 0; i < d; i++) {
        printf("%d", B[i]);
        if (i + 1 != d ) printf(", ");
    } printf("\n");
    
    /* Copy B to C */
    for (int i = 0; i < d; i++) { C[i] = B[i]; }
    
    /**************************************************/
    
    /* Part B */
    part_b<<<numBlocks, blockSize>>>(count, A, B2);
    
    /* Wait for GPU */
    cudaDeviceSynchronize();
    
    /* Part B to File */
    FILE *f2 = fopen("q2b.txt", "w");
    for (int i = 0; i < d; i++) {
        fprintf(f2, "%d", B2[i]);
        if (i + 1 != d) { fprintf(f2, ", "); }
    } fclose(f2);
    
    /* Print B2 */
    printf("B2: ");
    for (int i = 0; i < d; i++) {
        printf("%d", B2[i]);
        if (i + 1 != d ) printf(", ");
    } printf("\n");
    
    /**************************************************/
    
    /* Part C */
    part_c<<<1, 1>>>(B, C);
    
    /* Wait for GPU */
    cudaDeviceSynchronize();
    
    /* Part C to File */
    FILE *f3 = fopen("q2c.txt", "w");
    for (int i = 0; i < d; i++) {
        fprintf(f3, "%d", C[i]);
        if (i + 1 != d) { fprintf(f3, ", "); }
    } fclose(f3);
    
    /* Print C */
    printf("C: ");
    for (int i = 0; i < d; i++) {
        printf("%d", C[i]);
        if (i + 1 != d ) printf(", ");
    } printf("\n");
    
    /**************************************************/
    
    /* Free Memory */
    cudaFree(A);
    cudaFree(B);
    cudaFree(B2);
    cudaFree(C);
    
    return 0;
}
