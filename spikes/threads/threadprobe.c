/* SPIKE-10 throwaway: calls a cdecl callback from threads this DLL creates (CreateThread). */
#include <windows.h>

typedef int (__cdecl *tp_cb)(void *context, int n);

typedef struct { tp_cb cb; void *context; int n; int calls; int result; DWORD tid; } tp_job;

static volatile DWORD g_last_tid;

static DWORD WINAPI worker(LPVOID p)
{
    tp_job *job = (tp_job *)p;
    int i, r = 0;
    job->tid = GetCurrentThreadId();
    g_last_tid = job->tid;
    for (i = 0; i < job->calls; i++) r = job->cb(job->context, job->n);
    job->result = r;
    return 0;
}

/* Calls cb(context, n) once on a new thread, waits, returns what cb returned (-1: no thread). */
__declspec(dllexport) int tp_call_on_thread(tp_cb cb, void *context, int n)
{
    tp_job job = { cb, context, n, 1, 0, 0 };
    HANDLE h = CreateThread(NULL, 0, worker, &job, 0, NULL);
    if (!h) return -1;
    WaitForSingleObject(h, INFINITE);
    CloseHandle(h);
    return job.result;
}

/* Starts `threads` threads at once; each calls cb(context, its index) `calls` times. Returns 0,
   or -1 when a thread could not be created. At most 16 threads. */
__declspec(dllexport) int tp_call_on_threads(tp_cb cb, void *context, int threads, int calls)
{
    tp_job jobs[16];
    HANDLE hs[16];
    int i, made = 0;
    if (threads > 16) threads = 16;
    for (i = 0; i < threads; i++) {
        jobs[i].cb = cb; jobs[i].context = context; jobs[i].n = i; jobs[i].calls = calls;
        jobs[i].result = 0; jobs[i].tid = 0;
        hs[i] = CreateThread(NULL, 0, worker, &jobs[i], 0, NULL);
        if (!hs[i]) break;
        made++;
    }
    WaitForMultipleObjects(made, hs, TRUE, INFINITE);
    for (i = 0; i < made; i++) CloseHandle(hs[i]);
    return made == threads ? 0 : -1;
}

/* The OS thread id of the most recent worker. */
__declspec(dllexport) unsigned long tp_last_thread_id(void) { return g_last_tid; }

/* Atomic increment (InterlockedIncrement is an intrinsic on x64, not a kernel32 export). */
__declspec(dllexport) long tp_atomic_inc(volatile long *value) { return InterlockedIncrement(value); }
