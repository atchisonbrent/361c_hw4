#include <stdio.h>
#include <limits.h>

/* GPU */
__global__ void find_odd(int n, int *A, int *B) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride) {
        if (A[i] % 2 == 1) { B[i] = A[i]; }
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
    int *A = (int*) malloc(M * sizeof(int));
    int *B = (int*) malloc(M * sizeof(int));
    int *D = (int*) malloc(M * sizeof(int));
//    int *A = new int[M];
//    int *B = new int[M];
//    int *D = new int[M];
    int i, count = 0;
    
    /* Read numbers as integers one by one */
    printf("Scanning File!\n");
    while (fscanf(fp, "%d", &i) != EOF) {
        A[count++] = i;             // Add number to array
        fscanf(fp, "%s", buff);     // Read until whitespace
    }
    
    /* Close File */
    printf("Closing File!\n");
    fclose(fp);
    
    /* Copy to GPU Memory */
    printf("Copying to GPU Memory!\n");
    cudaMallocManaged(&A, M * sizeof(int));
    cudaMallocManaged(&B, M * sizeof(int));
    
    /* Kernel */
    printf("Accessing GPU!\n");
    int blockSize = 256;
    int numBlocks = (count + blockSize - 1) / blockSize;
    find_odd<<<numBlocks, blockSize>>>(count, A, B);

    /* Remove 0s */
    printf("Removing Zeros!\n");
    int zeroCount = 0;
    for (int i = 0; i < count; i++) {
        if (B[i] == 0) { zeroCount++; }
        else { D[i - zeroCount] = B[i]; }
    }

    /* Print Array */
    printf("Printing Array!\n");
    for (int i = 0; D[i] != 0; i++) { printf("%d, ", D[i]); }

    /* Write Out */
    printf("Writing File!\n");
    FILE *f = fopen("q3.txt", "w");
    for (int i = 0; D[i] != 0; i++) { fprintf(f, "%d, ", D[i]); }
    fclose(f);

    /* Free Memory */
    printf("Freeing Memory!\n");
    cudaFree(A);
    cudaFree(B);
    
    return 0;
}
