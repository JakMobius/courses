#include <stdio.h>

void fill_string_with_percents(char* ptr) {
	while(ptr) {
		*ptr++ = '%';
	}
}

int main() {
	char my_string[] = "This is my awesome string!";
	fill_string_with_percents(my_string);
	printf("%s", my_string);
	return 0;
}
