#include <stdio.h>
#include <limits.h>

/* GPU */
__global__ void last_digit(int n, int *A, int *D) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride) {
        if (A[i] % 2 == 1) { D[i] = A[i]; }
        else { D[i] = 0; }
    }
}

/* Remove Values in Array */
int* remove_copy(const int *in, size_t n, int *out, int value) {
    for (size_t i = 0; i != n; i++)
        if (in[i] != value) *out++ = in[i];
    return out;
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
    int *D = new int[M];
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
    cudaMallocManaged(&D, M * sizeof(int));
    
    /* Kernel */
    printf("Accessing GPU!\n");
    int blockSize = 256;
    int numBlocks = (count + blockSize - 1) / blockSize;
    last_digit<<<numBlocks, blockSize>>>(count, A, D);
    
    /* Remove 0s */
    printf("Removing Zeros!\n");
    int *B = new int[sizeof(D) / sizeof(*D)];
    const size_t N = sizeof(D) / sizeof(*D);
    int *done = remove_copy(D, N, B, 0);
    
    /* Print Array */
    int length = sizeof(done) / sizeof(*done);
    for (int i = 0; i < length; i++) {
        printf("%d", done[i]);
        if (i + 1 != length) { printf(", "); }
    }
    
    /* Write Out */
    FILE *f = fopen("q3.txt", "w");
    for (int i = 0; i < length; i++) {
        fprintf(f, "%d", done[i]);
        if (i + 1 != length) { fprintf(f, ", "); }
    } fclose(f);
    
    /* Free Memory */
    cudaFree(A);
    cudaFree(D);
    
    return 0;
}
