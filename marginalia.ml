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
	bookmark : bool; (*what if there are two bookmarks of contrasting colours*)
	mutable file_json : Yojson.Basic.json
  }
  
  (*if the file_json is empty, then add whats there,
  what if add is empty. prevent duplicates.*)
  let add_assoc existing add =
    match (existing, add) with
	| (`Assoc a, _) -> `Assoc ((List.filter (fun (j,x) -> not (mem_assoc j a)) add) @ a)
	| (`Null, [])   -> `Null
	| (`Null, _ )   -> `Assoc add
	| _             -> `Null
  
  let rec delete_helper lst i =
    List.filter (fun (j,x) -> i <> j) lst

  let get_range t1 = t1.page
  
  let single_note j_index =
    try
	  let single = List.assoc "notes" j_index |> to_assoc in
	  Some (List.assoc "colour" single |> to_string |> colorify, List.assoc "note" single |> to_string)
	with
	| _ -> None
  
  let single_highlight j_index =
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
	else if mem_assoc index j_entire then (List.assoc index j_entire |> to_assoc |> f |> debox_lst e)
	                                      @ collect_annotations j_entire (b, e - 1) f
	else collect_annotations j_entire (b, e - 1) f
	  
  let rec collect_all (b, e) t f =
    let base = b / 2000 in
	let base_next = (base + 1) * 2000 in
	let ending = e / 2000 in
	try
	  let j_file = Basic.from_file ((string_of_int t.id) ^ "_" ^ (string_of_int base) ^ ".json") |> to_assoc in
	  t.file_json <- add_assoc t.file_json j_file;
	  if ending = base then collect_annotations j_file (b, e) f
	  else collect_annotations j_file (b, base_next - 1) f
	     @ collect_all (base_next, e) t f
	with
	| Sys_error _ -> if ending = base then []
	                 else collect_all (base_next, e) t f
	
  (*also have to add the json stuff to the record*)
   let get_page_overlay book_id (b,e) =
     let init = { id = book_id ;
		          page = (b, e) ;
		          highlights = [] ;
		          notes = [] ;
		          bookmark = false ;
		          file_json = `Null }
				  in
     let new_h = collect_all (b, e) init single_highlight in
	 let new_n = collect_all (b, e) init single_note in
	 { init with highlights = new_h ; notes = new_n }
	 (*sort?*)

  let json_add t1 is tag c ad_key ad =
    let without_assoc = t1.file_json |> to_assoc in
	let prepare = (tag, `Assoc [("colour", `String c); (ad_key, ad)]) in
	if mem_assoc is without_assoc then
	  let to_alter = assoc is without_assoc |> to_assoc in
	  let altered = `Assoc (prepare :: to_alter) in
	  let removed = delete_helper without_assoc is in
	  let changed = `Assoc ((is, altered) :: removed) in
	  t1.file_json <- changed
	else
	  let addition = (is, `Assoc [prepare]) in
	  let final = `Assoc (addition :: without_assoc) in
	  t1.file_json <- final

  let add_note note i c t1 =
    if not (mem_assoc i t1.notes) then
	  let () = json_add t1 (string_of_int i) "notes" (decolorify c) "note" (`String note) in
	  { t1 with notes = (i, (c, note))::t1.notes }
	else raise Already_Exists
	
  (*doesn't preserve order, just adds to the beginning of the list.*)
  let add_highlight i e c t1 =
    if not (mem_assoc i t1.highlights) then
	  let () = json_add t1 (string_of_int i) "highlight" (decolorify c) "end" (`Int e) in
	  { t1 with highlights = (i, (c, e))::t1.highlights }
	else raise Already_Exists
	(*also have to add to JSON structure, note that it could also be empty*)

  (*assumes that its actually there*)	
  let json_remove t1 is tag =
    let without_assoc = t1.file_json |> to_assoc in
	let to_change = List.assoc is without_assoc |> to_assoc in
	let changed = delete_helper to_change tag in
	let r_assoc = List.remove_assoc is without_assoc in
	let finalized =
	  match (r_assoc, changed) with
	  | ([], []) -> `Null
	  | (_, [])  -> `Assoc r_assoc
	  | ([], _)  -> `Assoc [(is, `Assoc changed)]
	  | (_, _)   -> `Assoc ([(is, `Assoc changed)] @ r_assoc)
	  in
	t1.file_json <- finalized
  
  (*didn't use List.remove_assoc cause it's not tail recursive.h*)
  let delete i t1 t_aspect tag =
    if mem_assoc i t_aspect then
	  match tag with
	  | `Notes      -> json_remove t1 (string_of_int i) "notes" ;
	                   { t1 with notes = delete_helper t1.notes i }
	  | `Highlights -> json_remove t1 (string_of_int i) "highlight" ;
	                   { t1 with highlights = delete_helper t1.highlights i }
	else raise Not_found
  
  let delete_note i t1 = delete i t1 t1.notes `Notes
	
  let delete_highlight i t1 = delete i t1 t1.highlights `Highlights

  let is_bookmarked t1 = t1.bookmark

  let add_bookmark t1 c1 =
    failwith "Unimplemented"
  
  let remove_bookmark t1 =
    failwith "Unimplemented"

  let rec remove_all_files id (b,e) =
    let base = b / 2000 in
	let ending = e / 2000 in
	let base_next = (base + 1) * 2000 in
	let file_name = (string_of_int id) ^ "_" ^ (string_of_int base) ^ ".json" in
	if base = ending then try Sys.remove file_name with Sys_error _ -> ()
	else try Sys.remove file_name ; remove_all_files id (base_next, e)
	     with Sys_error _ -> remove_all_files id (base_next, e)
  
  (*give it a sorted list? and copy, without assoc too.*)
  let save_to_file assoc_copy id (b, e) =
    let to_save = List.filter (fun (j, x) -> let k = int_of_string j in k >= b && k < e) assoc_copy in
	let base = b / 2000 in
	let file_name = (string_of_int id) ^ "_" ^ (string_of_int base) ^ ".json" in
	if to_save = [] then try Sys.remove file_name with Sys_error _ -> ()
	else Basic.to_file file_name (`Assoc to_save)
	
  let rec save_all assoc_copy id (b,e) =
    let base = b / 2000 in
	let ending = e / 2000 in
	let base_next = (base + 1) * 2000 in
	if base = ending then save_to_file assoc_copy id (b, e)
	else save_to_file assoc_copy t1.id (b, e) ; save_all assoc_copy id (base_next, e)
	
  let save_page t1 =
    match t1.file_json with
	| `Null    -> remove_all_files t1.id t1.page
	| `Assoc x -> let copy = fold_left (fun acc x -> x::acc) [] (t1.file_json |> to_assoc) in
	              let sorted = List.sort (fun (i, _) (k, _) -> Pervasives.compare i k) copy in
				  save_all sorted t1.id (b,e)
	
	(*also what if the book id or the index doesn't exist. *)

end
(*
4. how to bookmark
*)

