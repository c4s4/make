# Parent makefile for C++ (https://github.com/c4s4/make)

CPP_SRC=src
CPP_INC=include

.PHONY: cpp-lint
cpp-format: # Reformat CPP source and header files with clang-format
	$(title)
	clang-format -i $(shell find $(CPP_SRC) \( -name *.cpp -o -name *.c++ \))
	clang-format -i $(shell find $(CPP_INC) \( -name *.h -o -name *.hpp \))
