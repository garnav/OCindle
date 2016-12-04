module type Marginalia = sig

  open Colours
  type t
  type page = int * int
  val get_range : t -> int * int
  val get_page_overlay : int -> page -> t
  val add_note : int -> string -> Colours.t -> t -> t
  val delete_note : int -> t -> t
  val add_highlight : int -> int -> Colours.t -> t -> t
  val delete_highlight : int -> t -> t
  val is_bookmarked : t -> Colours.t option
  val add_bookmark : t -> Colours.t -> t
  val remove_bookmark : t -> t
  val notes_list : t -> (int * (Colours.t * string)) list
  val highlights_list : t -> (int * (Colours.t * int)) list
  val save_page : t -> unit

end

module Marginalia = struct
  
  exception Already_Exists
  exception Corrupted_Data
  		
  open List
  open Yojson
  open Yojson.Basic.Util
  open Colours
  		
  type notes_list = (int * (Colours.t *  string)) list
  
  type highlights_list = (int * (Colours.t * int)) list
  
  type page = int * int
		
  type t = {
    id : int ;
	page : page ;
	highlights : highlights_list ;
	notes : notes_list ;
	bookmark : (int * Colours.t) option ;
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
	
  let debox_marked m =
    match m with
	| Some x -> x
	| None  -> raise Not_found
  
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
	  let j_file = Basic.from_file (t.bookshelf ^ Filename.dir_sep ^ (string_of_int t.id) ^ "_" ^ (string_of_int base) ^ ".json") |> to_assoc in
	  t.file_json <- add_assoc t.file_json j_file;
	  if ending = base then collect_annotations j_file (b, e) f
	  else collect_annotations j_file (b, base_next - 1) f
	     @ collect_all (base_next, e) t f
	with
	| Sys_error _ -> if ending = base then []
	                 else collect_all (base_next, e) t f
	
	let check_bookmark t i =
	  try
	    let without_assoc = t.file_json |> to_assoc in
	    let within_index = List.assoc (string_of_int i) without_assoc |> to_assoc in
		let tag = List.assoc "bookmarks" within_index |> to_assoc in
		let actual_colour = List.assoc "colour" tag |> to_string |> colorify in
		Some (i, actual_colour)
	  with
	    | _ -> None
	
  (*also have to add the json stuff to the record*)
   let get_page_overlay book_id (b,e) =
     let init = { id = book_id ;
		          page = (b, e) ;
		          highlights = [] ;
		          notes = [] ;
		          bookmark = None ;
		          file_json = `Null }
				  in
     let new_h = collect_all (b, e) init single_highlight in
	 let new_n = collect_all (b, e) init single_note in
	 let page_bookmark = check_bookmark init ((b + e)/2) in (*init has had it's file_json changed by the prev. fun. calls*)
	 { init with highlights = new_h ; notes = new_n ; bookmark = page_bookmark }
  
  let json_add t1 is tag c ad_key ad =
  	let prepare = (tag, `Assoc [("colour", `String c); (ad_key, ad)]) in
    if t1.file_json = `Null then
	  	let addition = (is, `Assoc [prepare]) in
	    t1.file_json <- `Assoc [addition]
    else
      let without_assoc = t1.file_json |> to_assoc in
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

  let add_note i note c t1 =
    if not (mem_assoc i t1.notes) then
	  let () = json_add t1 (string_of_int i) "notes" (decolorify c) "note" (`String note) in
	  { t1 with notes = (i, (c, note))::t1.notes }
	else raise Already_Exists
  
  let rec existing_highlight s t lst =
    match lst with
	| (i,(_,e)) :: tail -> if (s >= i && s <= e) || (t >= i && t <= e) then true
	                       else existing_highlight s t tail
	| _                 -> false
	
  (*doesn't preserve order, just adds to the beginning of the list.*)
  let add_highlight i e c t1 =
    if not (mem_assoc i t1.highlights) && not (existing_highlight i e t1.highlights) then
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

  let is_bookmarked t1 =
    match t1.bookmark with
	| Some (i, c) -> Some c 
	| None        -> None

  (* In the context of changing content in books, due to changing font sizes, the term
  bookmark is loosely defined. We shall adhere to the conventional notion of a bookmark,
  ie: a way to mark the contents of a majority of a page. Assuming reasonable constraints
  on page and text sizes, the best way to ensure that content that is intended to be bookmarked
  is indeed always done so, is to ensure that a bookmark is placed in the center of a page.
  This is in contrast to having bookmarks closer to the end or beginning of a pages, which
  have higher chances of being pushed onto adjacent pages when font sizes change, thus,
  displacing the intended bookmark.
  
  Finally, this is best used when font sizes don't break 'normal' pages into several pages
  because adding bookmarks to each would eventually cause conflicts if the size was returned to normal.*)

  let json_add_bookmark t1 is c =
    let prepare = ("bookmarks", `Assoc [("colour", `String c)]) in
	if t1.file_json = `Null then
	  let addition = (is, `Assoc [prepare]) in
	  t1.file_json <- `Assoc [addition]
	else
     let without_assoc = t1.file_json |> to_assoc in
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

  (*can't add a bookmark if t1 is already bookmarked*)
  let add_bookmark t1 c =
    (*Condition prevents a bookmark from being added on any indices of the page, if
	it already exists on that page.*)
    if t1.bookmark <> None then raise Already_Exists
	else
	  let loc = ((fst t1.page) + (snd t1.page)) / 2 in
	  let colour = (decolorify c) in
	  let () = json_add_bookmark t1 (string_of_int loc) colour in
	  { t1 with bookmark = Some (loc, c) }
	  
  let remove_bookmark t1 =
    if t1.bookmark = None then raise Not_found
	else json_remove t1 (t1.bookmark |> debox_marked |> fst |> string_of_int) "bookmarks";
	{ t1 with bookmark = None }
	  
  let rec remove_all_files bookshelf_id id (b,e) =
    let base = b / 2000 in
	let ending = e / 2000 in
	let base_next = (base + 1) * 2000 in
	let file_name = bookshelf_id ^ Filename.dir_sep ^ (string_of_int id) ^ "_" ^ (string_of_int base) ^ ".json" in
	if base = ending then try Sys.remove file_name with Sys_error _ -> ()
	else try Sys.remove file_name ; remove_all_files id (base_next, e)
	     with Sys_error _ -> remove_all_files id (base_next, e)
  
  (*give it a sorted list? and copy, without assoc too.*)
  let save_to_file assoc_copy id (b, e) =
    let to_save = List.filter (fun (j, x) -> let k = int_of_string j in k >= b && k < e) assoc_copy in
	let base = b / 2000 in
	let file_name = bookshelf_id ^ Filename.dir_sep ^ (string_of_int id) ^ "_" ^ (string_of_int base) ^ ".json" in
	if to_save = [] then try Sys.remove file_name with Sys_error _ -> ()
	else Basic.to_file file_name (`Assoc to_save)
	
  let rec save_all bookshelf assoc_copy id (b,e) =
    let base = b / 2000 in
	let ending = e / 2000 in
	let base_next = (base + 1) * 2000 in
	if base = ending then save_to_file assoc_copy id (base * 2000, base_next)
	else (save_to_file assoc_copy id (base * 2000, base_next) ; save_all assoc_copy id (base_next, e))
  
  let save_page t1 =
    match t1.file_json with
	| `Null    -> remove_all_files t1.bookshelf t1.id t1.page
	| `Assoc x -> let copy = fold_left (fun acc x -> x::acc) [] (t1.file_json |> to_assoc) in
	              let sorted = List.sort (fun (i, _) (k, _) -> Pervasives.compare i k) copy in
				  save_all sorted t1.bookshelf t1.id t1.page
	| _        -> raise Corrupted_Data
				  
  let notes_list t1 = t1.notes
  
  let highlights_list t1 = t1.highlights
				  
end
