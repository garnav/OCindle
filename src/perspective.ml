module Perspective = struct
  
  open Colours
  open Marginalia
  open List
  open Str

  type t = Marginalia.t
  
  let sorting lst =
    List.sort (fun (i, _) (j,_) -> Pervasives.compare i j) lst
  
  let rec insert_colour prev lst (c, (i, j)) =
    match lst with
	| (co, t) :: ta -> if co = c then (co, (i,j) :: t) :: ta @ prev
	                   else insert_colour ((co, t) :: prev) ta (c, (i, j))
	| _             -> raise Not_found 
  
  let rec sort_colour main_lst acc =
    match main_lst with
	| (i, (c, j))::t -> if mem_assoc c acc
	                      then sort_colour t (insert_colour [] acc (c, (i, j)))
	                    else sort_colour t ((c, [(i, j)]) :: acc)
	| _              -> acc
  
  let general_colour_sort n_or_h =
    let sorted = sort_colour n_or_h [] in
	let inner_sorted = rev_map (fun (c, t) -> (c, sorting t)) sorted in
	List.sort (fun (i, _) (j,_) -> Colours.compare_colours i j) inner_sorted

  let create_range shelf_id id page = get_page_overlay shelf_id id page

  let note_by_colour t1 = general_colour_sort (notes_list t1)

  let highlight_by_colour t1 = general_colour_sort (highlights_list t1)
    
  let note_by_loc t1 = sorting (notes_list t1)

  let highlight_by_loc t1 = sorting (highlights_list t1)
  
  let rec search_through_lst custom_reg lst =
    match lst with
	| h :: t -> (try ignore (search_forward custom_reg (String.lowercase_ascii h) 0) ; true
				with _ -> search_through_lst custom_reg t)
	| _      -> false
  
  let search_in_string to_check check_in =
    let r_words = regexp "\\([ \t\n\r]+\\)" in
	let custom_reg = regexp_string to_check in
    let lst_of_words = Str.split r_words check_in in
	search_through_lst custom_reg lst_of_words
	
  let search_notes t1 note =
    fold_left (fun acc (i, (c, s)) -> if search_in_string (String.lowercase_ascii note) s
	                                    then (i, (c, s)) :: acc
									  else acc) [] (notes_list t1)

end