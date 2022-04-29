#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "sym_tab.h"

table* init_table()	
{
	/*
        allocate space for table pointer structure eg (t_name)* t
        initialise head variable eg t->head
        return structure
    	*/
    table * t = (table*)malloc(sizeof(table));
    t->head = NULL;
    return t;
}

symbol* init_symbol(char* name, int size, int type, int lineno, int scope) //allocates space for items in the list
{
	/*
        allocate space for entry pointer structure eg (s_name)* s
        initialise all struct variables(name, value, type, scope, length, line number)
        return structure
    	*/
    symbol * sym = (symbol*)malloc(sizeof(symbol));
    sym->name = name;
    sym->len = size;
    sym->type = type;
    sym->line = lineno;
    sym->scope = scope;
    sym->next = NULL;
    sym->val = "~";
    return sym;
}

void insert_into_table(symbol *entry)/* 
 arguments can be the structure s_name already allocated before this function call
 or the variables to be sent to allocate_space_for_table_entry for initialisation        
*/
{
    /*
        check if table is empty or not using the struct table pointer
        else traverse to the end of the table and insert the entry
    */
   if(t->head == NULL)
   {
       t->head = entry;
   }

   else
   {
       symbol *curr = t->head;
       while(curr->next != NULL)
       {
           curr = curr->next;
       }
        curr->next = entry;
   }
    
}

int check_sym_tab(char* name) //return a value like integer for checking
{
    /*
        check if table is empty and return a value like 0
        else traverse the table
        if entry is found return a value like 1
        if not return a value like 0
    */
   if(t->head == NULL)
   {
        return 0;
   }

   else
   {
        // printf("%s head\n", t->head->name);
       symbol *curr = t->head;
       while(curr != NULL)
       {
           
           // printf("curr %s\t%s\n", curr->name, name);
           if(strcmp(curr->name, name) == 0)
           {
               return 1;
           }
           else
           {
               curr = curr->next;
           }
            

       }
       return 0;
   }

}

void insert_value_to_name(char *name, char *value)
{
    /*
        if value is default value return back
        check if table is empty
        else traverse the table and find the name
        insert value into the entry structure
    */
   if(strcmp(value, "~") == 0)
   {
       return;
   }
   else
   {
       if(t->head == NULL)
       {
           return;
       }

       else
       {
           symbol *curr = t->head;
           while(curr != NULL)
           {
               if(strcmp(curr->name, name)==0)
               {
                   curr->val = value;
                   return;
               }
               else
               {
                   curr = curr->next;
               }
           }
       }
   }
}

void display_symbol_table()
{
    /*
        traverse through table and print every entry
        with its struct variables
    */
   printf("Name\tSize\tType\tlineno\tScope\tValue\n");
   symbol *curr = t->head;
   while(curr != NULL)
   {
       printf("%s\t%d\t%d\t%d\t%d\t%s\n", curr->name, curr->len, curr->type, curr->line, curr->scope, curr->val);
       curr = curr->next;
   }
}

int size(int type)
{
    if(type == 1)
    {
        return 1;
    }

    else if (type==2)
    {
        return 2;
    }

    else if (type==3)
    {
        return 4;
    }

    else if (type==4)
    {
        return 8;
    }

    else
    {
        return 0;
    }
    
}

char* retrieve_val(char* name)	
{
    symbol *curr = t->head;
    while(curr != NULL)
    {
        if(strcmp(curr->name, name)==0)
        {
            return curr->val;
        }

        curr = curr->next;
    }
    return "null";
}

int retrieve_type(char* name)	
{
    symbol *curr = t->head;
    while(curr != NULL)
    {
        if(strcmp(curr->name, name)==0)
        {
            return curr->type;
        }
        curr = curr->next;
    }
    return -1;
}

/*
int type_check(char* value)
{
    if(value[0] >= '0' && value[0] <= '9')
    {
        // printf("value = %s\n", value);
        float int_value = atof(value);
        // printf("value = %f\n", int_value);

        if(ceil(int_value) == floor(int_value)) //is an integer or is n.0
        {
            if(int_value - floor(int_value)) //returns 0.0 if int_value is a float
            {
                return 2; //int
            }
        }
        else
            return 3; // float or double
        
    }
    else if((value[0] >= 65 && value[0] <= 91) || (value[0] >= 97 && value[1] <= 123))
        return 1; //char

    else
        return 0;

}
*/

int type_check(char* value, char* name)
{
    if(strcmp(value, name) != 0)
    {
        // printf("%s = name", name);
        int x = retrieve_type(name);
        // printf("%d = x\n", x);
        if((x == 1) || (x == 2) || (x == 3) || (x==4))
        {
            return x;
        }
    }
    

    if(value[0] >= '0' && value[0] <= '9')
    {
        for(int i=0; value[i] != '\0'; i++)
        {
            if(value[i] == '.')
            {
                return 3; //float
            }
        }
        return 2; //int
    }
    return 1; //char
}

void update_line(char* name, int yylineno)
{
    //printf("%s\n", name);
    symbol *curr = t->head;
    while(curr != NULL)
    {
        //printf("%s\t%s\n", curr->name, name);
        if(strcmp(curr->name, name)==0)
        {
            //printf("inside func\n");
            //printf("%d linno inside func", yylineno);
            curr->line = yylineno;
            break;
        }

        curr = curr->next;
    }
    return;
}
