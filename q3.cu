#include <stdio.h>
#include <limits.h>

/* GPU */
__global__ void find_odd(int n, int *A, int *B) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride) {
        if (A[i] % 2 > 0) { B[i] = A[i]; }
        else { B[i] = 0; }
    }
}

int main() {
    
    /* Open File */
    printf("Opening File!\n");
    FILE *fp;
    fp = fopen("inp.txt", "r");
    
    printf("Init Arrays and Such!\n");
    char buff[256];
    const int M = 1<<20;
    int *A = new int[M];
    int *B = new int[M];
    int *D = new int[M];
    int i, count = 0;
    
    /* Copy to GPU Memory */
    printf("Copying to GPU Memory!\n");
    cudaMallocManaged(&A, M * sizeof(int));
    cudaMallocManaged(&B, M * sizeof(int));
    
    /* Read numbers as integers one by one */
    printf("Scanning File!\n");
    while (fscanf(fp, "%d", &i) != EOF) {
        A[count++] = i;             // Add number to array
        fscanf(fp, "%s", buff);     // Read until whitespace
    }
    
    /* Close File */
    printf("Closing File!\n");
    fclose(fp);
    
    /* Kernel */
    printf("Accessing GPU!\n");
    int blockSize = 256;
    int numBlocks = (count + blockSize - 1) / blockSize;
    find_odd<<<numBlocks, blockSize>>>(count, A, B);
    
    /* Wait for GPU */
    cudaDeviceSynchronize();
    
    /* Print B */
    for (int i = 0; i < count; i++) {
        printf("%d, ", B[i]);
    }
    printf("\n");

    /* Remove 0s */
    printf("Removing Zeros!\n");
    int zeroCount = 0;
    for (int i = 0; i < count; i++) {
        if (B[i] != 0) { D[i - zeroCount] = B[i]; }
        else { zeroCount++; }
    }

    /* Print D */
    printf("Printing Array!\n");
    for (int i = 0; D[i] != 0; i++) {
        printf("%d", D[i]);
        if (D[i + 1] != 0) printf(", ");
    }
    printf("\n");

    /* Write D */
    printf("Writing File!\n");
    FILE *f = fopen("q3.txt", "w");
    for (int i = 0; D[i] != 0; i++) {
        fprintf(f, "%d", D[i]);
        if (D[i + 1] != 0) fprintf(f, ", ");
    }
    fclose(f);

    /* Free Memory */
    printf("Freeing Memory!\n");
    cudaFree(A);
    cudaFree(B);
    
    return 0;
}
