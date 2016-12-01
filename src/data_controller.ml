module DataController = struct

  exception Annotation_Error
  exception No_Annotation
  exception Page_Undefined of string
  exception Book_Error of string

  (* [t] is a record containing important information about the book *)
  type t = {
            id : int ;
            book_text : string ;
            page_start : int ;
            page_end : int ;
            page_content : string ;
            page_annotations : Marginalia.t option
           }

  let debox_ann ann =
    match ann with
    | Some x -> x
    | None   -> raise No_Annotation
	
  (* Initialize Book Content 
  let init_book max_char shelf_id book_id =
    let book = Bookshelf.get_book_text shelf_id book_id in
    let book_length = String.length book in
    (*Differentiating b/w page end indices if the book is > 1 page, = 1
    page or is empty*)
    let page_end = if book_length = 0 then raise (Book_Error "Empty Book")
                   else if book_length < max_char then book_length - 1
                   else max_char - 1 in
    let new_content = String.sub book 0 (page_end + 1)  in
    let new_ann = Marginalia.get_page_overlay book_id (0, page_end) in
    { id = book_id ;
      book_text = book ;
      page_start = 0 ;
      page_end = page_end ;
      page_content = new_content ;
      page_annotations = Some new_ann } *)

  (* Highlight Data Control *)
  let add_highlights beg ending colour t1 =
    let absolute_start = t1.page_start + beg in
    let absolute_end = t1.page_start + ending in
    try
      if absolute_end < absolute_start then raise Annotation_Error
      else
        let new_ann = Marginalia.add_highlight
                      absolute_start absolute_end colour
                      (debox_ann t1.page_annotations) in
        {t1 with page_annotations = Some new_ann}
    with
      | Marginalia.Already_Exists -> raise Annotation_Error

  let delete_highlights beg t1 =
    let absolute_start = t1.page_start + beg in
    try
      let new_ann = Marginalia.delete_highlight
                    absolute_start (debox_ann t1.page_annotations) in
      {t1 with page_annotations = Some new_ann}
    with
      | Not_found -> raise Annotation_Error
  
  (*check how this affects sorted order*)
  let abs_to_rel_highlights lst =
    List.rev_map (fun (i, (c,e)) -> (i - t.page_start, (c, e - t.page_start))) lst
	  
  (*check how this affects sorted order*)
  let abs_to_rel_notes lst =
    List.rev_map (fun (i, r) -> (i - t.page_start, r)) lst
  
  (*needed to split all sorts into different functions because they return
  different types.*)
  let sort_notes_colour id range =
    let all_ann  = Perspective.create_range id range in
    let sorted_base = Perspective.note_by_colour all_ann in
	(*rather than giving page number, makes more sense to give some part
	of the text with it*)
	
  let sort_notes_loc id range =
    let all_ann  = Perspective.create_range id range in
    let sorted_base = Perspective.note_by_loc all_ann in 
	(*rather than giving the pag enumber, give the aspect of the book that its related to*)
	(*For each of these get a string related to it.
	Need a better strcuture to pass around things?*)

  let page_highlights t =
     abs_to_rel_highlights (Marginalia.highlights_list (debox_ann (t.page_annotations)))
	 
  (* Note Data Control *)
  let add_notes beg note colour t1 =
    let absolute_start = t1.page_start + beg in
    try
      let new_ann = Marginalia.add_note note
                    absolute_start colour (debox_ann t1.page_annotations) in
      {t1 with page_annotations = Some new_ann}
    with
      | Marginalia.Already_Exists -> raise Annotation_Error

  let delete_notes beg t1 =
    let absolute_start = t1.page_start + beg in
    try
      let new_ann = Marginalia.delete_note
                    absolute_start (debox_ann t1.page_annotations) in
      {t1 with page_annotations = Some new_ann}
    with
      | Not_found -> raise Annotation_Error
	  
  let page_notes t =
    abs_to_rel_notes (Marginalia.notes_list (debox_ann (t.page_annotations)))
	
  (* Bookmark Data Control *)
  let add_bookmarks t1 colour =
    try
      let new_ann = Marginalia.add_bookmark (debox_ann t1.page_annotations) colour in
      {t1 with page_annotations = Some new_ann}
    with
      | Marginalia.Already_Exists -> raise Annotation_Error

  let delete_bookmarks t1 =
    try
      let new_ann = Marginalia.remove_bookmark (debox_ann t1.page_annotations) in
      {t1 with page_annotations = Some new_ann}
    with
      | Not_found -> raise Annotation_Error
	  
  let page_bookmark t =
    Marginalia.is_bookmarked (debox_ann t.page_annotations)

  (* Page Content Control*)
  let next_page max_char t =
    (*Save all annotations on the current page*)
    Marginalia.save_page (debox_ann t.page_annotations) ;
    let book_length = String.length t.book_text in
    (*Ensure that the current page is not the last page*)
    let new_start = if t.page_end = (book_length - 1)
                      then raise (Page_Undefined "End of Book")
                    else t.page_end + 1 in
    let potential_end = new_start + max_char - 1 in
    (*Ensure that there is enough characters to print on this new page*)
    let new_end = if potential_end + 1 <= book_length then potential_end
                  else book_length - 1 in
    let new_contents = String.sub t.book_text new_start (new_end - new_start + 1) in
    let new_ann = Marginalia.get_page_overlay t.id (new_start, new_end) in
    { t with page_start = new_start ;
             page_end   = new_end ;
             page_content = new_contents ;
             page_annotations = Some new_ann }

  let prev_page max_char t =
    (*Save all annotations on the current page*)
    Marginalia.save_page (debox_ann t.page_annotations) ;
    let book_length = String.length t.book_text in
    (*Ensure that the current page is not the first page*)
    let new_end = if t.page_start = 0 then raise (Page_Undefined "Can't go back")
                  else t.page_start - 1 in
    let potential_start = new_end - max_char + 1 in
    let new_start = if potential_start < 0 then 0
                    else potential_start in
    let new_contents = String.sub t.book_text new_start (new_end - new_start + 1) in
    let new_ann = Marginalia.get_page_overlay t.id (new_start, new_end) in
    { t with page_start = new_start ;
             page_end   = new_end ;
             page_content = new_contents ;
             page_annotations = Some new_ann }

  (*let close_book t =
    Marginalia.save_page (debox_ann t.page_annotations) ;
    failwith "Unimplemented"
    (*Bookshelf close book gives the final position read but doesn't return
    it in anyway later*) *)

  let percent_read t =
    ((float_of_int t.page_start) /. (float_of_int (String.length t.book_text)))

  (*let return_definition word =
    try
      Bookshelf.get_definition word
    with
    | Word_Not_Found -> raise No_Annotation*)

(*
return current page string
all QA stuff
bookshelves list
books list in bookshelf
*)
end