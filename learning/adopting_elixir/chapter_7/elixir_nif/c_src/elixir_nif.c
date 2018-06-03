#include "string.h"
#include "erl_nif.h"

#ifdef ERTS_DIRTY_SCHEDULERS
#define DIRTINESS ERL_NIF_DIRTY_JOB_CPU_BOUND
#else
#define DIRTINESS 0
#endif

static ERL_NIF_TERM
hello(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  ErlNifBinary *output_binary;
  enif_alloc_binary(sizeof "Hello from C", output_binary);
  strcpy(output_binary->data, "Hello from C");
  return enif_make_binary(env, output_binary);
}

static ErlNifFunc
nif_funcs[] = {
  {"hello", 0, hello, DIRTINESS},
};

ERL_NIF_INIT(Elixir.ElixirNif, nif_funcs, NULL, NULL, NULL, NULL)
