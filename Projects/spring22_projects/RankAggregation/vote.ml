(* vote.ml -- a rank aggregation application *)

let cmdline = Array.to_list Sys.argv
let _::cfile::bfile::[] = if (List.length cmdline) <> 3 then exit 1 else cmdline
let (f,iv,candidates) = Config.parse_config_file cfile
let blines = Ballot.get_ballot_lines bfile
let ballots = Ballot.ballots_from_lines blines
let () = match (Ballot.first_error candidates ballots) with None -> ()
         | Some i -> let () = print_endline ("Line " ^ (string_of_int i) ^ " ranks unknown candidate") in (exit 2)
let cscores = Rank.score_all candidates iv f ballots
let sorted = List.sort (fun (a1,a2) (b1,b2) -> compare (a2,a1) (b2,b1)) cscores
let () = Ballot.print_rankings sorted
