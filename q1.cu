#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <cuda.h>

#define THREADS_PER_BLOCK 512
#define ARRAY_SIZE 512*512


__global__ void getMin(int* array, int* results, int n){
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i >= n){
        array[i] = INT_MAX;
    }
    __syncthreads();
    for(int s = blockDim.x/2; s > 0; s>>=1){
        if(i < ARRAY_SIZE){
            if(threadIdx.x < s){
                if(array[i] > array[i + s]){
                    array[i] = array[i + s];
                }
            }
        }
        __syncthreads();
    }
    if(threadIdx.x == 0){
        results[blockIdx.x] = array[i];
    }
}

__global__ void getMin2(int* array){
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    for(int s = blockDim.x/2; s > 0; s>>=1){
        if(i < s){
            if(threadIdx.x < s){
                if(array[i] > array[i + s]){
                    array[i] = array[i + s];
                }
            }
        }
        __syncthreads();
    }
}

/* Part B */
__global__ void last_digit(int n, int *A, int *B){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride)
        B[i] = A[i] % 10;
}

int main(){
    FILE* fp;
    int temp;
    char buff[256];
    fp = fopen("inp.txt", "r");
    //int size = 256;
    int count = 0;
    int numBlocks = (ARRAY_SIZE/THREADS_PER_BLOCK);

    int* array = (int*)malloc(ARRAY_SIZE * sizeof(int));
    int* A = array;
    int* B = (int*)malloc(ARRAY_SIZE*sizeof(int));

    int* d_A;
    cudaMalloc((void**)&d_A, ARRAY_SIZE*sizeof(int));
    int* d_B;
    cudaMalloc((void**)&d_B, ARRAY_SIZE*sizeof(int));

    while(fscanf(fp, "%d", &temp) != EOF){
        array[count] = temp;
        count++;
        fscanf(fp, "%s", buff);
    }
    cudaMemcpy(d_A, A, ARRAY_SIZE*sizeof(int), cudaMemcpyHostToDevice);

    /* Kernel B */
    int blockSize = 256;
    int numBlocks2 = (count + blockSize - 1) / blockSize;
    last_digit<<<numBlocks2, blockSize>>>(count, d_A, d_B);

    int tempC = count;

    while(tempC < ARRAY_SIZE){
        array[tempC] = INT_MAX;
        tempC++;
    }

    int* d_array;
    cudaMalloc((void **)&d_array, ARRAY_SIZE*sizeof(int));
    cudaMemcpy(d_array, array, ARRAY_SIZE*sizeof(int), cudaMemcpyHostToDevice);

    int* mid;
    cudaMalloc((void **)&mid, numBlocks*sizeof(int));

    getMin<<<numBlocks, THREADS_PER_BLOCK>>>(d_array, mid, count);

    getMin2<<<16, 32>>>(mid);

    cudaMemcpy(array, d_array, ARRAY_SIZE*sizeof(int), cudaMemcpyDeviceToHost);

    int* h_mid = (int*)malloc(numBlocks*sizeof(int));
    cudaMemcpy(h_mid, mid, numBlocks*sizeof(int), cudaMemcpyDeviceToHost);

    for(int i = numBlocks - 1; i >= 0; i--){
        printf("%d\n", h_mid[i]);
    }

    // for(int i = ARRAY_SIZE - 1; i >= 0; i--){
    //     printf("%d\n", array[i]);
    // }
    
    /* Part A to File */
    FILE *f = fopen("q1a.txt", "w");
    fprintf(f, "%d", h_mid[0]);
    fclose(f);
    
    // int* newA = (int*)malloc(ARRAY_SIZE*sizeof(int));

    cudaMemcpy(B, d_B, ARRAY_SIZE*sizeof(int), cudaMemcpyDeviceToHost);

    /* Part B to File */
    FILE *f2 = fopen("q1b.txt", "w");
    for (int i = 0; i < count; i++) {
        fprintf(f2, "%d", B[i]);
        if (i + 1 != count) { fprintf(f2, ", "); }
    } fclose(f2);

    return 0;
}