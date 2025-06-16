# Compiler
CC = gcc

# Target executable name
TARGET = test

# Default rule to build the target
all: $(TARGET)

# Rule to build the executable
$(TARGET): main.c
	$(CC) -o $(TARGET) main.c

# Clean up generated files
clean:
	rm -f $(TARGET)
