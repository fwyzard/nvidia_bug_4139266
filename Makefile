.PHONY: all clean

all: test.o

clean:
	rm -f test.o

test.o: test.cu
	/usr/local/cuda-12.1/bin/nvcc -ccbin g++-12 --compiler-options "-msse2" test.cu -c -o test.o
