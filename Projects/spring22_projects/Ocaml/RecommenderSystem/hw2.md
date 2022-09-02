# Homework 2:  You might also like... OCaml(?)
*CSci 2041: Advanced Programming Principles, Spring 2022 (Section 1)*

**Due:** Friday, March 18 at 11:59pm

In the `hw2041/hw2` directory, you will find files named `rating.ml`,
`rating.mli`, `similar.ml`, `rec.ml` and several example input files. Create a
directory named `hw2` in your personal repository, and copy all of these files
to your `hw2` directory.  Don't forget to run `git add` on both the directory
and the files!

**Reminder:** In this class homeworks are a summative activity.  Therefore, unlike lab problmes and reading quizzes, you should only submit code that is the result of your own work and should not discuss solutions to this homework with anyone but the course staff. Additionally, course staff can help you with compiler errors and clarifying requirements but will not help you in *solving* the homework problems.

However, you *may* ask clarifying questions about these instructions on `#hw2-questions` in the course Discord server.  **No code should be posted in this channel.**

## Overview: Recommender systems

If you have ever watched a video on youtube, streamed a song on spotify, logged into netflix, or searched for a book on amazon, you probably noticed that the system also recommended some other videos, songs, movies or books for you to watch.  These recommendations are based on an algorithm called a "recommender system," and in this homework, we'll look at one way such systems can be constructed.  (There are a *lot* of extra features and other algorithms used besides the basic one we'll build here; in fact, the CSci department has an entire graduate course on the topic, CSci 5123)

The basic idea behind recommender systems is that a collection of *users* each contribute some sort of *rating* (e.g., "like"/"don't like", "upvote"/"downvote", "10 out of 10"...) on some *items* from a collection.  Then using these ratings the system tries to either find users who have similar ratings on many items (user/user similarity) or items that have similar ratings from many users (item/item similarity).  In the second case, the idea is that if many users had a similar opinion of both items, then they must have something in common.  We'll build an application that uses item/item similarity to find other items similar to a given item.

## Homework 2: `rec`

In this homework your goal will be to write a terminal application called `rec` that will use a database of items and ratings to produce recommendations.  In particular, when we start the program `rec`, it will ask the user for the name of a database file (more about the format of this file in a few paragraphs), then ask the user for a "short name" of the item to make a recommendation for, and how many recommendations to output, and give a formatted list of recommended items, sorted by most similar to least similar.  The program then will ask the user whether they would like recommendations for another item, and either exit or repeat the process for another item.  Here's an example terminal transcript from the application:

```
% ./rec
Enter name of ratings file: jokes.csv
Enter name of item to search for: boomerang
How many suggestions do you want? (1-5): 3

#  score	name: description
== ======	===================
1)  0.201	neutron bar: "A neutron walks into a bar and orders a drink. ""How much do I owe you?"" the neutron asks.  The bartender replies‚ ""for you‚ no charge."""
2)  0.187	shredder: "The new employee stood before the paper shredder looking confused.""Need some help?"" a secretary asked. ""Yes‚"" he replied. ""How does this thing work?"" ""Simple‚"" they said‚ taking the fat report from his hand and feeding it into the shredder.""Thanks‚ but where do the copies come out?"""
3)  0.183	walk a mile: Just a thought ..  Before criticizing someone‚ walk a mile in their shoes.    Then when you do criticize them‚  you will be a mile away and have their shoes !
Make another recommendation? (y/n): y
Enter name of item to search for: neutron bar
How many suggestions do you want? (1-5): 5

#  score	name: description
== ======	===================
1)  0.229	atoms: "Two atoms are walking down the street when one  atom says to the other  ""Oh‚ my! I've lost an electron!""  The second atom says""Are you sure""  The first replies ""I'm positive!"""
2)  0.215	antigravity: I'm reading a great book about antigravity -- I just can't put it down.
3)  0.204	invisible patient: Nurse: Doctor‚ Doctor‚ there's an invisible man in the waiting room! Doctor: Well‚ go in there and tell him that I can't see him!
4)  0.201	boomerang: Q: What is the Australian word for a boomerang that won't    come back?   A: A stick
5)  0.200	shampoo: "Q: How do you keep a computer programmer in the  shower all day long?  A: Give them a shampoo with a label that says ""rinse‚ lather‚ repeat""."
Make another recommendation? (y/n): n
```

If you open `jokes.csv` in a text editor you'll see that this "database" consists of lines of text that have one of two forms.  Either the line describes an "item", and has the format `i,<#>,<name>,<description>` where `<#>` is an integer "handle" for the item, or the line is a "rating" and has the format `r,<u#>,<i#>,±1`, where `<u#>` is an integer "handle" for a user, `<i#>` is an integer "handle" for an item, and the rating is either `1` ("like") or `-1` ("didn't like").  If we were programming a system where users entered ratings, we might have a third type of line for users, but since we are just looking at making the recommendations, we'll keep it simple and leave information about the users out of our database.  (We could also use a wider range of ratings, but keeping them as ±1 makes some of our math work out easier).

So when the user enters an item name (like `boomerang` or `neutron bar` above) our program will need to translate this into an item handle so that it can find ratings of the item.  Then we need to compute a "similarity score" between the chosen item and every other item in the database.  Our program will use a widely-used score called the "cosine similarity" (If you've had linear algebra: we treat every item as a vector with components for every user, with ratings in {-1,0,1}, and compute the cosine of the angle between these vectors, which is the dot product of the vectors divided by the product of their lengths.  If you haven't had linear algebra: don't worry about that): in our case this is (the number of users who rated both items +1 plus the number of users who rated both items -1 minus the number of users who gave opposite ratings for the items), divided by the square root of (the number of ratings of the chosen item times the number of ratings of the second item).  In "math" we have

<center><code>sim(a,b)</code>=<span style="font-size:150%">&Sum;</span><sub><code>u</code></sub><code>rating(u,a)*rating(u,b)</code> / <big>(&Sqrt;</big>(<code>len(ratings(a))*len(ratings(b))</code>)<big>)</big></center>

Where `rating(u,a)` is the rating of user `u` for item `a` (or 0 if no rating is present in the database) and `ratings(a)` is the list of ratings for item `a`. So if more people agreed on the rating of an item they are more similar, but items with more ratings won't be similar just because more people rated them.

Once we have computed the similarities between the chosen item and every other item, we'll need to sort by similarity, and then take the top k (for the number of recommendations the user asked for) for printing out.  (Note: the chosen item will always have similarity 1.0 to itself, and be the "most similar", so you'll want to either exclude it from your computations or skip it in the sorted list...)  then the final step is to format the output nicely, and ask the user whether to make more recommendations.

There are several other rating databases in the `hw2` folder; some of these are for testing error-handling in your code, and some are "real" rating data.  For example, the `jokes.csv` file referenced above comes from the "jester" [data set](https://goldberg.berkeley.edu/jester-data/) (with several offensive items removed), and the `books20k.csv` comes from the "Book-crossing" [data set](https://grouplens.org/datasets/book-crossing/).  We also collected the `music.csv` and `coffee.csv` data sets from students in this class.  The `books20k.csv` data set is very large and serves as a good test of the efficiency of your algorithms, so you could consider being able to process it as a stretch goal for this project.  Here are some example transcripts from these data sets:

```
% ./rec                  
Enter name of ratings file: music.csv
Enter name of item to search for: prince
How many suggestions do you want? (1-5): 5

# 	score 	name: description
==	======	===================
1)	 0.667	dylan: Bob Dylan
2)	 0.470	lizzo: Lizzo
3)	 0.255	hippocampus: Hippo Campus
4)	 0.136	suburbs: The Suburbs
5)	 0.130	replacements: The Replacements
Make another recommendation? (y/n): y
Enter name of item to search for: turtles
How many suggestions do you want? (1-5): 5

# 	score 	name: description
==	======	===================
1)	 0.737	soulasylum: Soul Asylum
2)	 0.657	arcwelder: Arcwelder
3)	 0.622	atb: After the Burial
4)	 0.607	cadillac: Cadillac Blindside
5)	 0.578	motioncity: Motion City Soundtrack
Make another recommendation? (y/n): n
```

```
% ./rec
Enter name of ratings file: coffee.csv
Enter name of item to search for: frenchmeadow
How many suggestions do you want? (1-5): 5

# 	score 	name: description
==	======	===================
1)	 0.425	einstein:  [Einstein Bros]
2)	 0.354	fultonst:  [Fulton Street Cafe]
3)	 0.318	btown:  [Bordertown Coffee]
4)	 0.312	7corners:  [7 corners coffee]
5)	 0.269	brueggers:  [Bruegger's]
Make another recommendation? (y/n): y
Enter name of item to search for: mitea
How many suggestions do you want? (1-5): 5

# 	score 	name: description
==	======	===================
1)	 0.588	btown:  [Bordertown Coffee]
2)	 0.556	sugartiger:  [SUGAR TIGER]
3)	 0.545	mumu:  [Mu Mu Tea]
4)	 0.443	wbcaribou:  [West bank caribou]
5)	 0.417	hub:  [The HUB Caribou]
Make another recommendation? (y/n): n
```

```
% ./rec
Enter name of ratings file: books20k.csv
Enter name of item to search for: interview with the vampire
How many suggestions do you want? (1-5): 5

#  score	name: description
== ======	===================
1)  0.210	the queen of the damned: The Queen of the Damned (Vampire Chronicles (Paperback)); Anne Rice; 1993
2)  0.186	the vampire lestat: The Vampire Lestat (Vampire Chronicles Book II); ANNE RICE; 1986
3)  0.136	memnoch the devil: Memnoch the Devil (Vampire Chronicles No 5); Anne Rice; 1997
4)  0.121	the witching hour: The Witching Hour (Lives of the Mayfair Witches); ANNE RICE; 1993
5)  0.109	pandora: Pandora: New Tales of the Vampires (New Tales of the Vampires); Anne Rice; 1999
Make another recommendation? (y/n): y
Enter name of item to search for: foundation
How many suggestions do you want? (1-5): 5

#  score	name: description
== ======	===================
1)  0.219	the caves of steel: The Caves of Steel; Isaac Asimov; 1991
2)  0.201	on basilisk station..: On Basilisk Station (Honor Harrington (Paperback)); David Weber; 2002
3)  0.201	nun in the closet.: Nun in the Closet; DOROTHY GILMAN; 1986
4)  0.201	elric of melnibone: Elric of Melnibone (Elric); Michael Moorcock; 1996
5)  0.201	white shell woman.: White Shell Woman; James D. Doss; 2002
Make another recommendation? (y/n): n
```

## A Tour of the application

OK, so now that we know what we're trying to make, we're ready to take a look at the code.
Looking at the files in the `hw2` directory, we see that there are four ocaml files:

* `rating.mli` - this file specifies the **interface** to the `rating` module that the other modules in the program will
  interact with.  It specifies that there are "abstract" types `ih` and `uh` for item handles and user handles, and `db`
  for rating databases.  We make these types abstract so that the compiler can help prevent the rest of the program from
  trying to look up nonexistent users or items: the only way to get a value of type `Rating.uh`, `Rating.ih` or
  `Rating.db` is through the interface we provide.  Besides specifying these abstract types, the interface specifies the
  functions for reading a database from a file (`from_file`), translating between an item name and an item handle
  (`iname_from_handle` and `handle_from_iname`), and looking up item descriptions (`description_from_handle`) as well as
  specific ratings (`get`), the list of item handles in a database (`get_items`), the list of ratings for a particular
  item (`get_item`), and the list of user handles in the database (`get_users`). There are also several exceptions declared that might be raised when reading a ratings database file.
  ***You should not modify this file!***  Our grading scripts will use the unmodified file when compiling your submission, so if your `rating.ml` file doesn't match the unmodified interface, you'll receive no autograder points for it.

* `rating.ml` - this file should implement the interface given in the `rating.mli` file.  The type declarations for `uh` and `ih` are provided, and type-correct "skeletons" of the other functions are provided, but this is where most of the work will go.  We'll describe the requirements for the functions in this module in further detail below.

* `similar.ml` - this file should implement two functions: `similarity` computes the similarity between two items given the rating database and their handles, and `top_k` takes a rating database, an item handle, and an integer k, and returns the k most similar items in the database.

* `rec.ml` - this is the "driver" module that collects user input, calls the appropriate functions from `rating.ml` and `similar.ml`, and prints out the results.   Some of the code for this module is provided, but you'll need to fill in the rest, as described below.

**Compiling** Compiling the application will require a little bit of care, because some of the files depend on others.  In particular, to enforce the `rating.mli` interface we need to include it before the `rating.ml` file; and `similar.ml` will need to call functions in `rating.ml` to do its job, and `rec.ml` will need to call functions in both to work.  So the correct command to compile the application is:

```sh
% ocamlc -o rec rating.mli rating.ml similar.ml rec.ml
```

Note that because working with larger rating files will involve a lot of computation, you may want to use the optimizing ocaml compiler, in which case you can replace `ocamlc` with `ocamlopt` in the above command line.

**Slow and Steady Wins The Race**: Although there are some points reserved for more efficiently implementing this project, a well-documented, easy to read, and correct submission can still earn an "A" grade (90/100) with inefficient algorithms.  So your best strategy is to first focus on producing a correct implementation, and only once you have such an implementation should you start thinking about more efficient methods of implementing this project.

**NOTE: If an error in one function causes your submission to fail to compile, _all_ of your automated testing scores for that file will be 0.  (This is how auto-grading works: it compiles and runs your code)  If you cannot implement one of these functions in a way that will compile, leave the original version in place and put your best attempt in a comment.**

## Missing Functions

### 1. `Rating.db` type (5 points)

Fill in the type declaration in the `rating.ml` file for the `db` type.  There are many different possible representations you might choose, but one possible starting point is a record with fields that contain the different kinds of information we'll need to retrieve fromt the database: the list of item handles, an associative list mapping between handles and names, another associative list mapping between handles and descriptions, the list of users, and a list of ratings provided for the various items and users in the database file.

Be sure to include a comment explaining the representation you've chosen, so a TA or future maintainer knows how to access the information in a `Rating.db` value.

### 2. `from_file` (20 points)

This is the most complex function in this project: `from_file : string -> db` should take a file name, and read a rating database from that file in the format specified above: every line in the file should either:

+ start with `i,` and be followed by an integer "item handle", a name, and a description, separated by comma characters (`','`).  These lines specify an item, and if there are not exactly 4 fields, or the first comma-separated field after `i` does not contain an integer, the function should raise a `LineFormatError` exception.
+ start with `r,` and be followed by an integer "user handle", an integer "item handle", and a rating, either 1 or -1. As in the previous case, if there are not exactly 4 fields, or the second or third field do not contain integers, or the last field cannot be converted to a float, the function should raise a `LineFormatError` exception.

If a line in the input file does not match one of these two cases, a `LineFormatError` should be raised as well.

After reading the input file, a `db` item should be created, but several additional checks must also be applied:

+ if two item lines have the same handle, an `ItemError` should be raised.
+ if two item lines have the same "short name", an `ItemError` should be raised
+ if there was a rating for an item handle, but no item line for that handle in the file, a `RatingError` should be raised
+ if there was a rating that was not `1.` or `-1.`, a `RatingError` should be raised.
+ if the file included two ratings for the same user handle and item handle, a `RatingError` should be raised.

Note: you will probably find the `List.sort_uniq` function very helpful in implementing some of these checks.  A further general note: if you are storing lists of pairs and using functions like `map`, `filter`, and `fold_left` to access these pairs, you might find it useful to know that Ocaml has built in functions `fst : 'a*'b -> 'a` and `snd : 'a*'b -> 'b` that return the first and second elements of a pair, respectively.

The `hw2` directory includes several files that can help check these error conditions:

+ The files `lerr1.csv`, `lerr2.csv`, `lerr3.csv`, `lerr4.csv`, `lerr5.csv`, `lerr6.csv` should all cause `from_file` to raise a `LineFormatError`

+ The files `ierr1.csv` and `ierr2.csv` should cause `from_file` to raise a `ItemError`

+ The files `rerr1.csv`, `rerr2.csv`, and `rerr3.csv` should cause `from_file` to raise a `RatingError` (`rerr1.csv` has a rating for a non-existent item; `rerr2.csv` has a rating that is not +1 or -1; and `rerr3.csv` contains a repeat user,item pair.)

+ The files `empty.csv`, `ok1.csv`, and `ok2.csv` should load without causing any errors.

A few other notes: it will probably improve the readability of your code and make the problem easier to solve if you write separate functions to check for the possible error types, and then call these functions from `from_file`.  Since the `rating.mli` interface doesn't name these functions, it is perfectly acceptable for these definitions to be at the module scope, rather than defined locally inside the `from_file` definition.  As noted in the overview, there are certainly opportunities to write more efficient algorithms to implement these checks, based on how you choose the data structure to represent a `Rating.db`, but your first focus should be on a correct and clearly readable implementation.

### 3. `iname_from_handle`, `handle_from_iname`, `description_from_handle`, `get_items` (20 points)

Once we have a data type to represent a rating database, and a function to read one from a file, we can write functions to allow access to the database from other modules.  Note: because the autograder has no way to create ratings databases except through your `from_file` implementation, the test cases for this section will only work if `from_file` is already implemented.  Let's start with four functions that involve just the items in the database:

+ `iname_from_handle : db -> ih -> string` should take a database and an item handle, and return the name associated with that handle in the database.  Since there is no way to create a handle except through the rating interface, `iname_from_handle` can raise `Not_found` if the database does not include the handle argument.  Some example evaluations:
    * `iname_from_handle (from_file "ok1.csv") 4` should evaluate to `"four"`
    * `iname_from_handle (from_file "ok1.csv") 1` should raise `Not_found`
    * `iname_from_handle (from_file "ok2.csv") 314159` should evaluate to `"pi"`

+ `handle_from_iname : db -> string -> ih option` should try to find the item handle for a given name, e.g. if there is a handle `h` for name `n` in database `d` then `handle_from_iname d n` should return `Some i`.  If there is no item handle for the item name, `handle_from_iname` should return `None`.  Some example evaluations:
    * `handle_from_iname (from_file "ok1.csv") "thirteen"` should evaluate to `Some 13`
    * `handle_from_iname (from_file "ok1.csv") "slitheen"` should evaluate to `None`
    * `handle_from_iname (from_file "ok2.csv") "pi"` should evaluate to `Some 314159`

+ `description_from_handle : db -> ih -> string` should take a database and an item handle, and return the item description associated with that handle in the database.  Like with `iname_from_handle`, this function should raise `Not_found` if the given handle is not present in the database.  Example evaluations
    * `description_from_handle (from_file "ok1.csv") 4` should evaluate to `"Tom Baker"`
    * `description_from_handle (from_file "ok1.csv") 5` should raise `Not_found`
    * `description_from_handle (from_file "ok2.csv") 271828` should evaluate to `"Euler's constant"`

+ `get_items : db -> ih list` should return a list of all item handles in a ratings database, with no repeated elements.  Some example evaluations:
    * `get_items (from_file "empty.csv")` should evaluate to `[]`
    * `get_items (from_file "ok1.csv")` should evaluate to `[13;12;11;10;9;4]` (possibly in a different order)
    * `get_items (from_file "ok2.csv")` should evluate to `[314159;271828;161803;3;2;1]` (possibly in a different order)

Manual scores for this section and the next will include components for readability, code reuse (for example, using `List` module functions where appropriate), and efficiency.

### 4. `get`, `get_item`, and `get_users` (15 points)

We can finish up the rating module with the functions that depend on the ratings in a database:

+ `get_users : db -> uh list` should return a list of all the user handles that rate at least one item in the database, with no repeated elements.  Some example evaluations:
  * `get_users (from_file "empty.csv")` should evaluate to `[]`
  * `get_users (from_file "ok1.csv")` should evaluate to `[101;102;103;104;105;106;107]` (possibly in a different order)
  * `get_users (from_file "ok2.csv")` should evaluate to `[102;103;104]` (possibly in a different order)

+ `get : db -> ih -> uh -> float` should return the rating for a given item and handle in the database.  If no rating is found, `get` should return `0.`.  Some example evaluations:
  * `get (from_file "ok1.csv") 4 103` should evaluate to `-1.`
  * `get (from_file "ok1.csv") 4 106` should evaluate to `0.`
  * `get (from_file "ok2.csv") 314159 102` should evaluate to `1.`

+ `get_item : db -> ih -> (uh * float) list` should return the list of all user handle, rating pairs in the database for the given item handle.  Some example evaluations:
  * `get_item (from_file "ok1.csv") 4` should evaluate to `[(105, -1.); (104, 1.); (103, -1.); (101, 1.)]`
  * `get_item (from_file "ok1.csv") 13` should evaluate to `[(105, 1.); (101, 1.)]`
  * `get_item (from_file "ok2.csv") 314159` should evaluate to `[(103, 1.); (102, 1.)]`
  * `get_item (from_file "ok2.csv") 345` should raise `Not_found` (since the handle `345` is not in the database)

### 5. `Similar` module: `similarity` and `top_k` (20 points)

Once we've finished up the `rating` module we can fill in the two function definitions in `similar.ml`.  Note that these functions will need to call functions in the `rating` module.  If you want to test them against your implementations in utop, you'll need to compile `rating` on the command line with `ocamlc -c rating.mli rating.ml` and then load the module in utop with `#load "rating.cmo";;`.  (**DO NOT** put this in your `similar.ml` file.  `#` directives like `#use` and `#load` should not go in source files.)  The `hw2` folder on github also includes a file named `test.ml` that defines a nested module `Rating` that implements the interface in `rating.mli` but only for a fixed database (it cannot be used to correctly implement the functions above).  You can use this module to test your functions in utop with `#use "test.ml";;`.  The autograder will use similar modules to test your code for this section.

The two functions to be defined in `similar.ml` are:

+ `similarity : Rating.db -> Rating.ih -> Rating.ih -> float`: `similarty d i1 i2` should compute the cosine similarity between the items with handles `i1` and `i2` in database `d`, as defined [above](hw2.md#homework-2-rec).  One thing to keep in mind when trying to efficiently implement this function is that the typical item will only be rated by a very small fraction of the users in the database.  Here are some example evaluations using the `test.ml` rating module:
  * `similarity Rating.DB 1 2` should evaluate to `-0.408248290463862962`
  * `similarity Rating.DB 2 3` should evaluate to `0.577350269189625842`
  * `similarity Rating.DB 1 3` should evaluate to `0.`
  * `similarity Rating.DB 4 4` should evaluate to `0.999999999999999778`
  * `similarity Rating.DB 5 4` should evaluate to `0.707106781186547462`
(due to small differences in the order of operations, you might get slightly different results; the autograder will check that your results are with `0.0000001` of these results)

+ `top_k : Rating.db -> int -> Rating.ih -> (float * Rating.ih) list`: `top_k d k i` should compute the `k` items (excluding `i`) in the database most similar to `i` and return a list of (similarity, handle) pairs, in order of decreasing similarity. If `k` is greater than the number of items in `d`, the entire sorted list of items should be returned. So for example:
  * `top_k Rating.DB 0 1` should evaluate to `[]`
  * `top_k Rating.DB 3 1` should evaluate to `[(0., 5); (0., 3); (-0.408248290463862962, 2)]`
  * `top_k Rating.DB 2 4` should evaluate to `[(0.707106781186547462, 5); (0.408248290463862962, 2)]`
  * `top_k Rating.DB 5 3` should evaluate to `[(0.577350269189625842, 2); (0.353553390593273731, 4); (0., 5); (0., 1)]`

### 6. `print_out` (10 points)

Let's move on the the driver module, `rec.ml`.  This module is responsible for asking the user for inputs and printing results to the terminal.  It will also expect to have access to the `Rating` module and the `Similar` module, so if you want to test the functions in `utop`, you'll need to compile and load the rating module as described in the previous section, and similarly compile `similar.ml` in the terminal with `ocamlc -c rating.mli similar.ml` and load the module in utop with `#load "similar.cmo";;`  One more note: if you want to test out the individual functions in `rec.ml` by loading the file with `#use "rec.ml";;` you should comment out the final line in `rec.ml`.  You can also `#use "test.ml";;` module, which has a nested definition of the `Similar` module that is not correct but will return values you can use for testing.

For this problem, we'll fill in the stub implementation of `print_out : (float*Rating.ih) list -> Rating.db -> unit`.  `print_out` is responsible for printing the formatted results of `top_k` to the terminal in the format illustrated in the examples above.  As you can see from the examples given in the overview, `print_out` should first print a newline, follwed by a "header" line consisting of the string `"# \tscore \tname: description"` and a "ruler" line consisting of the string `"==\t======\t==================="`.  It should then print one line for each element of the input list, in the format shown above: the item's position in the list (starting from 1) followed by a `")\t"`, followed by the similarity formatted to fill 6 spaces, with 3 digits of precision, followed by a `'\t'` character, followed by the item name, `": "`, and the item description.

Some example outputs using the `test.ml` file:

* `print_out [(0.301,1); (0.219,2); (0.127,3)] Rating.DB` should return `()` and print the following to the standard output:
```
# 	score   name: description
==	======	===================
1)	 0.301	1: one
2)	 0.219	2: two
3)	 0.127	3: three
```

* `print_out [] Rating.DB` should return `()` and print the following to the standard output:
```
# 	score   name: description
==	======	===================
```

* `print_out [(0.1234,4);(0.3,2)] Rating.DB` should reurn `()` and print the following to the standard output:
```
# 	score   name: description
==	======	===================
1)	 0.123	4: four
2)	 0.300	2: two
```

### 7. Error handling: `get_db_file`, `get_search_handle`, `get_num_matches` (10 points)

Finally, the current implementations of `get_db_file`, `get_search_handle`, and `get_num_matches` in `rec.ml` do not gracefully deal with unexpected conditions.  Let's fix this:

+ Modify `get_db_file` so that if the filename the user provides either cannot be opened or has a formatting error, it prints out an explanation of this failure and gives the user the option to choose another file name or quit.  If the users chooses to quit the program, `get_db_file` should return `(exit 0)`, which will exit the program immediately.

+ Modify `get_search_handle` so that if the item name the user provides is not present in the database, the user is given the option to enter another name or quit.  

+ Modify `get_num_matches` so that if the user does not enter an integer, or the integer is not between 1 and 5, the user is asked to try again.  (You can test the behavior or `read_int ()` on a non-integer input in utop.)

There are no autograder test cases for this section; we'll grade them manually in gradescope.

## Other considerations

In addition to satisfying the functional specifications given above, your code
should be readable, with comments that explain what you're trying to accomplish.
It must compile with no errors using the command `ocamlopt -o rec rating.mli
rating.ml similar.ml rec.ml` and the unmodified `rating.mli` interface file.
Solutions that pay careful attention to resources like running time and stack
space (e.g. using tail recursion wherever feasible) and code reuse (e.g. using
`List` module higher-order functions) are worth more than solutions that do not
have these properties.


## Submission instructions and extension requests.

Once you are satisfied with the status of your submission in github, you can upload the files `rating.ml`, `similar.ml` and `rec.ml` to the "Homework 2" assignment on [Gradescope](https://www.gradescope.com/courses/342332/assignments/1826297).  We will run additional correctness testing to the basic feedback tests described here, and provide some manual feedback on the efficiency, readability, structure and comments of your code, which will be accessible in Gradescope once all submissions have been graded.

**Extension Requests**: Keep in mind that every student is allowed to request up to 6 24-hour deadline extensions for the four homeworks this semester, but no more than 4 may be used on any single homework.  To request an extension for this homework, please use [this form](https://forms.gle/3jEEg8bNgrD1U5h16) by the submission deadline on Friday, 3/18.
