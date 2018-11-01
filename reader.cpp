#include <stdio.h>

int main() {

	/* Open File */
	FILE *fp;
	fp = fopen("inp.txt", "r");

	char buff[256];
	const int M = 1 << 20;		// 1 Million
	int *A = new int[M];
	int i, count = 0;

	/* Read numbers as integers one by one */
	while (fscanf(fp, "%d", &i) != EOF) {
		A[count++] = i;			// Add number to array
		// printf("%d\n", i);	// Print number to console
		fscanf(fp, "%s", buff);	// Read until whitespace
	}

	printf("\n%d\n", count);		// 10,000 ints in inp.txt

	for (int j = 0; j < count; j++) { printf("%d\n", A[j]); }	// Print A

	fclose(fp);
}
