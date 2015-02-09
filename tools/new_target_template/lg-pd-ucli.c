/**
 * @file lg-pd-ucli.c
 * @brief Lionsgate uCli thread and commands
 *
 * The uCli object is invoked in its own thread.
 */

#include <pthread.h>
#include <stdlib.h>

#include <uCli/ucli.h>
#include <uCli/ucli_argparse.h>
#include <uCli/ucli_node.h>

/* Sample test handler for uCli */
static ucli_status_t
lg_pd_ucli_ucli__config__(ucli_context_t* uc)
{
    UCLI_COMMAND_INFO(uc,
                      "config", 0,
                      "Show the p4rmt build configuration.");


    aim_printf(&uc->pvs, "Placeholder function for local config\n");

    return 0;
}

/* Sample test handler for uCli */
static ucli_status_t
lg_pd_ucli_ucli__quit__(ucli_context_t* uc)
{
    UCLI_COMMAND_INFO(uc,
                      "quit", 0,
                      "Terminate the LionsGate simulation.");

    /* FIXME: Probably needs more graceful clean up */
    exit(0);

    return 0;
}

/* Sample test handler for uCli */
static ucli_status_t
lg_pd_ucli_ucli__echo__(ucli_context_t* uc)
{
    int i;

    UCLI_COMMAND_INFO(uc,
                      "echo", 1,
                      "Echo one argument.");

    for (i = 0; i < uc->pargs->count; i++) {
        aim_printf(&uc->pvs, "%s\n", uc->pargs->args[i]);
    }

    return 0;
}

static ucli_command_handler_f lg_pd_ucli_handlers__[] =
{
    lg_pd_ucli_ucli__config__,
    lg_pd_ucli_ucli__echo__,
    lg_pd_ucli_ucli__quit__,
    NULL
};

static ucli_module_t lg_pd_ucli_mod = {
    "lg_pd",
    NULL,
    lg_pd_ucli_handlers__
};



typedef struct lg_pd_ctl_s {
    pthread_t thread_id;
    char *prompt;
    ucli_t *uc;
} lg_pd_ctl_t;

static lg_pd_ctl_t _ctl;

int
lg_pd_ucli_create(char *prompt)
{
    ucli_t *uc;

    ucli_init();

    ucli_module_init(&lg_pd_ucli_mod);
    _ctl.prompt = prompt;
    _ctl.uc = uc = ucli_create("lg_pd", &lg_pd_ucli_mod, NULL);

    return 0;
}

    

static void *ucli_thread(void *arg)
{
    lg_pd_ctl_t *ctl = (lg_pd_ctl_t *)arg;

    (void)ucli_run(ctl->uc, ctl->prompt);

    return NULL;
}

int
lg_pd_ucli_thread_spawn(void)
{
    int rv = 0;

    rv = pthread_create(&_ctl.thread_id, NULL, ucli_thread, &_ctl);
    if (rv < 0) {
        return -1;
    }

    return 0;
}  

int 
lg_pd_ucli_thread_stop(void)
{
    void *join_val;

    pthread_cancel(_ctl.thread_id); 
    pthread_join(_ctl.thread_id, &join_val); 
    _ctl.thread_id = 0; 

    return 0; 
}
