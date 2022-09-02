# Homework 1: Rank Aggregation

*CSci 2041: Advanced Programming Principles, Spring 2022 (Section 1)*

**Due:**  Friday, February 18 at 11:59pm

In the `hw2041/hw1` directory, you will find files named `parse.ml`, `rank.ml`, `vote.ml` and several example "input files".
Create a directory named `hw1` in your personal repository, and copy all of these files
to your `hw1` directory.  Don't forget to run `git add` on both the directory and
the files!

**Reminder:** In this class homeworks are a **summative** activity, like an exam.  Therefore, unlike lab exercises and reading quizzes, you should only submit code that is the result of your own work and should not discuss solutions to this homework with anyone but the course staff.  Additionally, course staff can help you with compiler errors and clarifying requirements but will not help you in *solving* the homework problems.

However, you *may* ask clarifying questions about these instructions on `#homework-questions` in the course Discord server.  **No code should be posted in this channel.**

## Background: Command Line programs

Every homework in this class will involve eventually creating a
program that can be run from the "command line" in a terminal.  We will
typically include directions for building these programs in the homework.  They
can be compiled with `ocamlc` or `ocamlopt` to produce executable files. 

Command line programs typically take arguments on the command line, for example,
like `git` or `ssh`.  They also often need to read or write outputs to files, or
in the case of many Unix/linux utilities, can read an input file from the "standard
input" and write to the "standard output."  As you might know, a command line
program's standard input can be "redirected" to use a file with the `<`
operator, and its standard output can be redirected with the `>` operator.  (So
for example, if you type `git status >git.out` in the terminal while your
working directory is within a git repo, the result will go to a file named
`git.out` that you can read with your favorite text editor, or `less`)

## Background: Rank Agggregation

There are a lot of situations in which we have a list of options that we want to
rank (for example, places to eat, movies, sports teams, scholarship awardees,
competitors, construction projects, political candidates...) and a group of
people or measurements that may all produce different rankings of these
candidates, and we need a way to combine, or *aggregate* these rankings into a
single overall ranking.  One way to do this would be to give each option a
"score" - say 1 point for each #1 ranking, 2 points for each #2 ranking, and so
on -- so if the choices are A, B, and C, and we are aggregating the four
rankings "A,B,C", "A,C,B", "C,A,B", "B,C,A", then option "A" would score 1+1+2+3
= 7 points, option "B" would score 2+3+3+1 = 9 points, and option C would score
3+2+1+2 = 8 points -- and then the final ranking would sort the options by
increasing scores, giving us "A,C,B" in our example.  (This is how, for example,
"poll rankings" in college sports are produced).  

This "sum of positions" ranking is simple to understand but it can lead to
strange outcomes, for example if four people are combining rankings of options,
and three have option A before option B, but one has B much earlier than A, then
the combined ranking might prefer B to A even though most people preferred
option A.   Another system, used in the 2021 Tokyo olympics to rank sports
climbers, is to *multiply* the ranks to produce the scores, so in our example
above A's score would be 1*1*2*3 = 6, B's score would be 2*3*3*1 = 12, and C's
score would be 3*2*1*2 = 12.  Or we might be interested only in counting how
many 1st place rankings each option received, or summing the squares of an
option's ranks, or we could look at the *worst* ranking given to each option,
etc. (There is a [general theorem](https://en.wikipedia.org/wiki/Arrow%27s_impossibility_theorem) 
that says that *no rule* for aggregating rankings of more than 2 parties is
perfect, but that doesn't stop us from trying to find a rule that seems to do
the best job for our application.)

## Homework 1: `vote`

In this homework your goal will be to write a command line tool called `vote`
that will allow us to investigate how different aggregation rules lead to
different rankings.  When run from the command line, `vote` will expect two
command-line arguments.  The first argument will specify a "configuration" file
that gives us a formula that tells us how to update the score for an option (or
candidate) given the current score ("aggregate") and its rank (position) in the
next ballot, an initial score to start the aggregation from (usually 1 or 0),
and the list of options that will appear in each ballot, separated by commas.
The second argument will specify a "ballots" file that lists all of the rankings
we will aggregate, one per line, separated by commas.

When run with these inputs, `vote` will compute the scores for each candidate,
and then print out a sorted list of candidate and score pairs, one per line, in
increasing order of score.  (If there are ties, the candidates will be sorted by
lexicographic order.)

For example, the file `mbbtop25.conf` starts with the following lines:
```
a+r
0.0
```
Here, `a+r` means that given a candidate's current (`a`)ggregate score and their
(`r`)ank on the next ballot, we update their aggregate score by adding them
(`a+r`).  The second line, `0.0` indicates that an option's initial score
(before we read any ballots) should be set to `0.0`.  The third line lists the
options we expect to find on the ballots.  The file `mbbtop25.ballots` then
includes the (actual) list of rankings produced by 61 reporters in January 2022,
one per line.  Running the `vote` program with these two files as (command-line)
inputs should produce the following output:
```
% ./vote mbbtop25.conf mbbtop25.ballots
Candidate        Score
-------------    -----
Baylor           61.
Gonzaga          146.
UCLA             210.
Auburn           393.
USC              434.
Arizona          442.
Purdue           447.
Duke             456.
Kansas           555.
MichiganState    575.
Houston          637.
LSU              697.
Wisconsin        813.
Villanova        926.
IowaState        949.
OhioState        1087.
Xavier           1155.
Kentucky         1203.
TexasTech        1268.
SetonHall        1354.
Tennessee        1419.
Providence       1479.
Texas            1513.
Alabama          1580.
Illinois         1598.
LoyolaChicago    1842.
Oklahoma         1860.
Miami            1928.
ColoradoState    2170.
Connecticut      2174.
WestVirginia     2182.
SanDiegoState    2193.
Indiana          2201.
Davidson         2230.
BYU              2244.
Iowa             2244.
SanFrancisco     2244.
```
If you look at the `mbbtop25.ballots` file, you'll notice that several of the
options lower on the list do not appear on most ballots.  The behavior of `vote`
in this situation is to assign any option not appearing in a ballot the rank
`n`, where `n` is the total number of options that might appear on a ballot.

Another example appears in the file `sportclimb.conf`, which starts with the lines:
```
r*a
1.0
```
Here the first line tells `vote` to update an option's aggregate score by
multiplying the aggregate score by the rank, and so that the resulting scores
aren't all 0, the second line says that the score before counting any rankings
should be `1.0`.  Using this configuration with the file `sportclimb.events`
(which is the actual rankings of competitors in the "sport climbing" qualifying
round in the 202~0~1 Tokyo Olympics in the three events that get combined into
one score) should produce the output:
```
% ./vote sportclimb.conf sportclimb.events 
Candidate        Score
----------       -----
MAWEM.M          33.
NARASAKI         56.
DUFFY            60.
SCHUBERT         84.
ONDRA            216.
GINES            294.
MAWEM.B          360.
COLEMAN          550.
MEGOS            684.
CHON             800.
KHAIBULLIN       884.
HOJER            891.
RUBTSOV          960.
PAN              1120.
PICCOLRUAZ       1248.
COSSER           1440.
McCOLL           1680.
HARADA           3060.
FOSSALI          4446.
O'HALLORAN       6460.
```

Of course we could run into trouble because of malformed inputs.  The files
`bestpicture2021.conf` and `bestpicture2021.ballots` are meant to simulate the
voting behavior of the Motion Picture Academy Awards (Oscars), in which over
9000 voters submit a ranking of the (up to 10) movies nominated for "Best
Picture."  (The winner is decided using "instant runoff voting", but `vote`
doesn't support IRV; instead we give each movie 1 point for a 1st-place ranking,
2 for 2nd-place and 3 for any lower rankings.)  But there are some errors: a few
of the ballots rank movies that were not nominated.  Running `vote` with these
files as input will produce an error message:
```
% ./vote bestpicture2021.conf bestpicture2021.ballots 
Line 800 ranks unknown candidate
```
(Removing lines 800-1000 produces the following result:)
```
% ./vote bestpicture2021.conf bestpicture2021.ballots799 
Candidate                        Score
-----------------------          -----
Nomadland                        1992.
TheFather                        1995.
PromisingYoungWoman              2055.
JudasandtheBlackMessiah          2059.
Chicago7                         2071.
Minari                           2164.
SoundofMetal                     2190.
Mank                             2253.
```
Running `vote` with the wrong number of command line arguments will produce no output, and with a file that doesn't exist will produce a fatal error:
```
 ./vote blah blahblah
Fatal error: exception Sys_error("blah: No such file or directory")
```


## A Tour of the application

OK, so now that we know what we're trying to make, we're ready to take a look at the code.
Looking at the files in the `hw1` directory, we see that there are four Ocaml files:

* `config.ml` - the code in this module is responsible for reading configuration
  files as described above.  It contains code to convert string representations
  of scoring rules (like `"a+r"` or `"a + min 3 r"`) into expressions, as well
  as reading the list of candidates. You won't need to change it at all, and it
  uses some features of Ocaml we haven't covered in class yet, so don't worry if
  you don't understand it.  `config.ml` does call some code that you'll need to
  fix in `rank.ml`

* `ballot.ml` - the code in this module is responsible for reading ballot files,
  converting from lists of file lines to lists of ballots (represented as lists
  of strings), checking ballot lists for errors, and printing out the results of
  the scoring.  You'll need to complete some functions in this file, as
  described below.

* `vote.ml` is the "driver" module.  It has code that retrieves the command line
arguments, calls the `config.ml` function to read the config file and the
`ballot.ml` functions to read the ballots and check if all the ballots are
legal.  Next, it calls `score_all` in `rank.ml` to compute a list of (candidate,
score) pairs, and sorts the list by scores.  Finally, it calls some functions in
`ballot.ml` to print out the results.  You shouldn't need to change any code in
this file.

* `rank.ml` is the most "unfinished" file.  It will eventually contain code that:
    + Defines a new data type, `formula` that represents an arithmetic expression for updating a candidate's score
    + Computes an updated score given a `formula`, current score, and rank
    + Computes the score for a single candidate by stepping through each ballot and updating the score
    + Computes the scores for all candidates by stepping through each candidate.
  (Currently there are "type-correct" skeletons for these functions that don't satisfy the requirements)

**Compiling** Compiling the application will require a little bit of care, because some of the files depend on others.  (In particular, `config.ml` calls functions in `rank.ml` and `vote.ml` calls functions in all of the other files.) The correct command line to compile is:

```sh
% ocamlc -o vote rank.ml ballot.ml config.ml vote.ml
```
Note that when you compile you'll get a match case warning for `vote.ml`; you can ignore this because the code in `vote.ml` ensures that the match case is correct.  If it really bothers you AND you don't have any other match warnings, you can add the flags `-w -8` before `-o` in the above command line to suppress the warning.

**NOTE: If an error in one function causes your submission to fail to compile, _all_ of your automated testing scores for that file will be 0.  (This is how auto-grading works: it compiles and runs your code)  If you cannot implement one of these functions in a way that will compile, leave the original version in place and put your best attempt in a comment.**

## Missing Functions

When looking at the "skeleton" functions in `ballot.ml` and `rank.ml` you'll
notice that we have provided the types of the parameters (and in some cases the
result types), to help the compiler test your implementations of these
functions.  For example, the declaration of `ballots_from_lines` in `ballot.ml`:
```ocaml
let ballots_from_lines (blines : string list) : string list list = [] 
```
lets the compiler know that the first (and only, in this case) input to the
function should have type `string list` and the output should have type `string
list list`.  You can safely remove these if you find them distracting, but
leaving them in may help you avoid some headaches when implementing some of the
functions that will eventually depend on full implementations that you haven't
written yet.  Similarly, you can feel free to add the `rec` keyword to any
function declaration if it is needed for your implementation.

### 1. Ballot input (20 points)

The functions `ballots_from_lines` and `first_error` in `ballot.ml` are used in
the reading and validation of ballot/ranking files.  Let's start by filling
these in.

The function `ballots_from_lines : string list -> string list list` should take
as input a list of strings, where each string is a comma-delimited list of
options, and return a list where each element is the list of strings between the
commas in the corresponding position.  So for example, 
`ballots_from_lines ["a,b,c";"1,2"]` should evaluate to 
`[["a";"b";"c"];["1";"2"]]`.  

Some other example evaluations:
+ `ballots_from_lines []` should evaluate to `[]`
+ `ballots_from_lines [""]` should evaluate to `[[]]`
+ `ballots_from_lines ["a";"";"b,c"]` should evaluate to `[["a"]; []; ["b";"c"]]`
You will probably find the Ocaml library function `String.split_on_char` useful for this problem.

The function `first_error : 'a list -> 'a list list -> int option` should take a
list `c` of candidates, and a list `l` of lists, and return the index of the
first list in `l` that has an element that is not an element of `c`, or `None`
if no such element exists.  So for example:

+ `first_error [] []` should evaluate to `None` 
+ `first_error [] [[];[]]` should evaluate to `None` 
+ `first_error [0] [[]]` should evaluate to `None`
+ `first_error [0] [[0]]` should evaluate to `None`
+ `first_error [0] [[2]]` should evaluate to `Some 1`, since the 1st element of
  `[[2]]`, the list `[2]` contains an element, `2`, that is not an element of
  `[0]`.
+ `first_error [0] [[]; [4]]` should evaluate to `Some 2` since the 2nd element
  of `[[];[4]]` contains an element, `4`, that is not an element of `[0]`.

### 2. Result output (20 points)

The file `ballot.ml` also contains two unfinished functions related to "pretty-printing" results, `pad : int -> string -> string` and `max_len : (string*float) list -> int`.  Let's fill them in in reverse order:

`pad : int -> string -> string` ensures that a string has at least as many characters as its first argument, by adding space characters to the end if needed.  So for example:
+ `pad 2 "a"` should evaluate to `"a "` (if you don't see a space after `a` in this example, you may need to switch to "raw" view to correctly read the examples for this function.)
+ `pad 2 "abc"` should evaluate to just `"abc"` since `"abc"` has length 3 > 2.
+ `pad 0 ""` should evaluate to `""`.
+ `pad 3 ""` should evaluate to `"   "` (three spaces.)
+ `pad (-1) "anything"` should evaluate to `"anything"`.

`max_len : (string*float) list -> int` should take a list of `string`,`float` pairs and return the length of the longest string in the list.  Some example evaluations:
+ `max_len []` should evaluate to `0`
+ `max_len [("a",0.)]` should evaluate to `1`
+ `max_len [("abc",0.); ("ab",1.)]` should evaluate to `3`, since the longest string in the list, `"abc"` has length 3.
+ `max_len [("a",3.); ("exterminate!",1.414); ("rtb",3e+14)]` should evaluate to 12 (the length of `"exterminate!"`).

### 3. Ranking, part I: `rank` (10 points)

Moving on to the file `rank.ml`, let's start with a helper function, `rank : 'a
-> float -> 'a list -> float`.  Calling `rank c d ls` should return (the `float`
value of) the index of `c` in `ls`, or `d` if `c` does not appear in `ls`.  Some
example evaluations:

+ `rank 42 2.71828 []` should evaluate to `2.71828` (because `42` does not appear in `[]`).
+ `rank "peekaboo" 4. ["I see you"; "peekaboo"]` should evaluate to `2.` (because rankings are indexed from 1 in `vote`)
+ `rank "a" 7. ["b";"b";"a";"a"]` should evaluate to `3.`
+ `rank 0 3.14 [1;2;3;4]` should evaluate to `3.14`.

### 4. Updating, part I: `formula` (15 points)

The next few questions will transition from computing on lists to computing on
arithmetic expressions.  Remember that the application we are building includes
an arithmetic formula for updating the (`'a'`)ggregate score of an option given
its (`'r'`)ank on the next ballot.  So we'll need a data type to represent these
formulas and to be able to compute the value of the formula given the current
value of `a` and the next value of `r`.  (The application also needs to convert
from a string representation to the recursive data type we'll create.)

To start with, you should replace the `formula` type declaration in `rank.ml`
with a recursive data structure that can represent:
* the sum of two `formula`s (that is, f1 + f2)
* the difference of two `formula`s (i.e. f1 - f2)
* the product of two `formula`s (f1 * f2)
* the division of two `formula`s (f1/f2)
* the maximum of two `formula`s (max (f1,f2))
* the minimum of two `formula`s (min (f1,f2))
* a floating-point constant (like `6.1` or `9.` or `1.12358132134`)
* a variable standing in for the current aggregated score
* a variable standing in for the rank on the next ballot.

You might find it helpful to start with something like the `arithExpr` type we defined in Lab 3.  Make sure you add comments to the file explaining your type declaration.

Once you've declared the type, modify the accessor functions that `parser.ml`
will use to convert from strings to elements of `formula`:
+ `make_add : formula -> formula -> formula` should take two formulas as input
  and return a formula representing their sum.  (e.g. with the `arithExpr`
  constructors, `make_add f1 f2` would evaluate to `AddExpr (f1,f2)`.)
+ `make_sub : formula -> formula -> formula` should take two formulas as input
  and return a formula representing their difference, e.g. `f1-f2`.
+ `make_mul`,`make_div`,`make_max`, and `make_min` should similarly serve as
  functions that call the correct constructors for the multiplication, division,
  maximum, and minimum representations, respectively.
+ `make_float : float -> formula` should apply the leaf constructor for a
  constant to its value.
+ `make_rank : unit -> formula` should return the leaf constructor representing
  the variable for the rank.
+ `make_aggr : unit -> formula` should return the leaf constructor representing
  the variable for the aggregate score.

Since the gitbot won't know how you've defined these constructors, it will just test that the functions all return different values from each other, i.e. the following should all evaluate to `true`:

+ `make_aggr () <> make_rank ()`
+ `make_rank () <> make_float 0.` 
+ `make_float 0. <> make_float 1.`
+ `make_mul (make_float 1.) (make_float 0.) <> make_mul (make_float 1.) (make_float 1.)`
+ `make_mul (make_float 1.) (make_float 0.) <> make_div (make_float 1.) (make_float 0.)`
+ `make_max (make_float 1.) (make_float 0.) <> make_min (make_float 1.) (make_float 0.)`
+ `make_max (make_float 1.) (make_float 0.) <> make_add (make_float 1.) (make_float 0.)`
+ `make_add (make_float 0.) (make_float 1.) <> make_sub (make_float 0.) (make_float 1.)`
 
(In the manual grading step we'll evaluate the correctness and clarity of your
implementation of this portion)

### 5. Updating, part II: `compute` (15 points)

Once we have a data structure to represent the update formulas, we can define
the function `compute : formula -> float -> float -> float`, which given a
formula, the value of the next rank, and the value of the current score,
computes the new score.  (This will be similar to the `arithExpEval` function
from lab 3.)  Some example evaluations:

+ `compute (make_rank ()) 1. 10.` should evaluate to `1.`, since the argument
  indicating the current rank is set to `1.` in this call.
+ `compute (make_aggr ()) 1. 10.` should evaluate to `10.`
+ `compute (make_float 17.) 1. 10.` should evaluate to `17.`
+ `compute (make_sub (make_rank ()) (make_float 1.)) 0. 10.` should evaluate to `-1.`
+ `compute (make_div (make_rank ()) (make_aggr ())) 1. 10.` should evaluate to `0.1`
+ `compute (make_add (make_aggr ()) (make_float 63.)) 1. 32.` should evaluate to `95.`
+ `compute (make_max (make_rank ()) (make_aggr ())) 1. 10.` should evaluate to `10.`
+ `compute (make_min (make_float 5.) (make_rank ())) 3. 1.` should evaluate to `3.`
+ `compute (make_add (make_min (make_float 3.) (make_rank ())) (make_aggr ())) 1. 10.` should evaluate to `11.`
+ `compute (make_mul (make_float 3.) (make_float 2.)) 10. 10.` should evaluate to `6.`

### 6. Ranking, part II: `score` (10 points)

Now that we have a way to compute an updated score for a candidate, we can write
the function `score : 'a -> float -> formula -> float -> 'a list list -> float`
that computes the aggregate score for a candidate given an initial score, update
formula, number of candidates, and list of ballots.  `score c init f n bs`
should iterate through the ballots in `bs`, using `rank` to find the rank of `c`
in each ballot (using `n` as the default value), and using `compute` with `f`,
the current score, and the next rank to update the score.  The result of `score`
is the final updated score.  Some example evaluations:

+ `score "a" 0. (make_add (make_rank ()) (make_aggr ())) 10. []` should evaluate to `0.`
+ `score "a" 0. (make_add (make_rank ()) (make_aggr ())) 10. [[]]` should evaluate to `10.` (because `"a"` does not appear on the first ballot, resulting in the default rank `10.`)
+ `score "a" 0. (make_add (make_rank ()) (make_aggr ())) 10. [["a"]]` should evaluate to `1.`
+ `score "a" 0. (make_add (make_rank ()) (make_aggr ())) 10. [["a"];["b";"a"]]` should evaluate to `3.`
+ `score "a" 1. (make_mul (make_rank ()) (make_aggr ())) 10. [["a"];["b";"a"]]` should evaluate to `2.`
+ `score "a" 1. (make_mul (make_rank ()) (make_aggr ())) 10. [["a"];["b";"a"]; []]` should evaluate to `20.`

### 7. Ranking, part III: `score_all` (10 points)

Finally, we can define the function 
`score_all : 'a list -> float -> formula -> 'a list list -> ('a * float) list`. 
Calling  `score_all cs init f bs` should iterate through the candidates in `cs`,
computing the score of each candidate using the ballot list `bs`, `init` and `f`
as the initial value and formula, and the length of `cs` as the value `n`.  Some
example evaluations:

+ `score_all [] 0. (make_float 0.) []` should evaluate to `[]`.
+ `score_all ["a"] 0. (make_float 1.) []` should evaluate to `[("a",0.)]`
+ `score_all ["a";"b"] 0. (make_float 1.) []` should evaluate to `[("a",0.); ("b",0.)]`
+ `score_all ["a";"b"] 0. (make_rank ()) [["a"]]` should evaluate to `[("a",1.); ("b",2.)]`
+ `score_all ["a";"b";"c"] 0. (make_add (make_rank ()) (make_aggr ())) [["a"]; ["b";"c"]]` 
   should evaluate to `[("a",4.);("b",4.);("c",5.)]`
+ `score_all ["a";"b";"c"] 1. (make_mul (make_rank ()) (make_aggr ())) [["a"]; ["a"]; ["b";"a"]]` 
   should evaluate to `[("a",2.);("b",9.);("c",27.)]`


## Other considerations

In addition to satisfying the functional specifications given above, your code
should be readable, with comments that explain what you're trying to accomplish.
It must compile with `ocamlc -c rank.ml ballot.ml config.ml vote.ml`. Solutions that pay
careful attention to resources like running time and stack space (e.g. using
tail recursion wherever feasible) and code reuse are worth more than solutions
that do not have these properties.

## Submission instructions and extension requests.

Once you are satisfied with the status of your submission in github, you can upload the files `rank.ml` and `ballot.ml` to the "Homework 1" assignment on [Gradescope](https://www.gradescope.com/courses/342332/assignments/1787845).  We will run additional correctness testing to the basic feedback tests described here, and provide some manual feedback on the efficiency, readability, structure and comments of your code, which will be accessible in Gradescope once all homeworks have been graded.

**Extension Requests**: Keep in mind that every student is allowed to request up to 6 24-hour deadline extensions for the four homeworks this semester, but no more than 4 may be used on any single homework.  To request an extension for this homework, please use [this form](https://forms.gle/6rBgM1EJoJYs5QvW9) by the submission deadline on Friday, 2/18.
