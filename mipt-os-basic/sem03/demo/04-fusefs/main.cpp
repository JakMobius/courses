#define FUSE_USE_VERSION 31

#include <fuse/fuse.h>
#include <fuse/fuse_opt.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <stddef.h>
#include <assert.h>

const char *filename = "current-time";

const char* get_time() {
    time_t rawtime;
    struct tm *timeinfo;

    time(&rawtime);
    timeinfo = localtime(&rawtime);
    return asctime(timeinfo);
}

static void *init_handler(struct fuse_conn_info *conn) {
    return NULL;
}

static int getattr_handler(const char *path, struct stat *stbuf) {
    printf("getattr_handler(\"%s\");\n", path);
    int res = 0;

    memset(stbuf, 0, sizeof(struct stat));
    if (strcmp(path, "/") == 0) {
        stbuf->st_mode = S_IFDIR | 0755;
        stbuf->st_nlink = 2;
    } else if (strcmp(path + 1, filename) == 0) {
        stbuf->st_mode = S_IFREG | 0444;
        stbuf->st_nlink = 1;
        const char* time = get_time();
        stbuf->st_size = strlen(time);
    } else {
        res = -ENOENT;
    }

    return res;
}

static int readdir_handler(const char *path, void *buf, fuse_fill_dir_t filler,
                           off_t offset, struct fuse_file_info *fi) {
    printf("readdir_handler(\"%s\")\n", path);
    if (strcmp(path, "/") != 0) {
        return -ENOENT;
    }

    filler(buf, ".", NULL, 0);
    filler(buf, "..", NULL, 0);
    filler(buf, filename, NULL, 0);

    return 0;
}

static int open_handler(const char *path, struct fuse_file_info *fi) {
    printf("open_handler(\"%s\");\n", path);
    if (strcmp(path + 1, filename) != 0) {
        return -ENOENT;
    }

    if ((fi->flags & O_ACCMODE) != O_RDONLY) {
        return -EACCES;
    }

    // Prevent caching
    fi->direct_io = 1;

    return 0;
}

static int read_handler(const char *path, char *buf, size_t size, off_t offset,
                        struct fuse_file_info *fi) {
    printf("read_handler(\"%s\");\n", path);
    size_t len = 0;

    if (strcmp(path + 1, filename) != 0) {
        return -ENOENT;
    }

    const char* time = get_time();

    len = strlen(time);
    if (offset < len) {
        if (offset + size > len) {
            size = len - offset;
        }
        memcpy(buf, time + offset, size);
    } else {
        return 0;
    }

    return size;
}

static const struct fuse_operations hello_oper = {
    .init = init_handler,
    .getattr = getattr_handler,
    .readdir = readdir_handler,
    .open = open_handler,
    .read = read_handler,
};

int main(int argc, char *argv[]) {
    int ret = 0;
    struct fuse_args args = FUSE_ARGS_INIT(argc, argv);

    if (fuse_opt_parse(&args, NULL, NULL, NULL) == -1)
        return 1;

    ret = fuse_main(args.argc, args.argv, &hello_oper, NULL);
    fuse_opt_free_args(&args);
    return ret;
}
