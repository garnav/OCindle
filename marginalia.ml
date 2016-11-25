module Marginalia = struct
  
  exception Already_Exists		
  		
  open List
  open Yojson
  open Yojson.Basic.Util
  open Colours
  		
  type notes_list = (int * (Colours.t *  string)) list
  type highlights_list = (int * (Colours.t * int)) list
  type page = int * int
  		
  type t = {
    id : int;
	page : page;
	highlights : highlights_list;
	notes : notes_list;
	bookmark : bool;(*what if there are two bookmarks of contrasting colours*)
	(*Design choices: why are these made before they are actually needed,
	because it's intended use is for actually making sure all of this stuff
	is shown on a page, so it makes to have it there and pre-processed.
	Also when new notes and highlights are created, then we just want to
	add it to the existing lists instead of adding it to the JSon structure
	and having to create the list all over again.*)
	mutable file_json : Yojson.json
  }
  
  let rec delete_helper lst i =
    List.filter (fun (j,x) -> i <> j) lst

  let get_range t1 = t1.page
  
  let single_index_note j_index =
    try
	  let single = List.assoc "notes" j_index |> to_assoc in
	  Some (List.assoc "colour" single |> to_string |> colorify, List.assoc "note" single |> to_string)
	with
	| _ -> None
  
  let single_index_highlight j_index =
    try 
      let single = List.assoc "highlight" j_index |> to_assoc in
	  Some (List.assoc "colour" single |> to_string |> colorify, List.assoc "end" single |> to_int)
	with
	| _ -> None
	
  let debox_lst e lst=
    match lst with
    | Some x -> [(e, x)]
	| None   -> []
  
  (*e must be greater than or equal to b. collects highlights in a one json. optimized so that notes and highlights
  are collected together, insteaad of having to over the structure twice?*) 
  let rec collect_annotations j_entire (b,e) f =
    let index = string_of_int e in
    if e < b then []
	else if mem_assoc index j_entire then debox_lst e (List.assoc index j_entire |> to_assoc |> f)
	                                      @ collect_annotations j_entire (b, e - 1) f
	else collect_annotations j_entire (b, e - 1) f
	  
  let rec collect_all (b, e) t f =
    let base = b / 2000 in
	let base_next = (base + 1) * 2000 in
	let ending = e / 2000 in
	try
	  let j_file = Basic.from_file ((string_of_int t.id) ^ "_" ^ (string_of_int base) ^ ".json") |> to_assoc in
	  if ending = base then collect_annotations j_file (b, e) f
	  else collect_annotations j_file (b, (base_next - 1)) f
	     @ collect_all (base_next, e) t f
	with
	| Sys_error _ -> if ending = base then []
	                 else collect_all ((base + 1) *2000, e) t f
	
  (*also have to add the json stuff to the record*)
   let get_page_overlay book_id (b,e) =
     let init = {
		id = book_id ;
		page = (b, e) ;
		highlights = [] ;
		notes = [] ;
		bookmark = false ;
		file_json = `Null } in
     let new_highlights = collect_all (b, e) init single_index_highlight in
	 let new_notes = collect_all (b, e) init single_index_note in
	 { init with highlights = new_highlights ; notes = new_notes}

  let add_note note i c t1 =
    if not (mem_assoc i t1.notes)
	  then { t1 with notes = (i, (c, note))::t1.notes }
	else raise Already_Exists
  
 (* let delete i t1 t_aspect tag =
    if mem_assoc i t_aspect
	  then match tag with
	       | `Notes      -> { t1 with notes = delete_helper t_aspect i }
		   | `Highlights -> { t1 with highlights = delete_helper t_aspect i }
	else raise Not_found
	have to delete from json structure as well.*)
  
  let delete_note i t1 =
    (*delete i t1 t1.notes `Notes *)
    if mem_assoc i t1.notes
	  then { t1 with notes = delete_helper t1.notes i }
	else raise Not_found 

  (*doesn't preserve order, just adds to the beginning of the list.*)
  let add_highlight i e c t1 =
    if not (mem_assoc i t1.highlights)
	  then { t1 with highlights = (i, (c, e))::t1.highlights }
	else raise Already_Exists
	(*also have to add to JSON structure, note that it could also be empty*)
 
  (*didn't use List.remove_assoc cause it's not tail recursive.
  Can't use a higher order function because how would you refer to high*)
  let delete_highlight i t1 =
    (*delete i t1 t1.highlights `Highlights *)
    if mem_assoc i t1.highlights
	  then { t1 with highlights = delete_helper t1.highlights i }
	else raise Not_found
	(*also have to delete from JSON structure*)

  let is_bookmarked t1 =
    failwith "Unimplemented"

  let add_bookmark t1 c1 =
    failwith "Unimplemented"
  
  let remove_bookmark t1 =
    failwith "Unimplemented"
	
  let save_page t1 =
    failwith "Unimplemented"
	(*should take care of creating a new file, if it doesn't already exist?*)
	(*but only create if there are actually eny highlights to add?*)
		(*also what if the book id or the index doesn't exist.*)

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
