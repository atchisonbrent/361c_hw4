#include <stdio.h>
#include <limits.h>
#include <cuda.h>

__global__ void min(int n, int *A) {
    
    __shared__ int min = INT_MAX;
    
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride)
        atomicMin(min, A[i]);
}

int main() {
    
    /* Open File */
    FILE *fp;
    fp = fopen("inp.txt", "r");
    
    char buff[256];
    const int M = 1 << 20;          // 1 Million
    int *A = new int[M];
    int i, count = 0;
    
    cudaMallocManaged(&A, M * sizeof(int));

    /* Read numbers as integers one by one */
    while (fscanf(fp, "%d", &i) != EOF) {
        A[count++] = i;             // Add number to array
        fscanf(fp, "%s", buff);     // Read until whitespace
    }

    printf("\n%d\n", count);        // 10,000 ints in inp.txt

    for (int j = 0; j < count; j++) { printf("%d\n", A[j]); }    // Print A

    fclose(fp);
    
    /* Run Kernel */
    min<<<256, 256>>>(count, x);
    
    /* Wait for GPU to finish */
    cudaDeviceSynchronize();
    
    /* Free Memory */
    cudaFree(A);
}
