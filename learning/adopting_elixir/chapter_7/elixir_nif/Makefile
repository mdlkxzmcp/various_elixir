MIX = mix
CFLAGS = -O3

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
ERLANG_DIRTY_SCHEDULERS = $(shell erl -eval 'io:format("~s", [try erlang:system_info(dirty_cpu_schedulers), true catch _:_ -> false end])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

ifndef MIX_ENV
  MIX_ENV = dev
endif

ifeq ($(ERLANG_DIRTY_SCHEDULERS),true)
	CFLAGS += -DERTS_DIRTY_SCHEDULERS
endif

ifdef DEBUG
  CFLAGS += -DNIFSY_DEBUG -pedantic -Weverything -Wall -Wextra -Wno-unused-parameter -Wno-gnu
endif

ifeq ($(MIX_ENV),dev)
  CFLAGS += -g
endif


.PHONY: all clean

all:
  $(MIX) compile
  priv/elixir_nif.so

priv/elixir_nif.so:
  c_src/elixir_nif.c
  mkdir -p priv
  $(CC) $(CFLAGS) -shared -o $@ c_src/elixir_nif.c

clean:
  $(RM) -r priv
