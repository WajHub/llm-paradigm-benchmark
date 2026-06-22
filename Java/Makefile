DIR ?= .

JAVAC = javac
JAVA = java
JAVACFLAGS = -g

SRCS = $(wildcard $(DIR)/*.java)

test: $(SRCS)
	$(JAVAC) $(JAVACFLAGS) -d $(DIR) $(SRCS)

clean:
	rm -f $(DIR)/*.class *.class