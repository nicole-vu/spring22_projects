(* Student: Nicole Vu - 5742307 *)

(* rec.ml *)
(* read a rating database (.csv file) *)
(* and find the k "most similar" items *)

(* get_db_file takes in a file name and returns the database if the file can be opened *)
let get_db_file () =
  let () = print_string "Enter name of ratings file: " in
  let rec rfname () = let new_line = read_line () in match new_line with "quit" -> (exit 0)
  | nl -> match (try Some (Rating.from_file nl) with Sys_error _ -> None) with 
          | Some db -> db
          | None -> let () = print_string "File name cannot be opened. Enter another file name or (quit) to quit: " in rfname ()
  in rfname ()

(* gte_search_handle takes in a item name and returns the item handle if the item exists *)
let get_search_handle rdb =
  let () = print_string "Enter name of item to search for: " in
  let rec iname () = let new_line = read_line () in match new_line with "quit" -> (exit 0)
  | nl -> match Rating.handle_from_iname rdb (nl) with 
          | Some ih -> ih
          | None -> let () = print_string "Item name is not in the database. Enter another name or (quit) to quit: " in iname ()
  in iname ()

(* get_num_matches takes in number k between 1 to 5 and returns the top k items if k is correctly formatted *)
let get_num_matches () =
  let () = print_string "How many suggestions do you want? (1-5): " in 
  let rec next_int () = match (try Some (read_int ()) with Failure _ -> None) with
  | None -> let () = print_string "Input is not a valid number. Enter a number (1-5):" in next_int ()
  | Some i -> if ((i<1) || (i>5)) then (let () = print_string "Number is out of range. Enter another number (1-5): " in next_int ()) 
              else i 
  in next_int ()

let ask_again () =
  let () = print_string "Make another recommendation? (y/n): " in
  let ans = read_line () in (String.lowercase_ascii ans) = "y"

(* print_out prints the top k items similar to the input item to the console *)
let print_out topk rdb = 
  let () = print_newline () in 
  let () = print_string "# \tscore \tname: description\n" in
  let () = print_string "==\t======\t===================\n" in 
  let rec print_line topk c = match topk with [] -> ()
  | (sim,i)::t -> 
    let () = Printf.printf "%d)\t%6.3f\t%s: %s\n" c sim (Rating.iname_from_handle rdb i) (Rating.description_from_handle rdb i)
    in print_line t (c+1)
  in print_line topk 1  

let rec main_loop rdb =
  let ih = get_search_handle rdb in
  let k = get_num_matches () in
  let topk = Similar.top_k rdb k ih in
  let () = print_out topk rdb in
  if ask_again () then main_loop rdb else ()

let () = main_loop (get_db_file ())
