/*
 * CS152 Winter 2013
 * Section: 023
 * Name: Cynthia Kwok
 * Login: kwokcy
 * Email: ckwok004@ucr.edu
 * Assign: Project Phase 2 Parser Generation Using bison
 * File: main.cc
 */

#include "heading.h"

int yyparse();

int main(int argc, char **argv)
{
  if((argc > 1) && (freopen(argv[1], "r", stdin) == NULL))
  {
    cerr << argv[0] << ": File " << argv[1] << " cannot be opened.\n";
    exit(1);
  }

  yyparse();

  return 0;
}
