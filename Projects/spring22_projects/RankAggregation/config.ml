(* read configuration files for the "vote" rank aggregation program *)

(* parse a vote aggregation formula.  A formula is either:
 * the rank r, 
 * the number of candidates n,
 * a floating-point constant x
 * the max or min of two terms, ie max Term Term
 * A term, of the form Factor or Factor * Term or Factor/Term
 * A sum, of the form Term or Term + Sum or Term - Sum
 * ( Formula )
 * The strategy used here to parse such expressions is called "Recursive Descent"
*)

exception ParseError of string*Genlex.token

let rec parse_exp tstream = 
    let term = parse_term tstream in
    try 
      begin match Stream.peek tstream with 
      | Some(Genlex.Kwd "+") -> (ignore(Stream.next tstream); (Rank.make_add term (parse_exp tstream)))
      | Some(Genlex.Kwd "-") -> (ignore(Stream.next tstream); (Rank.make_sub term (parse_exp tstream)))
      | _ -> term end
    with Stream.Failure -> term
and parse_term tstream = 
    let factor = parse_factor tstream in
    try 
      begin match Stream.peek tstream with
      | Some(Genlex.Kwd "*") -> (ignore(Stream.next tstream); (Rank.make_mul factor (parse_term tstream)))
      | Some(Genlex.Kwd "/") -> (ignore(Stream.next tstream); (Rank.make_div factor (parse_term tstream)))
      | _ -> factor end
    with Stream.Failure -> factor
and parse_factor tstream = 
    match Stream.next tstream with
    | Genlex.Kwd "(" -> begin 
      let nested = parse_exp tstream in match Stream.next tstream with Genlex.Kwd ")" -> nested | t -> raise (ParseError ("nest",t)) end
    | Genlex.Kwd "max" -> let n1 = parse_term tstream in let n2 = parse_term tstream in Rank.make_max n1 n2
    | Genlex.Kwd "min" -> let n1 = parse_term tstream in let n2 = parse_term tstream in Rank.make_min n1 n2
    | Genlex.Float f -> Rank.make_float f
    | Genlex.Int i -> Rank.make_float (float_of_int i)
    | Genlex.Kwd "r" -> Rank.make_rank ()
    | Genlex.Kwd "a" -> Rank.make_aggr ()
    | t -> raise (ParseError ("factor",t))

let parse_formula s = 
      let mylexer = Genlex.make_lexer ["*"; "/"; "+"; "("; ")"; "-"; "min"; "max"; "a"; "r"] in
      try parse_exp (mylexer (Stream.of_string s)) with _ -> failwith "formula parse error"

let parse_config_file fname = 
  let ic = open_in fname in
  let f = parse_formula (input_line ic) in
  let iv = float_of_string (input_line ic) in
  let candidates = String.split_on_char ',' (input_line ic) in
  let () = close_in ic in (f,iv,candidates)
