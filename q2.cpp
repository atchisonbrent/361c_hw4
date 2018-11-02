#include <stdio.h>
#include <limits.h>

/* Part A */
__global__ void entries_in_range(int n, int *A, int *B){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride) {
        if (0 <= A[i] && A[i] <= 99) { atomicAdd(B, 1); }
        if (100 <= A[i] && A[i] <= 199) { atomicAdd(&B[0], 1); }
        if (200 <= A[i] && A[i] <= 299) { atomicAdd(&B[1], 1); }
        if (300 <= A[i] && A[i] <= 399) { atomicAdd(&B[2], 1); }
        if (400 <= A[i] && A[i] <= 499) { atomicAdd(&B[3], 1); }
        if (500 <= A[i] && A[i] <= 599) { atomicAdd(&B[4], 1); }
        if (600 <= A[i] && A[i] <= 699) { atomicAdd(&B[5], 1); }
        if (700 <= A[i] && A[i] <= 799) { atomicAdd(&B[6], 1); }
        if (800 <= A[i] && A[i] <= 899) { atomicAdd(&B[7], 1); }
        if (900 <= A[i] && A[i] <= 999) { atomicAdd(&B[8], 1); }
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
    int *C = new int[d];
    int i, count = 0;
    
    /* Copy to GPU Memory */
    cudaMallocManaged(&A, M * sizeof(int));
    cudaMallocManaged(&B, d * sizeof(int));
    
    /* Read numbers as integers one by one */
    while (fscanf(fp, "%d", &i) != EOF) {
        A[count++] = i;             // Add number to array
        fscanf(fp, "%s", buff);     // Read until whitespace
    }
    
    /* Close FilePointer */
    fclose(fp);
    
    int blockSize = 256;
    int numBlocks = (count + blockSize - 1) / blockSize;
    entries_in_range<<<numBlocks, blockSize>>>(count, A, B);
    
    /* Wait for GPU */
    cudaDeviceSynchronize();
    
    /* Print B */
    printf("Printing Array!\n");
    for (int i = 0; i < d; i++) {
        printf("%d", B[i]);
        if (i + 1 != d ) printf(", ");
    }
    printf("\n");
    
    /* Free Memory */
    cudaFree(A);
    cudaFree(B);
    
    return 0;
}
