#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <math.h>
#include <stdint.h>

int writeb(int fd, const void* data, size_t size) {
    const uint8_t* data2 = data;
    for (size_t i = 0; i < size; i++) {
        for (size_t b = 0; b < 8; b++) {
            write(fd, &"01"[data2[i] >> (7 - b) & 1], 1);
        }
        write(fd, "\n", 1);
    }
    return size;
}

int main() {
    for (int i = 0; i < 256; i++) {
        int8_t sine = round(sin(M_PI * 2 * i / 256) * 127);
        writeb(STDOUT_FILENO, &sine, sizeof(sine));
        // printf("%d ", sine);
    }
    return 0;
}
