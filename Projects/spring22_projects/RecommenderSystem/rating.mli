(* a rating database *)
type db
(* "handles" for users and items *)
(* these just ensure that other modules need to go through our interface to get items/users *)
type ih
type uh

(* errors that can arise when reading a ratings file *)
exception LineFormatError
exception ItemError
exception RatingError

val from_file : string -> db
val iname_from_handle : db -> ih -> string
val handle_from_iname : db -> string -> ih option
val description_from_handle : db -> ih -> string

(* find the rating for a particular item by a user *)
val get : db -> ih -> uh -> float

(* the list of items in the db *)
val get_items : db -> ih list

(* the list of users in the db *)
val get_users : db -> uh list

(* get the list of user,rating pairs for an item *)
val get_item : db -> ih -> (uh*float) list
