

uint8_t* alignFramebuffer(uint8_t* buffer);

void swapUint8(uint8_t* a, uint8_t* b);
void swapUint32(uint32_t* a, uint32_t* b);

void shuffleArrayUint8(uint8_t* array, size_t size);
void shuffleArrayUint32(uint32_t* array, size_t size);

int compareUint8(const void* a, const void* b);
int compareUint32(const void* a, const void* b);

void bubbleSortUint8(uint8_t* array, size_t size);
void bubbleSortUint32(uint32_t* array, size_t size);

void shakerSortUint32(uint32_t* array, size_t size);

void fillArrayUint8(uint8_t* arr, int size);
void fillArrayUint32(uint32_t* arr, int size);

void* sortMain(void* arg);