/* 
 * CS152 Winter 2013
 * Section: 023
 * Name: Cynthia Kwok - ckwok004@ucr.edu
 * Login: kwokcy
 * Partner: Eric Montijo - emont009@ucr.edu
 * Assign: Project Phase 3 Code Generation
 * File: mini_l.y
 */

%{
  #include "heading.h"
  #include <string>
  #include <sstream>
  #include <map>
  #include <stack>

  int yyerror(const char *s);
  int yylex(void);

  extern int yylines;
  extern char* yytext;
  extern int yycolumn;

  map<string, int> declarations;
  stack<string> ident_stack;
  stack<string> var_stack;
  stack<string> comp_stack;
  stack<string> index_stack;
  stack<string> reverse_stack;
  stack<int> size_stack;
  stack<int> label_stack;
  stack<int> loop_stack;
  stack<int> predicate_stack;

  unsigned int t = 0;
  unsigned int p = 0;
  unsigned int l = 0;
  bool Error = false;
  std::stringstream output;
  string s1 = "";
  string s2 = "";
  string e = "";
%}

%union{
  char* ival;
  char* idval; 
}

%error-verbose
%start input
%token <idval> IDENT
%token <ival> NUMBER
%left PROGRAM
%left BEGIN_PROGRAM
%left END_PROGRAM
%left INTEGER
%left ARRAY
%left OF
%left IF
%left THEN
%left ENDIF
%left ELSE
%left WHILE
%left DO
%left BEGINLOOP
%left ENDLOOP
%left CONTINUE
%left READ
%left WRITE
%left AND
%left OR
%left NOT
%left TRUE
%left FALSE
%left SUB
%left ADD
%left MULT
%left DIV
%left MOD
%left EQ
%left NEQ
%left LT
%left GT
%left LTE
%left GTE
%left SEMICOLON
%left COLON
%left COMMA
%left L_PAREN
%left R_PAREN
%left ASSIGN

%%
input
  : PROGRAM IDENT SEMICOLON block END_PROGRAM {
    if(!Error) {
      for(int i = 0; i < t; i++)
        cout << "\t. t" << i << endl;
      for(int i = 0; i < p; i++)
        cout << "\t. p" << i << endl;
      cout << output.str();
    }
  }
  | error IDENT SEMICOLON block END_PROGRAM
  | PROGRAM error SEMICOLON block END_PROGRAM
  | PROGRAM IDENT error block END_PROGRAM
  | PROGRAM IDENT SEMICOLON block error
  ;

block
  : declaration_l begin_program statement_l 
  | declaration_l error statement_l
  ;

begin_program
  : BEGIN_PROGRAM {
    output << ": START" << endl;
  }
  ;

declaration_l
  : declaration SEMICOLON declaration_l 
  | declaration SEMICOLON 
  | declaration error
  ;

statement_l
  : statement SEMICOLON statement_l 
  | statement SEMICOLON 
  | statement error
  ;

declaration
  : identifier_l COLON INTEGER {
    while(!ident_stack.empty()) {
      output << "\t. " << ident_stack.top() << endl;
      ident_stack.pop();
    }
  }
  | identifier_l COLON ARRAY L_PAREN NUMBER R_PAREN OF INTEGER {
    if(atoi($5) <= 0) {
      e = "Error: declaring an array of size <= 0";
      yyerror(e.c_str());
    }
    while(!ident_stack.empty()) {
      output << "\t.[] " << ident_stack.top() << ", " << atoi($5) << endl;
      declarations[ident_stack.top()] = atoi($5);
      ident_stack.pop();
    }
  }
  | identifier_l error ARRAY L_PAREN NUMBER R_PAREN OF INTEGER 
  | identifier_l COLON error L_PAREN NUMBER R_PAREN OF INTEGER 
  | identifier_l COLON ARRAY error NUMBER R_PAREN OF INTEGER 
  | identifier_l COLON ARRAY L_PAREN error R_PAREN OF INTEGER 
  | identifier_l COLON ARRAY L_PAREN NUMBER error OF INTEGER 
  | identifier_l COLON ARRAY L_PAREN NUMBER R_PAREN error INTEGER 
  | identifier_l COLON ARRAY L_PAREN NUMBER R_PAREN OF error 
  ;

identifier_l
  : ident COMMA identifier_l
  | ident 
  ;

ident
  : IDENT {
    if(declarations.find("_" + string($1)) != declarations.end()) {
      e = "Error: " + string($1) + " was previously defined";
      yyerror(e.c_str());
    }
    declarations["_" + string($1)] = -1;
    ident_stack.push("_" + string($1));
  }
  ;

statement
  : statement1
  | statement2
  | statement3
  | statement4
  | statement5
  | statement6
  | statement7
  ;

statement1
  : var ASSIGN expression1 
  | var error expression1
  ;

expression1
  : expression {
    s2 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s2 << ", "
             << index_stack.top() << endl;
      s2 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    s1 = var_stack.top();
    if(index_stack.top() != "-1") {
      output << "\t[]= " << s1 << ", " << index_stack.top()
             << ", " << s2 << endl;
    }
    else {
      output << "\t= " << s1 << ", " << s2 << endl;
    }
    var_stack.pop();
    index_stack.pop();
  }
  ;

statement2
  : IF bool_exp then statement_l statement2_l
  | IF bool_exp error statement_l statement2_l
  ;

then
  : THEN {
    int s2 = predicate_stack.top();
    predicate_stack.pop();
    output << "\t?:= L" << l << ", p" << s2 << endl;
    label_stack.push(l);
    l++;
  }
  ;

statement2_l
  : else statement_l endif
  | endif
  ;

else
  : ELSE {
    output << "\t:= L" << l << endl;
    output << ": L" << label_stack.top() << endl;
    label_stack.pop();
    label_stack.push(l);
    l++;
  }
  ;

endif
  : ENDIF {
    output << ": L" << label_stack.top() << endl;
    label_stack.pop();
  }
  ;

statement3
  : while bool_exp beginloop statement_l endloop 
  | while bool_exp error statement_l endloop
  | while bool_exp beginloop statement_l error
  ;

while
  : WHILE {
    output << ": L" << l << endl;
    label_stack.push(l);
    loop_stack.push(l);
    l++;
  }
  ;

beginloop
  : BEGINLOOP {
    int s2 = predicate_stack.top();
    predicate_stack.pop();
    output << "\t?:= L" << l << ", p" << s2 << endl;
    label_stack.push(l);
    l++;
  }
  ;

endloop
  : ENDLOOP {
    int s2 = label_stack.top();
    label_stack.pop();
    int s1 = label_stack.top();
    label_stack.pop();
    output << "\t:= L" << s1 << endl << ": L" << s2 << endl;
    loop_stack.pop();
  }
  ;

statement4
  : do BEGINLOOP statement_l endloop1 WHILE bool_exp {
    int s1 = predicate_stack.top();
    predicate_stack.pop();
    int l1 = label_stack.top();
    output << "\t== p" << p << ", p" << s1 << ", 0" << endl;
    output << "\t?:= L" << l1 << ", p" << p << endl;
    p ++;
    label_stack.pop();
  }
  ;

do
  : DO {
    output << ": L" << l << endl;
    label_stack.push(l);
    l++;
    loop_stack.push(l);
    l++;
  }
  ;

endloop1
  : ENDLOOP {
    int l1 = loop_stack.top(); 
    output << ": L" << l1 << endl;
    loop_stack.pop();
  }
  ;

statement5
  : READ var_l {
    while(!var_stack.empty()) {
      if(index_stack.top() == "-1") {
        std::stringstream revout;
        revout << "\t.< " << var_stack.top() << endl;
        reverse_stack.push(revout.str());
      }
      else {
        std::stringstream revout;
        revout << "\t.[]< " << var_stack.top() << ", "
               << index_stack.top() << endl;
        reverse_stack.push(revout.str());
      }
      var_stack.pop();
      index_stack.pop();
    }
    while(!reverse_stack.empty()) {
      output << reverse_stack.top();
      reverse_stack.pop();
    }
  }
  ;

var_l
  : var COMMA var_l 
  | var 
  ;

statement6
  : WRITE var_l {
    while(!var_stack.empty()) {
      if(index_stack.top() == "-1") {
        std::stringstream revout;
        revout << "\t.> " << var_stack.top() << endl;
        reverse_stack.push(revout.str());
      }
      else {
        std::stringstream revout;
        revout << "\t.[]> " << var_stack.top() << ", "
               << index_stack.top() << endl;
        reverse_stack.push(revout.str());
      }
      var_stack.pop();
      index_stack.pop();
    }
    while(!reverse_stack.empty()) {
      output << reverse_stack.top();
      reverse_stack.pop();
    }
  }
  ;

statement7
  : CONTINUE {
    if(!loop_stack.empty()) {
      int s = loop_stack.top();
      output << "\t:= L" << s << endl;
    }
  }
  ;

bool_exp
  : relation_and_exp bool_exp_l {
    int s2 = predicate_stack.top();
    predicate_stack.pop();
    output << "\t== p" << p << ", p" << s2 << ", 0" << endl;
    predicate_stack.push(p);
    p++;
  }
  ;

bool_exp_l
  : OR relation_and_exp bool_exp_l {
    int s2 = predicate_stack.top();
    predicate_stack.pop();
    int s1 = predicate_stack.top();
    predicate_stack.pop();
    output << "\t|| p" << p << ", p" << s1 << ", p" << s2 << endl;
    predicate_stack.push(p);
    p++;
  }
  | 
  ;

relation_and_exp
  : relation_exp relation_and_exp_l 
  ;

relation_and_exp_l
  : AND relation_exp relation_and_exp_l {
    int s2 = predicate_stack.top();
    predicate_stack.pop();
    int s1 = predicate_stack.top();
    predicate_stack.pop();
    output << "\t&& p" << p << ", p" << s1 << ", p" << s2 << endl;
    predicate_stack.push(p);
    p++;
  }
  | 
  ;

relation_exp
  : relation_exp1
  | relation_exp2
  | relation_exp3
  | relation_exp4
  ;

relation_exp1
  : expression comp expression {
    s2 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s2 << ", "
             << index_stack.top() << endl;
      s2 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    s1 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s1 << ", "
             << index_stack.top() << endl;
      s1 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    string c = comp_stack.top();
    comp_stack.pop();
    output << "\t" << c << " p" << p << ", " << s1 << ", " << s2 << endl;
    predicate_stack.push(p);
    p++;
  }
  | NOT expression comp expression {
    s2 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "  =[] t" << t << ", " << s2 << ", "
             << index_stack.top() << endl;
      s2 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    s1 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s1 << ", "
             << index_stack.top() << endl;
      s1 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    string c = comp_stack.top();
    comp_stack.pop();
    output << "\t" << c << " p" << p << ", " << s1 << ", " << s2 << endl;
    p++;
    output << "\t== p" << p << ", p" << p-1 << ", 0" << endl;
    predicate_stack.push(p);
    p++;
  }
  ;

relation_exp2
  : TRUE {
    output << "\t== p" << p << ", 1, 1" << endl;
    predicate_stack.push(p);
    p++;
  }
  | NOT TRUE {
    output << "\t== p" << p << ", 1, 0" << endl;
    predicate_stack.push(p);
    p++;
  }
  | NOT error
  ;

relation_exp3
  : FALSE {
    output << "\t== p" << p << ", 1, 0" << endl;
    predicate_stack.push(p);
    p++;
  }
  | NOT FALSE {
    output << "\t== p" << p << ", 1, 1" << endl;
    predicate_stack.push(p);
    p++;
  }
  ;

relation_exp4
  : L_PAREN bool_exp R_PAREN 
  | NOT L_PAREN bool_exp R_PAREN 
  | L_PAREN bool_exp error
  | NOT L_PAREN bool_exp error
  ;

comp
  : EQ {
    comp_stack.push("==");
  }
  | NEQ {
    comp_stack.push("!=");
  }
  | LT {
    comp_stack.push("<");
  }
  | GT {
    comp_stack.push(">");
  }
  | LTE {
    comp_stack.push("<=");
  }
  | GTE {
    comp_stack.push(">=");
  }
  ;

expression
  : multiplicative_exp expression_l
  ;

expression_l
  : ADD multiplicative_exp expression_l {
    s2 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s2 << ", "
             << index_stack.top() << endl;
      s2 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    s1 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s1 << ", "
             << index_stack.top() << endl;
      s1 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    output << "\t+ t" << t << ", " << s1 << ", " << s2 << endl;
    std::stringstream revout;
    revout << t;
    var_stack.push("t" + revout.str());
    index_stack.push("-1");
    t++;
  }
  | SUB multiplicative_exp expression_l {
    s2 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s2 << ", "
             << index_stack.top() << endl;
      s2 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    s1 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s1 
             << index_stack.top() << endl;
      s1 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    output << "\t- t" << t << ", " << s1 << ", " << s2 << endl;
    std::stringstream revout;
    revout << t;
    var_stack.push("t" + revout.str());
    index_stack.push("-1");
    t++;
  }
  |
  ;

multiplicative_exp
  : term multiplicative_exp_l
  ;

multiplicative_exp_l
  : MULT term multiplicative_exp_l {
    s2 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s2 << ", "
             << index_stack.top() << endl;
      s2 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    s1 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "\t=[] t" << t << ", " << s1 << ", "
             << index_stack.top() << endl;
      s1 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    output << "  * t" << t << ", " << s1 << ", "  << s2 << endl;
    std::stringstream revout;
    revout << t;
    var_stack.push("t" + revout.str());
    index_stack.push("-1");
    t++;
  }
  | DIV term multiplicative_exp_l {
    s2 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "  =[] t" << t << ", " << s2 << ", "
             << index_stack.top() << endl;
      s2 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    s1 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "  =[] t" << t << ", " << s1 << ", "
             << index_stack.top() << endl;
      s1 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    output << "  / t" << t << ", " << s1 << ", " << s2 << endl;
    std::stringstream revout;
    revout << t;
    var_stack.push("t" + revout.str());
    index_stack.push("-1");
    t++;
  }
  | MOD term multiplicative_exp_l {
    s2 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "  =[] t" << t << ", " << s2 << ", "
             << index_stack.top() << endl;
      s2 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    s1 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "  =[] t" << t << ", " << s1 << ", "
             << index_stack.top() << endl;
      s1 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    index_stack.pop();
    output << "  % t" << t << ", " << s1 << ", " << s2 << endl;
    std::stringstream revout;
    revout << t;
    var_stack.push("t" + revout.str());
    index_stack.push("-1");
    t++;
  }
  |
  ;

term
  : var 
  | SUB var {
    s2 = var_stack.top();
    if(index_stack.top() != "-1") {
      std::stringstream revout;
      revout << t;
      output << "  =[] t" << t << ", " << s2 << index_stack.top() << endl;
      s2 = "t" + revout.str();
      t++;
    }
    var_stack.pop();
    output << "  - t" << t << ", 0, " << s2 << endl;
    std::stringstream revout;
    revout << t;
    var_stack.push("t" + revout.str());
    index_stack.push("-1");
    t++;
  }
  | NUMBER {
    var_stack.push(string($1));
    index_stack.push("-1");
  }
  | SUB number
  | SUB error
  | L_PAREN expression R_PAREN
  | SUB L_PAREN expression R_PAREN {
    s2 = var_stack.top();
    var_stack.pop();
    output << "  - t" << t << ", 0, " << s2 << endl;
    std::stringstream revout;
    revout << t;
    var_stack.push("t" + revout.str());
    index_stack.push("-1");
    t++;
  }
  | L_PAREN expression error
  | SUB L_PAREN expression error
  ;

number
  : NUMBER {
    output << "  - t" << t << ", 0, " << string($1) << endl;
    std::stringstream revout;
    revout << t;
    var_stack.push("t" + revout.str());
    index_stack.push("-1");
    t++;
  }
  ;

var
  : idente {
    map<string, int>::iterator it;
    it = declarations.find(var_stack.top());
    if(it != declarations.end()) {
      if((*it).second != -1) {
        e = "Error: array " 
          + var_stack.top().substr(1, var_stack.top().length()-1)
          + " requires an index";
        yyerror(e.c_str());
      }
    }
    index_stack.push("-1");
  }
  | idente l_paren expression R_PAREN {
    index_stack.pop();
    index_stack.push(var_stack.top());
    var_stack.pop();
  }
  ;

l_paren
  : L_PAREN {
    map<string, int>::iterator it;
    it = declarations.find(var_stack.top());
    if(it != declarations.end()) {
      if((*it).second == -1) {
        e = "Error: variable "
          + var_stack.top().substr(1, var_stack.top().length()-1)
          + " does not require an index";
        yyerror(e.c_str());
      }
    }
  }
  ;

idente
  : IDENT {
    string s = string($1);
    if(declarations.find("_" + s) == declarations.end()) {
      e = "Error: " + s + " was not declared";
      yyerror(e.c_str());
    }
    else if(s == "program"    || s == "beginprogram" ||
            s == "endprogram" || s == "integer" ||
            s == "array"      || s == "of" ||
            s == "if"         || s == "then" ||
            s == "endif"      || s == "else" ||
            s == "while"      || s == "do" ||
            s == "beginloop"  || s == "endloop" ||
            s == "continue"   || s == "read" ||
            s == "write"      || s == "and" ||
            s == "or"         || s == "not" ||
            s == "true"       || s == "false") {
      e = "Error: " + string($1) + " is a keyword";
      yyerror(e.c_str());
    }
    var_stack.push("_" + string($1));
  }
  ;
%%

int yyerror(const char *e)
{
  printf("%s, at symbol %s on line %d\n", e, yytext, yylines);
  return 0;
}

