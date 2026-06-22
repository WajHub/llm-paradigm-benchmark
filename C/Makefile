DIR ?= .

CC = gcc
CFLAGS = -Wall -Wextra -g

# picks up tests.c + implementation .c automatically, works for any test-N folder
SRCS = $(wildcard $(DIR)/*.c)

test: $(SRCS)
	$(CC) $(CFLAGS) -o test_runner $(SRCS) -lm

clean:
	rm -f test_runner