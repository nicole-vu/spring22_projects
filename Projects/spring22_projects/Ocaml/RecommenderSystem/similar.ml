(* Student: Nicole Vu - 5742307 *)

(* similarity returns the similarity score between items i1 and i2 using cosine similarity *)
let similarity db i1 i2 = 
    (* ls1, and ls2 are the lists of users rating for item i1 and i2 respectively *)
    let ls1 = List.map fst (Rating.get_item db i1) in
    let ls2 = List.map fst (Rating.get_item db i2) in
    (* short_list is the list of users that votes on both i1 and i2 *)
    let short_list = 
        let rec user_short_list ls1 = match ls1 with [] -> [] 
        | h::t -> if (List.mem h ls2) then h::(user_short_list t) else (user_short_list t) in
        user_short_list ls1 in 
    (* denominator is the denominator of the cosine similarity function, sqrt (len(ratings(i1)*len(ratings(i2))) *)
    let denominator = (sqrt(float_of_int (List.length (Rating.get_item db i1)) *. float_of_int (List.length (Rating.get_item db i2)))) in
    (* cosine similarity function *)
    List.fold_left (fun a u -> a +. ((Rating.get db i1 u)*.(Rating.get db i2 u)) /. denominator) 0. (short_list) 

(* top_k returns the k items that have is most similar to the item it *)
let top_k db k it = 
    let item_ls = Rating.get_items db in
    (* full_list is the sorted list of similarity score between the item it and every item in the database *)
    let full_list = List.sort (fun x y -> compare y x) (List.fold_left (fun a i -> ((similarity db i it),i)::a) [] (item_ls)) in
    (* taking the top k items from full_list *)
    let rec choose_k k ls c = match ls with [] -> c []
    | (sim,i)::t -> if (k<=0) then c []
                    else if (i=it) then (choose_k k t c)   
                    else (choose_k (k-1) t (fun r -> c ((sim,i)::r)))
    in choose_k k full_list (fun x -> x)