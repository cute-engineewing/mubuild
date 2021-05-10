.DEFAULT_GOAL := all

# --- TOOLCHAIN -------------------------------------------------------------- #

CC		?=	gcc
CFLAGS	+=  -std=c99 						\
			-pedantic						\
			-Wpedantic						\
			-Wall							\
			-Wextra							\
			-Werror							\
			-ggdb							\
			-MD								\
			-fsanitize=undefined		 	\
			-fsanitize=address  			\
			-Ideps/mulib/inc				\
			-Ideps/mutest/inc				\
			-Isrc/

LDFLAGS	+=  -lreadline						\
			-lm 							\
			-Ldeps/mulib					\
			-Ldeps/mutest					\
			-l:libmu.a						\
			-l:libmutest.a						\
			-fsanitize=undefined			\
			-fsanitize=address

# --- UTILS ------------------------------------------------------------------ #

DIRECTORY_GUARD=@mkdir -p $(@D)

# --- TARGET ----------------------------------------------------------------- #

TARGET   =  $(PROJECT_NAME)
SRCS     =  $(PROJECT_SRC)
OBJS     =  $(patsubst %.c, $(BUILD_DIRECTORY)/%.c.o, $(SRCS))

# --- BUILD ------------------------------------------------------------------ #

BUILD_DIRECTORY ?= build

$(BUILD_DIRECTORY)/%.c.o: %.c
	$(DIRECTORY_GUARD)
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET): $(OBJS) deps/mulib/libmu.a
	$(DIRECTORY_GUARD)
	$(CC) $^ $(LDFLAGS) -o $@

# --- DEPENDENCIES ----------------------------------------------------------- #

deps/mulib/libmu.a: deps/mulib
	$(MAKE) -C deps/mulib all

deps/mutest/libmutest.a:
	$(MAKE) -C deps/mutest all

# --- TESTS ------------------------------------------------------------------ #

TEST_SRCS	= $(wildcard tests/*.c)
TEST_OBJS   = $(patsubst %.c, $(BUILD_DIRECTORY)/%.c.o, $(TEST_SRCS)) $(OBJS)
TEST_OBJS  := $(filter-out $(BUILD_DIRECTORY)/src/main.c.o, $(TEST_OBJS))

test: LDFLAGS	+= --coverage
test: CFLAGS    += --coverage

# --- PHONIES ---------------------------------------------------------------- #

.PHONY: all
all: $(TARGET)

.PHONY: test
test: $(TEST_OBJS) deps/mulib/libmu.a  deps/mutest/libmutest.a
	$(CC) -o $@ $^ $(LDFLAGS)
	@./$@

.PHONY: clean
clean:
	rm -r build

	-rm $(TARGET)
	-rm test
	-rm *.gcda
	-rm *.gcno

	$(MAKE) -C deps/mulib clean
	$(MAKE) -C deps/mutest clean
