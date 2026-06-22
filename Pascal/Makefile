DIR ?= .

FPC = fpc
FPCFLAGS = -Mobjfpc -Sh -O1 -g

test:
	$(FPC) $(FPCFLAGS) -Fu$(DIR) -otest_runner $(DIR)/tests.pas

clean:
	rm -f test_runner test_runner.o *.o *.ppu $(DIR)/*.o $(DIR)/*.ppu