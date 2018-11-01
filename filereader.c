#include <stdio.h>
#include <stdlib.h>

// Example of file reader to implement in each question

typedef struct {
    int *array;
    int count;
    int size;
} DynamicArray;

void initDynamicArray(DynamicArray *a, int initialSize){
    a->array = (int*)malloc(initialSize * sizeof(int));
    a->count = 0;
    a->size = initialSize;
}

void insertArray(DynamicArray *a, int element){
    if(a->count == a->size){
        a->size = a->size * 2;
        a->array = (int*)realloc(a->array, a->size * sizeof(int));
    }
    a->array[a->count] = element;
    a->count++;
}

void freeArray(DynamicArray *a) {
    free(a->array);
    a->array = NULL;
    a->count = 0;
    a->size = 0;
}

int main(void){
    FILE *fp;
    int test;
    char buff[256];
    fp = fopen("inp.txt", "r");
    int size = 256;
    int count = 0;

    DynamicArray a;
    initDynamicArray(&a, size);


    // the %d means to read only numbers and stop if not a number
    while(fscanf(fp, "%d", &test) != EOF){
        insertArray(&a, test);
        // printf("%d\n", test);
        // the %s means to read until encountering a whitespace
        fscanf(fp, "%s", buff);
    }

    fclose(fp);
    // fscanf(fp, "%d", &test);
    // printf("%d", test);
    int at = a.count;
    int end = a.array[at - 1];
    printf("size of array: %d\n", at);
    printf("last element: %d\n", end);


}