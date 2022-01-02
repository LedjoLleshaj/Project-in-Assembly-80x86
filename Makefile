EXE = parking
ARGS = testin.txt testout.txt
SRC = parking.c elaborazione.s

$(EXE) : $(SRC) 
	@echo "building $(EXE)..."
	@gcc -m32 -o $@ $^
	@echo "done building."
	@echo "type \"make help\" for command list"

run:
	@./$(EXE) $(ARGS)
	
clean: 
	@rm -f $(EXE) core testout.txt

help:
	@echo "make:\t\t build the executable"
	@echo "make run:\t run the executable with default parameters"
	@echo "make clean:\t clean executable and build files"
	@echo "make debug:\t compile for debug and run ddd with default parameters"

debug:
	@gcc -g -m32 -o $(EXE) $(SRC) 
	@ddd --args $(EXE) $(ARGS)

.PHONY: run, clean, help, debug

