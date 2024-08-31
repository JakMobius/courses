#include <stdio.h>
#include <stdlib.h>

int main() {
	int* ptr = NULL;	
	
	for(int i = 0; i < 1000; i++) {
		ptr = calloc(64, sizeof(int));
	}

	free(ptr);
	return 0;
}
