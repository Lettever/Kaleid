# Compiler and flags
CXX = g++
CXXFLAGS = -Wall -g

# Final executable
TARGET = out

# Source directory and files
SRC_DIR = src
SRCS = $(wildcard $(SRC_DIR)/*.cpp)

# Build directory for object files
OBJ_DIR = $(SRC_DIR)/build

# Object files (placed in the OBJ_DIR)
OBJS = $(patsubst $(SRC_DIR)/%.cpp, $(OBJ_DIR)/%.o, $(SRCS))

# Rule to build the final executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS)

# Rule to build object files from source files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Create the build directory if it doesn't exist
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

# Clean up build artifacts
clean:
	rm -rf $(OBJ_DIR) $(TARGET)

.PHONY: clean
