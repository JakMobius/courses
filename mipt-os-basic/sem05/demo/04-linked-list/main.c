
#include <stdio.h>
#include <inttypes.h>

typedef struct list_entry {
    struct list_entry* next;
    const char* element;
} list_entry;

void print_list(list_entry* first);

int main() {
    list_entry entries[3] = {};

    entries[0].next = &entries[1];
    entries[1].next = &entries[2];

    entries[0].element = "Я";
    entries[1].element = "люблю";
    entries[2].element = "АКОС!";

    print_list(&entries[0]);

    return 0;
}