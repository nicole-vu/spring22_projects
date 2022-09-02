(* Student: Nicole Vu - 5742307 *)

type ih = int
type uh = int

(* type db is a record with fields 
ih_ls: list of item handles 
ih_name_ls: associative list mapping between item handle and name
ih_desc_ls: associative list mapping between item handle and description
uh_ls: list of all users
rating_ls: associative list mapping user handle, item handle and rating
*)
type db = {
    ih_ls : ih list;
    ih_name_ls : (ih * string) list;
    ih_desc_ls : (ih * string) list;
    uh_ls : uh list;
    rating_ls : (uh * ih * float) list
}

exception LineFormatError
exception ItemError
exception RatingError

(* add_to_db is a helper function for from_file 
that checks the input line for LineFormatError, ItemError and Rating Error 
before adding to the database *)
let add_to_db db l = match (String.split_on_char ',' l) with 
    (* line l starts with i, followed by item handle, name and description *)
    | "i"::t1::t2::t3::[] -> (try (let ih = (int_of_string t1) in
                                (* check if two items have the same handle *)
                                if (List.mem ih db.ih_ls) then raise ItemError
                                (* check if two item names are the same *)
                                else if (List.mem t2 (List.map snd db.ih_name_ls)) then raise ItemError 
                                (* add to record if no error *)
                                else {ih_ls = ih::db.ih_ls; ih_name_ls = (ih,t2)::db.ih_name_ls; ih_desc_ls = (ih,t3)::db.ih_desc_ls;
                                        uh_ls = db.uh_ls; rating_ls = db.rating_ls}) 
                            (* check if the second field is an int *)
                            with Failure _ -> raise LineFormatError)  
    (* line l starts with r, followed by user handle, item handle and rating *) 
    | "r"::t1::t2::t3::[] -> (try (let uh = (int_of_string t1) in
                                let ih = (int_of_string t2) in
                                let r = (float_of_string t3) in
                                (* check if there is a rating for an item not in the database *)
                                if not (List.mem ih db.ih_ls) then raise RatingError
                                (* check if the rating is 1, 0 or -1 *)
                                else if ((r<>1.) && (r<>0.) && (r<> -1.)) then raise RatingError 
                                (* add to record if no error *)
                                else {ih_ls = db.ih_ls; ih_name_ls = db.ih_name_ls; ih_desc_ls = db.ih_desc_ls;
                                        uh_ls = uh::db.uh_ls; rating_ls = (uh,ih,r)::db.rating_ls}) 
                            (* check if second and third fields are int, fourth field is float *)
                            with Failure _ -> raise LineFormatError)
    (* raise exception if first arg is not "r" or "i", or if the number of args is not 4 *)
    | _ -> raise LineFormatError

(* from_file takes a file name, check for errors using a helper function and add valid lines to the database *)
let from_file f = 
    let ic = open_in f in
    let get_next_line () = try Some (input_line ic) with End_of_file -> None in
    let rec read_file_loop db = match get_next_line () with
    | None -> let () = close_in ic in db
    | Some l -> read_file_loop (add_to_db db l)
    in read_file_loop { ih_ls = []; ih_name_ls = []; ih_desc_ls = []; uh_ls = []; rating_ls = [] }

(* iname_from_handle returns the name matching with the item handle *)
let iname_from_handle d ih = 
    let rec nfh_helper ls i = match ls with [] -> raise Not_found
    | h::t -> if (fst h = i) then (snd h) else (nfh_helper t i) 
    in nfh_helper d.ih_name_ls ih

(* description_from_handle returns the descroption matching with the item handle *)
let description_from_handle d ih = 
    let rec dfh_helper ls i = match ls with [] -> raise Not_found
    | h::t -> if (fst h = i) then (snd h) else (dfh_helper t i) 
    in dfh_helper d.ih_desc_ls ih

(* handle_from_iname returns the item handle matching with the name *)
let handle_from_iname d name = 
    let rec hfn_helper ls i = match ls with [] -> None
    | h::t -> if (snd h = i) then Some (fst h) else (hfn_helper t i)
    in hfn_helper d.ih_name_ls name

(* get returns the rating for a particular item by a user *)
let get d i u = 
    let rec get_helper ls i u = match ls with [] -> 0.
    | (uh,ih,r)::t -> if ((uh = u) && (ih = i)) then r else (get_helper t i u)
    in get_helper d.rating_ls i u

(* get_items returns the list of items in the db *)
let get_items d = List.sort_uniq (-) d.ih_ls

(* get_users returns the list of users in the db *)
let get_users d = List.sort_uniq (-) d.uh_ls

(* get_item returns the list of user,rating pairs for an item *)
let get_item d i = 
    let rec get_i_helper ls i acc = match ls with [] -> acc
    | (uh,ih,r)::t -> (if (ih = i) then (get_i_helper t i ((uh,r)::acc)) else (get_i_helper t i acc))
    in match (get_i_helper d.rating_ls i []) with [] -> raise Not_found | ls -> ls
    
