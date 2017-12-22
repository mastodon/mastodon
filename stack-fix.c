#include <dlfcn.h>
#include <pthread.h>
#include <stdio.h>

// THIS IS TO AVOID A SIGFAULT WHEN RUNNING python3.6 manage.py runserver
// This should be fixed at some point by Alpine and/or Python
// Check this issue for more info
// https://github.com/docker-library/python/issues/211
typedef int (*func_t)(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void*), void *arg);

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void*), void *arg) {

    pthread_attr_t local;
    int used = 0, ret;

    if (!attr) {
        used = 1;
        pthread_attr_init(&local);
        attr = &local;
    }
    pthread_attr_setstacksize((void*)attr, 2 * 1024 * 1024); // 2 MB

    func_t orig = (func_t)dlsym(RTLD_NEXT, "pthread_create");

    ret = orig(thread, attr, start_routine, arg);

    if (used) {
        pthread_attr_destroy(&local);
    }

    return ret;
}
