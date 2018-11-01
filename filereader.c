#include <stdio.h>

// Example of file reader to implement in each question

int main(void){
    FILE *fp;
    int test;
    char buff[256];
    fp = fopen("inp.txt", "r");
    int size = 256;
    int count = 0;

    // the %d means to read only numbers and stop if not a number
    while(fscanf(fp, "%d", &test) != EOF){
        printf("%d\n", test);
        // the %s means to read until encountering a whitespace
        fscanf(fp, "%s", buff);
    }

    fclose(fp);
    // fscanf(fp, "%d", &test);
    // printf("%d", test);


}