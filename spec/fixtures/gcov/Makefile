coverage:
	gcc -fPIC -fprofile-arcs -ftest-coverage -c -Wall -Werror main.c
	gcc -fPIC -fprofile-arcs -ftest-coverage -o main main.o
	./main
	gcov main.c
