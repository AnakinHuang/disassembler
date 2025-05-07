#
# CSC254 Assignment 4
#
# Team: Yuesong Huang, Wentao Jiang
# E-mail: yhu116@u.rochecter.edu, wjiang20@u.rochester.edu
#

.PHONY: ascii_test ascii_O1 ascii_O2 ascii_O3 clean test test_O1 test_O2 test_O3

# Compilers and Flags
RUBY = ruby
CC = gcc

# Compile rules
ascii_test:
	$(CC) -g3 -o test_name ascii.c

ascii_O1:
	$(CC) -g3 -O1 -o ascii ascii.c

ascii_O2:
	$(CC) -g3 -O2 -o ascii ascii.c

ascii_O3:
	$(CC) -g3 -O3 -o ascii ascii.c

# Clean rules
clean:
	rm -f ascii test_name *dump.txt *.html

# Run rules
test: clean ascii_test
	$(RUBY) disassem.rb test_name

test_O1: clean ascii_O1
	$(RUBY) disassem.rb ascii

test_O2: clean ascii_O2
	$(RUBY) disassem.rb ascii
	
test_O3: clean ascii_O3
	$(RUBY) disassem.rb ascii
