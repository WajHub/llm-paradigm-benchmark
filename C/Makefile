DIR ?= .

CC = gcc
CFLAGS = -Wall -Wextra -g

test: $(DIR)/tests.c $(DIR)/spatial_logic.c
	$(CC) $(CFLAGS) -o test_runner $(DIR)/tests.c $(DIR)/spatial_logic.c -lm

clean:
	rm -f test_runner