DIR ?= .

GHC = ghc
GHCFLAGS = -Wall -Wextra -g

test:
	$(GHC) $(GHCFLAGS) -i$(DIR) -o test_runner $(DIR)/Tests.hs

clean:
	rm -f test_runner test_runner.exe test_runner.hi test_runner.o $(DIR)/*.hi $(DIR)/*.o
