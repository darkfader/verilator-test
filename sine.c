#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <math.h>
// #include <stdint.h>

int main() {
    for (int i = 0; i < 256; i++) {
        int8_t sine = round(sin(M_PI * 2 * i / 256) * 127);
        write(STDOUT_FILENO, &sine, sizeof(sine));
        // printf("%d ", sine);
    }
    return 0;
}
