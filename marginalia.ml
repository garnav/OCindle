module Marginalia = struct
  
  exception Already_Exists		
  		
  open List
  open Yojson
  open Colours
  		
  type notes_list = (int * (Colours.t *  string)) list
  type highlights_list = (int * (Colours.t * int)) list
  type page = int * int
  		
  type t = {
    book_id : int;
	page : page;
	highlights : highlights_list;
	notes : notes_list;
	bookmark : bool(*what if there are two bookmarks of contrasting colours*)
	(*Design choices: why are these made before they are actually needed,
	because it's intended use is for actually making sure all of this stuff
	is shown on a page, so it makes to have it there and pre-processed.
	Also when new notes and highlights are created, then we just want to
	add it to the existing lists instead of adding it to the JSon structure
	and having to create the list all over again.*)
	file_json : Yojson.json;
  }
  
  let rec delete_helper lst i =
    List.filter (fun (j,x) -> i <> j) lst

  let get_range t1 = t1.page
  
  (*e must be greater than or equal to b. collects highlights in a one json*) 
  let rec collect_highlights j_entire (b,e) = 
    try
	  if e < b then []
	  else single_index_highlight (List.assoc (string_of_int e) j_entire |> to_assoc)
	       :: collect_highlights j_entire (b, e - 1)
	with
	  | _ -> collect_highlights j_entire (b, e - 1)
   
  let single_index_highlight j_index =
    let single = List.Assoc "highlight" j_index |> to_assoc in
	(List.assoc "colour" single |> to_string |> colorify, List.assoc "end" single |> to_int)
  
  
  let rec collect_all_highlights book_id (b, e) =
    let base = b / 2000 in
	let ending = e / 2000 in
	let j_file = Basic.from_file
	           (string_of_int book_id) ^ "_" ^ (string_of_int base) ^ ".json" in
	if ending = base
	  then collect_highlights (j_file |> to_assoc) (b, e)
    else
	  let new_end = ((base + 1) *2000) - 1 in 
	  collect_highlights (j_file |> to_assoc) (b, new_end) :: collect_all book_id ((base + 1) *2000, e)
  
  	
  (*let get_page_overlay book_id (b,e) t1 =
    try 
    let base = (fst range) / 2000 in
	let j_file = Basic.from_file
	             (string_of_int book_id) ^ "_" ^ (string_of_int base) ^ ".json" in
	with
	  | Sys_error "test_schjson: No such file or directory" -> *)
	  (*no file, should it create it here, why waste mems? BUT what if part of it doesn't exist*)
	  
	
	
	(*also what if the book id or the index doesn't exist.*)
	(*assuming its in the same file right now, have to tackle differences next.
	Also note that in that case, have to carefully think about where to stop looking in that file*)
	

  let add_note note i c t1 =
    if not (mem_assoc i t1.notes)
	  then { t1 with notes = (i, (decolorify c, note))::t1.notes }
	else raise Already_Exists
  
  let delete i t1 t_aspect tag =
    if mem_assoc i t_aspect
	  then match tag with
	       | `Notes      -> { t1 with notes = delete_helper t1.aspect i }
		   | `Highlights -> { t1 with highlights = delete_helper t1.aspect i }
	else raise Not_found
	(*have to delete from json structure as well.*)
  
  let delete_note i t1 =
    delete i t1 t1.notes `Notes
    (*if mem_assoc i t1.notes
	  then { t1 with notes = delete_helper t1.notes i }
	else raise Not_found *)

  (*doesn't preserve order, just adds to the beginning of the list.*)
  let add_highlight i e c t1 =
    if not (mem_assoc i t1.highlights)
	  then { t1 with highlights = (i, (decolorify c, e))::t1.highlights }
	else raise Already_Exists
	(*also have to add to JSON structure, note that it could also be empty*)
 
  (*didn't use List.remove_assoc cause it's not tail recursive.
  Can't use a higher order function because how would you refer to high*)
  let delete_highlight i t1 =
    delete i t1 t1.highlights `Highlights
    (*if mem_assoc i t1.highlights
	  then { t1 with highlights = delete_helper t1.highlights i }
	else raise Not_found *)

  let is_bookmarked t1 =
    failwith "Unimplemented"

  let add_bookmark t1 c1 =
    failwith "Unimplemented"
  
  let remove_bookmark t1 =
    failwith "Unimplemented"
	
  let save_page t1 =
    failwith "Unimplemented"
	(*should take care of creating a new file, if it doesn't already exist?*)

end
(*
1. decide on how to store after reading file
2. how to manipulate that data to create what we need
3. how to add that data to the json structure and put it back
into the file.
4. how to bookmark

*)


(*TWO Options:
- everytime something is added, add it to the JSON file
OR once a new page is asked for, just rewrite everything all together.
*)
