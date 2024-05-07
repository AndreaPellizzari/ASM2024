AS_FLAGS = --32 -g  ; Compile as ELF 32-bit with debugging symbols
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

# Target executable name (customize if needed)
TARGET = bin/my_program

# Source and object file directories (adjust as needed)
SRC_DIR = src/
OBJ_DIR = obj/

# Source files (modify the list)
SRC_FILES = main.s EDF.s HPF.s


# Object files (automatically generated)
OBJECTS = $(patsubst $(SRC_DIR)/%.s, $(OBJ_DIR)/%.o, $(SRC_FILES))

all: $(TARGET)

$(TARGET): $(OBJECTS)
	ld $(LD_FLAGS) $(OBJECTS) -o $(TARGET)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s $(INCLUDE_FILES)
	$(AS) $(AS_FLAGS) -I$(SRC_DIR) $< -o $@  # Include source directory for header files

clean:
	rm -f $(OBJECTS) $(TARGET)