DIR ?= .

JAVAC = javac
JAVA = java
JAVACFLAGS = -g

test: $(DIR)/Tests.java $(DIR)/SpatialLogic.java
	$(JAVAC) $(JAVACFLAGS) -d $(DIR) $(DIR)/SpatialLogic.java $(DIR)/SpatialLogicImpl.java $(DIR)/Tests.java

clean:
	rm -f $(DIR)/*.class *.class