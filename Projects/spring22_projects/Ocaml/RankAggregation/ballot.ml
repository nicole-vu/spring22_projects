(* Nicole Vu - vu000166*)

(* free code: don't worry, you aren't meant to understand this function yet. *)
let get_ballot_lines bfile = 
  let ic = open_in bfile in
  let rec get_bl acc = 
    match (try Some (input_line ic) with End_of_file -> None) with
    None -> List.rev acc
    | Some l -> get_bl (l::acc) in
  let ballot_lines = get_bl [] in
  let () = close_in ic in ballot_lines

(* Given a list of comma-delimited "ballots" return a list of lists where each
   element is the list of comma-delimited options.  
   Using a helper function with continuation for tail recursion
 *)
let ballots_from_lines (blines : string list) : string list list = 
  let rec b_helper blines k : string list list = match blines with [] -> k []
  | s::t -> if s = "" then b_helper t (fun r -> k ([]::r)) 
            else b_helper t (fun r -> k ((String.split_on_char ',' s)::r))
  in b_helper blines (fun x -> x)

  
(* Identify the index of the first ballot that has a candidate not in the candidate list *)
(* Return None if all ballots are legal. *)
  let first_error (cs : 'a list) (ballots : 'a list list) : int option =
    let rec check cs ballots count : int option = match (cs, ballots, count) with
    | ([],_,_) | (_,[[]],_) | (_,[],_) -> None
    (*if the candidate doesn't match any in the candidate list, return the number of errors *)
    | (c, h::t, count) when (c <> h) && (h <> []) -> Some count
    | (c, h::t, count) -> check c t (count+1)
  in check cs ballots 1 


(* Given a list of (candidate,score) pairs, compute the String length of the longest candidate *)
let max_len (sl : (string * float) list) = 
  let rec max_len_helper sl m = match sl with [] -> m
  | (s,f)::t -> if (String.length s > m) then (max_len_helper t (String.length s))
                else max_len_helper t m
  in max_len_helper sl 0 


(* Pad the string s (with spaces) to length at least l *)
let rec pad (l : int) s = 
  if l <= 0 then s
  else if l <= (String.length s) then pad (l-1) s
  else pad (l-1) s ^ " "


(* free code: prints the list of rankings out *)
let print_rankings sl = 
  let padlen = max (String.length "Candidate") (max_len sl) in
  let () = print_endline ((pad padlen "Candidate") ^ " \t Score") in
  let () = print_endline ((String.make padlen '-') ^ " \t -----") in
  let rec p_loop = function [] -> () 
  | (c,s)::t -> let () = print_endline ((pad padlen c) ^ " \t " ^ (string_of_float s)) in p_loop t
in p_loop sl
