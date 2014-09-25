/*
 * CS152 Winter 2013
 * Section: 023
 * Name: Cynthia Kwok - ckwok004@ucr.edu
 * Login: kwokcy
 * Assign: Project Phase 3 Code Generation
 * File: README.txt
 */

to compile:
$ make

to run:
$./parser primes.min > primes.mil
$./mil_run primes.mil < input.txt

$./parser mytest.min > mytest.mil
$./mil_run mytest.mil < input2.txt

to clean:
$ make clean
