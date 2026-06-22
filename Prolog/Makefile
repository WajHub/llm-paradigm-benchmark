DIR ?= .

SWIPL = swipl
SWIPLFLAGS = -q

test:
	cd $(DIR) && $(SWIPL) $(SWIPLFLAGS) -g halt -s tests.pl

clean:
	rm -f test_runner test_runner.exe *.qlf $(DIR)/*.qlf
