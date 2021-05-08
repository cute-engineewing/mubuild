.DEFAULT_GOAL := all

# --- TOOLCHAIN -------------------------------------------------------------- #

CC		?=	gcc
CFLAGS	+=  -pedantic						\
			-Wpedantic						\
			-Wall							\
			-Wextra							\
			-Werror							\
			-ggdb							\
			-MD								\
			-fsanitize=undefined		 	\
			-fsanitize=address  			\
			-Ideps/mulib/inc				\

LDFLAGS	+=  -lreadline						\
			-lm 							\
			-Ldeps/mulib					\
			-lmu							\
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
	$(CC) $(CFLAGS) -r -o $@ $<

$(TARGET): $(OBJS) deps/mulib/libmu.a
	$(DIRECTORY_GUARD)
	$(CC) $^ $(LDFLAGS) -o $@

# --- DEPENDENCIES ----------------------------------------------------------- #

deps/mulib/libmu.a: deps/mulib
	$(MAKE) -C deps/mulib all

# --- TESTS ------------------------------------------------------------------ #

TEST_SRCS	= $(wildcard tests/*.c)
TEST_OBJS   = $(patsubst %.c, $(BUILD_DIRECTORY)/%.c.o, $(TEST_SRCS))

test: LDFLAGS	+= -lcmocka --coverage
test: CFLAGS    += --coverage

# --- PHONIES ---------------------------------------------------------------- #

.PHONY: all
all: $(TARGET)

.PHONY: test
test: $(TEST_OBJS)
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
