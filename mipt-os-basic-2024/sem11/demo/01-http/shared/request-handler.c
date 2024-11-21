
#include <stdbool.h>
#include <string.h>
#include "request-handler.h"

#define LINE_MAX 1024
#ifndef KEEPALIVE_SUPPORTED
#define KEEPALIVE_SUPPORTED false
#endif

bool handle_request(FILE* socket) {
    // Parse the request
    char line[LINE_MAX] = {};

    while(true) {
        if(fgets(line, sizeof(line), socket) == NULL) {
            return false;
        }
        if (strcmp(line, "\r\n") == 0) {
            break;
        }
    }

    const char* html = "<h1>Hello, World!</h1>";

    fprintf(socket, "HTTP/1.1 200 OK\r\n");
    if(KEEPALIVE_SUPPORTED) {
        fprintf(socket, "Connection: keep-alive\r\n");
    }
    fprintf(socket, "Content-Type: text/html\r\n");
    fprintf(socket, "Content-Length: %ld\r\n", strlen(html));
    fprintf(socket, "\r\n");
    fprintf(socket, "%s", html);
    fflush(socket);

    return true;
}