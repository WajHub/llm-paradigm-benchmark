DIR ?= .

SCALAC = scalac
SCALA = scala
SCALACFLAGS = -deprecation -feature -unchecked
TEST_DIR = $(DIR)/test_runner

test: $(DIR)/Tests.scala $(DIR)/SpatialLogic.scala
	mkdir -p $(TEST_DIR)
	$(SCALAC) $(SCALACFLAGS) -d $(TEST_DIR) $(DIR)/SpatialLogic.scala $(DIR)/Tests.scala

clean:
	rm -rf $(TEST_DIR) $(DIR)/*.class $(DIR)/*.log