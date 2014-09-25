/*
 * CS152 Winter 2013
 * Section: 023
 * Name: Cynthia Kwok
 * Login: kwokcy
 * Email: ckwok004@ucr.edu
 * Assign: Project Phase 2 Parser Generating Using bison
 * File: mini_l.lex
 */

%{
    #include "heading.h"
    //#include "mini_l.tab.h"
    //#include "tok.h"
    #include "y.tab.h"
    int yyerror(char *s);
    int yylines = 1;
    int yycolumn = 1;
%}

DIGIT   [0-9]
LETTER  [a-zA-Z]
UNDER   [_]
WHITE   [ \t]

%%
\(    {yycolumn += yyleng; return L_PAREN;}
\)    {yycolumn += yyleng; return R_PAREN;}
\-    {yycolumn += yyleng; return SUB;}
\*    {yycolumn += yyleng; return MULT;}
\/    {yycolumn += yyleng; return DIV;}
\%    {yycolumn += yyleng; return MOD;}
\+    {yycolumn += yyleng; return ADD;}
\<    {yycolumn += yyleng; return LT;}
\<\=  {yycolumn += yyleng; return LTE;}
\>    {yycolumn += yyleng; return GT;}
\>\=  {yycolumn += yyleng; return GTE;}
\=\=  {yycolumn += yyleng; return EQ;}
\<\>  {yycolumn += yyleng; return NEQ;}

not {yycolumn += yyleng; return NOT;}
and {yycolumn += yyleng; return AND;}
or  {yycolumn += yyleng; return OR;}

\:\=  {yycolumn += yyleng; return ASSIGN;}

program       {yycolumn += yyleng; return PROGRAM;}
beginprogram  {yycolumn += yyleng; return BEGIN_PROGRAM;}
endprogram    {yycolumn += yyleng; return END_PROGRAM;}
integer       {yycolumn += yyleng; return INTEGER;}
array         {yycolumn += yyleng; return ARRAY;}
of            {yycolumn += yyleng; return OF;}
if            {yycolumn += yyleng; return IF;}
then          {yycolumn += yyleng; return THEN;}
endif         {yycolumn += yyleng; return ENDIF;}
else          {yycolumn += yyleng; return ELSE;}
while         {yycolumn += yyleng; return WHILE;}
do            {yycolumn += yyleng; return DO;}
beginloop     {yycolumn += yyleng; return BEGINLOOP;}
endloop       {yycolumn += yyleng; return ENDLOOP;}
continue      {yycolumn += yyleng; return CONTINUE;}
read          {yycolumn += yyleng; return READ;}
write         {yycolumn += yyleng; return WRITE;}
true          {yycolumn += yyleng; return TRUE;}
false         {yycolumn += yyleng; return FALSE;}

\:  {yycolumn += yyleng; return COLON;}
\;  {yycolumn += yyleng; return SEMICOLON;}
\,  {yycolumn += yyleng; return COMMA;}

##.*$ {}
\n    {++yylines; yycolumn = 1;}

{DIGIT}+  {yycolumn += yyleng; yylval.ival = yytext; return NUMBER;}
{WHITE}+  {yycolumn += yyleng;}


{LETTER}+(({UNDER}|{DIGIT}|{LETTER})*({DIGIT}|{LETTER})+)* {
    yylval.idval = yytext;
    yycolumn += yyleng;
    return IDENT;
}
({DIGIT}|{UNDER})+({UNDER}|{DIGIT}|{LETTER})*{LETTER}+ {
    printf("Error at line %i, yycolumn %i: identifier \"%s\" must begin with a letter\n", yylines, yycolumn, yytext);
    return 1;
}
{LETTER}+({UNDER}|{DIGIT}|{LETTER})*{UNDER}+ {
    printf("Error at line %i, yycolumn %i: identifier \"%s\" cannot end with an underscore\n", yylines, yycolumn, yytext);
    return 1;
}

. {
    printf("Error at line %i unrecognized symbol \"%s\"\n",yylines, yytext);
    return 1;
}

%%
