#!/bin/bash

lex lexer.l
yacc -d parser.y
gcc -g y.tab.c lex.yy.c -ll

./a.out<test1.c
