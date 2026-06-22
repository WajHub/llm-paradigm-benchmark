DIR ?= .

SCALAC = scalac
SCALA = scala
SCALACFLAGS = -deprecation -feature -unchecked
TEST_DIR = $(DIR)/test_runner

SRCS = $(wildcard $(DIR)/*.scala)

test: $(SRCS)
	mkdir -p $(TEST_DIR)
	$(SCALAC) $(SCALACFLAGS) -d $(TEST_DIR) $(SRCS)

clean:
	rm -rf $(TEST_DIR) $(DIR)/*.class $(DIR)/*.log