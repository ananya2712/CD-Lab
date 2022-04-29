%{
	#include "sym_tab.c"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#define YYSTYPE char*
	/*
		declare variables to help you keep track or store properties
		scope can be default value for this lab(implementation in the next lab)
	*/
	int type=-1;
	char* vval="~";
	int vtype=-1;
	int scope=0;

	void yyerror(char* s); // error handling function
	int yylex(); // declare the function performing lexical analysis
	extern int yylineno; // track the line number

%}

%token T_INT T_CHAR T_DOUBLE T_WHILE  T_INC T_DEC   T_OROR T_ANDAND T_EQCOMP T_NOTEQUAL T_GREATEREQ T_LESSEREQ T_LEFTSHIFT T_RIGHTSHIFT T_PRINTLN T_STRING  T_FLOAT T_BOOLEAN T_IF T_ELSE T_STRLITERAL T_DO T_INCLUDE T_HEADER T_MAIN T_ID T_NUM

%start START


%%
START : PROG { printf("Valid syntax\n"); YYACCEPT; }	
        ;	
	  
PROG :  MAIN PROG				
	|DECLR ';' PROG 				
	| ASSGN ';' PROG 			
	|					
	;
	 

DECLR : TYPE LISTVAR 
	;	


LISTVAR : LISTVAR ',' VAR 
	  | VAR
	  ;

VAR: T_ID '=' EXPR 	
			{
				if(check_sym_tab($1)) {
					printf("Variable %s already declared\n",$1);
					//update_line($1, yylineno);
					yyerror($1);
				}
				else {
					symbol *sym = init_symbol($1,size(type),type,yylineno,scope);
					insert_into_table(sym);
					//printf("%d type ******\n", type);
					//printf("inserting\n");
					type=-1;
					insert_value_to_name($1,vval);
					vval="~";
					type = -1;
				}
			}
     | T_ID 	{

		 			if(check_sym_tab($1))
					{
						printf("Variable %s already declared\n",$1);
						//update_line($1, yylineno);
						yyerror($1);
					}
					else
					{
						symbol *sym = init_symbol($1,size(type),type,yylineno,scope);
						insert_into_table(sym);
						type=-1;
					}
			}	 

//assign type here to be returned to the declaration grammar
TYPE : T_INT {type = INT;}
       | T_FLOAT {type = FLOAT;}
       | T_DOUBLE {type = DOUBLE;}
       | T_CHAR {type = CHAR;}
       ;
    
/* Grammar for assignment */   
ASSGN : T_ID {type=retrieve_type($1);}'=' EXPR 	{
				if(!check_sym_tab($1))
				{
					printf("Variable %s not declared\n",$1);
					yyerror($$);
				}
				
				insert_value_to_name($1,vval);
				update_line($1, yylineno);
				//printf("%d LINEFUCKINGNUMBER\n", yylineno);
				vval="~";
				type=-1;

				/*	to be done in lab 3 */
			}
	;

EXPR : EXPR REL_OP E
       | E {vval=$1;}
       ;
	   
E : E '+' T		{
				if(vtype==2)
					sprintf($$,"%d",(atoi($1)+atoi($3)));
				else if((vtype==3) || (vtype==4))
					sprintf($$,"%lf",(atof($1)+atof($3)));
				else
				{
					printf("Character used in arithmetic\n");
					yyerror($$);
					$$="~";
				}
			}
    | E '-' T	{
				if(vtype==2)
					sprintf($$,"%d",(atoi($1)-atoi($3)));
				else if((vtype==3) || (vtype==4))
					sprintf($$,"%lf",(atof($1)-atof($3)));
				else
				{
					printf("Character used in arithmetic\n");
					yyerror($$);
					$$="~";
				}
			}
    | T {$$=$1;}
    ;
	
	
T : T '*' F	{
				if(vtype==2)
					sprintf($$,"%d",(atoi($1)*atoi($3)));
				else if((vtype==3) || (vtype==4))
					sprintf($$,"%lf",(atof($1)*atof($3)));
				else
				{
					printf("Character used in arithmetic\n");
					yyerror($$);
					$$="~";
				}
			}
    | T '/' F	{
				if(vtype==2)
					sprintf($$,"%d",(atoi($1)/atoi($3)));
				else if((vtype==3) || (vtype==4))
					sprintf($$,"%lf",(atof($1)/atof($3)));
				else
				{
					printf("Character used in arithmetic\n");
					yyerror($$);
					$$="~";
				}
			}
    | F	{$$=$1;}
    ;

F : '(' EXPR ')'
    | T_ID		{
					if(check_sym_tab($1))
					{
						char* check = retrieve_val($1);
						if(strcmp(check, "~")==0)
						{
							printf("Variable %s not initialised",$1);
							yyerror($1);
						}
						else
						{
							$$=strdup(check);
							vtype=type_check(check, $1);
							if(vtype!=type && type!=-1)
							{
								//printf("%d\t%d\n", vtype, type);
								//printf("running F-> TID\n");
								printf("Mismatch type\n");
								yyerror($1);
							}
						}
					}
			}
    | T_NUM 	{							// {vval=strdup($1);}
					$$=strdup($1);
					if(type == 4)
					{
						type = 3;
					}
					vtype=type_check($1, $1);
					if(vtype!=type && type!=-1)
					{
						//printf("%d\t%d\n", vtype, type);
						printf("Mismatch type\n");
						yyerror($1);
					}
			}
    | T_STRLITERAL 	{						// {vval=strdup($1);}
						$$=strdup($1);
						vtype=1;
						if(vtype!=type)
						{
							printf("Mismatch type\n");
							yyerror($1);
						}
				}
    ;

REL_OP :   T_LESSEREQ
	   | T_GREATEREQ
	   | '<' 
	   | '>' 
	   | T_EQCOMP
	   | T_NOTEQUAL
	   ;	


/* Grammar for main function */
MAIN : TYPE T_MAIN '(' EMPTY_LISTVAR ')' '{' {scope++;} STMT '}' {scope--;};

EMPTY_LISTVAR : LISTVAR
		|	
		;

STMT : STMT_NO_BLOCK STMT
       | BLOCK STMT
       |
       ;


STMT_NO_BLOCK : DECLR ';'
       | ASSGN ';' 
	   | T_IF COND STMT
	   | T_IF COND STMT T_ELSE STMT
       ;

BLOCK : '{' {scope++;} STMT '}' {scope--;};

COND : EXPR 
       | ASSGN
       ;

%%


/* error handling function */
void yyerror(char* s)
{
	printf("Error :%s at %d \n",s,yylineno);
}


int main(int argc, char* argv[])
{
	/* initialise table here */
	t = init_table();
	yyparse();
	/* display final symbol table*/
	display_symbol_table();
	return 0;

}
