(* Nicole Vu - vu000166 *)

(* a data type representing expressions *)
(* Adapted from lab3 - arithExpr.ml *)
type formula = ConstExpr of float | SubExpr of formula * formula | AddExpr of formula * formula | MultExpr of formula * formula 
| DivExpr of formula * formula | MaxExpr of formula * formula | MinExpr of formula * formula | Rank | Agg

let make_add f1 f2 = AddExpr (f1,f2) 
let make_sub f1 f2 = SubExpr (f1,f2)  
let make_mul f1 f2 = MultExpr (f1,f2) 
let make_div f1 f2 = DivExpr (f1,f2)
let make_max f1 f2 = MaxExpr (f1,f2) 
let make_min f1 f2 = MinExpr (f1,f2) 
let make_float (f:float) = ConstExpr f
let make_rank () = Rank
let make_aggr () = Agg


(* compute function do computation accordingly to the type of expression *)
let rec compute (f : formula) (rank : float) (agg : float) = match f with 
| Rank -> rank
| Agg -> agg
| ConstExpr f -> f
(* AddExpr, SubExpr, MultExpr, DivExpr, MaxExpr, Min Expr are recursive expressions, do arithmatic computation on the results of arguments *)
| AddExpr (f1,f2) -> ((compute f1 rank agg) +. (compute f2 rank agg))
| SubExpr (f1,f2) -> ((compute f1 rank agg) -. (compute f2 rank agg))
| MultExpr (f1,f2) -> ((compute f1 rank agg) *. (compute f2 rank agg))
| DivExpr (f1,f2) -> ((compute f1 rank agg) /. (compute f2 rank agg))
| MaxExpr (f1,f2) -> (max (compute f1 rank agg) (compute f2 rank agg))
| MinExpr (f1,f2) -> (min (compute f1 rank agg) (compute f2 rank agg))


(* rank function return the rank of c in list ls, if c not in ls, return default value *)
let rank (c : 'a) (default : float) (ls : 'a list) = 
  (* index i will be return as rank if c is in ls *)
  let rec rank_helper c d ls i = match ls with [] -> d
  | (h::t) -> if (c = h) then (float_of_int i)
              else rank_helper c d t (i+1)
  in rank_helper c default ls 1 


(* score function calculates the total score of c based on the list of ballot "ballots" *) 
let rec score (c : 'a) (agg : float) (f : formula) (n : float) (ballots : 'a list list) = 
  (* if the ballot list is empty, return the aggregation *)
  match ballots with [] -> agg
  | h::t -> score c (compute f (rank c n h) agg) f n t  
     
  
(* score_all funtion returns the list of all c in cs list and their scores 
    use continuation function k in score_all_helper to maintain tail recursion
*)
let score_all (cs : 'a list) (init : float) (f : formula) (ballots : 'a list list) : ('a * float) list = 
  (* n is the list of cs list, will be used as default in score funtion *)
  let n = float_of_int (List.length cs) in 

    let rec score_all_helper cs init f ballots n k = 
      match cs with [] -> k []
      (* go through the list of c in cs, calculate the score of c and cons to the list of results *)
      | c::cst -> score_all_helper cst init f ballots n (fun r -> k ((c,score c init f n ballots)::r))

    in score_all_helper cs init f ballots n (fun x -> x)
