a.out: y.tab.c lex.yy.c
	gcc y.tab.c lex.yy.c -ll
lex.yy.c: lexer.l
	lex lexer.l
y.tab.c: parser.y
	yacc -d parser.y
