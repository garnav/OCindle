module DataController = struct
 
  open Bookshelf
 
  exception Annotation_Error
  exception No_Annotation
  exception Page_Undefined of string
  exception Book_Error of string
  
(**************************** TYPE DEFINITIONS ************************************)

  (* [t] containts important information about the book, including its id, bookhelf
  id and details of the current page. *)
  type t = {
            bookshelf : Bookshelf.bookshelf_id ;
            id : Bookshelf.book_id ;
            book_text : string ;
            page_start : int ;
            page_end : int ;
            page_content : string ;
            page_annotations : Marginalia.t option
           }
		   
(**************************** GENERAL HELPERS ************************************)

  let debox_ann ann =
    match ann with
    | Some x -> x
    | None   -> raise No_Annotation
	
  (*check how this affects sorted order*)
  let abs_to_rel_highlights lst t =
    List.rev_map (fun (i, (c,e)) -> (i - t.page_start, (c, e - t.page_start))) lst
	
  (*check how this affects sorted order*)
  let abs_to_rel_notes lst t =
    List.rev_map (fun (i, r) -> (i - t.page_start, r)) lst
	
(**************************** HIGHER ORDER ADD & DELETE ***********************)
	
  let general_add beg additional colour t1 f =
    try
	  let new_ann = f beg additional colour (debox_ann t1.page_annotations) in
       {t1 with page_annotations = Some new_ann}
    with
      | Marginalia.Already_Exists -> raise Annotation_Error
	  
  let general_delete index t1 f =
    try
	  let new_ann = f index (debox_ann t1.page_annotations) in
      {t1 with page_annotations = Some new_ann}
    with
      | Not_found -> raise Annotation_Error
	
(**************************** PAGE HIGHLIGHTS ************************************)

  let add_highlights beg ending colour t1 =
    let absolute_start = t1.page_start + beg in
    let absolute_end = t1.page_start + ending in
	if absolute_end < absolute_start then raise Annotation_Error
	else general_add absolute_start absolute_end colour t1 Marginalia.add_highlight

  let delete_highlights beg t1 =
    let absolute_start = t1.page_start + beg in
	general_delete absolute_start t1 Marginalia.delete_highlight

  let page_highlights t =
     abs_to_rel_highlights (Marginalia.highlights_list (debox_ann (t.page_annotations))) t
	 
(**************************** PAGE NOTES ********************************************)

  let add_notes beg note colour t1 =
    let absolute_start = t1.page_start + beg in
	general_add absolute_start note colour t1 Marginalia.add_note

  let delete_notes beg t1 =
    let absolute_start = t1.page_start + beg in
	general_delete absolute_start t1 Marginalia.delete_note
	  
  let page_notes t =
    abs_to_rel_notes (Marginalia.notes_list (debox_ann (t.page_annotations))) t
	
(**************************** PAGE BOOKMARK *****************************************)

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

(**************************** PAGE CONTENT CONTROL ***********************************)

  let create_page_info start ending text shelf_id book_id =
    let new_contents = String.sub text start (ending - start + 1) in
    let new_ann = Marginalia.get_page_overlay book_id (start, ending) in
    { bookshelf = shelf_id ;
	  id = book_id ;
	  book_text = text ;
	  page_start = start ;
      page_end   = ending ;
      page_content = new_contents ;
      page_annotations = Some new_ann }
  
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
	create_page_info new_start new_end t.book_text t.bookshelf t.id

  let prev_page max_char t =
    (*Save all annotations on the current page*)
    Marginalia.save_page (debox_ann t.page_annotations) ;
    (*Ensure that the current page is not the first page*)
    let new_end = if t.page_start = 0 then raise (Page_Undefined "Can't go back")
                  else t.page_start - 1 in
    let potential_start = new_end - max_char + 1 in
    let new_start = if potential_start < 0 then 0
                    else potential_start in
	create_page_info new_start new_end t.book_text t.bookshelf t.id
	
  let page_number t max_char = t.page_end / max_char
  
  let percent_read t =
    (/.) (float_of_int t.page_end) (float_of_int ((String.length t.book_text) - 1))
	  
  (*returns [t] for the page that contains index. Index may not necessarily be the beginning
  of the page. Is an existing t being kept track of.*)
  let get_page index max_char shelf_id book_id =
    (*division by max_char returns the highest multiple of max_char lower than index
	and thus, the 'page number' of the book.*)
    let page_start = (index / max_char) * max_char in
	let book = get_book_text shelf_id book_id in
	let book_length = String.length book in
	let page_end = if page_start + max_char > book_length then book_length - 1
	               else page_start + max_char - 1 in
	create_page_info page_start page_end book shelf_id book_id
	    
  let return_definition word =
    try
      Dictionary.get_definition word
    with
    | Word_Not_Found -> raise No_Annotation
	
(**************************** META BOOK DATA *****************************************)

  let meta_annotations t = Perspective.create_range t.id (0, String.length t.book_text)
	
  (*what if the highlight goes beyond the bounds of the book*)	
  let highlight_surroundings i e t1 = String.sub t1.book_text i (e - i + 1)
  
  let note_surroundings i max_num t1 =
    let book_length = String.length t1.book_text in
	(*be able to provide a general view of the noted string, with a roughly equal amount on both sides of
	the note.*)
	if i + (max_num/2) > book_length then
	  let end_i = book_length - i in
      let prev_i = max_num - end_i in
	 (String.sub t1.book_text (i - prev_i) prev_i) ^ (String.sub t1.book_text (i + 1) (end_i))
    else if i - (max_num/2) < 0 then 
	  let beg_length = i + 1 in
	  (String.sub t1.book_text 0 beg_length) ^ (String.sub t1.book_text beg_length (max_num - beg_length))
	else (String.sub t1.book_text (i - (max_num/2) + 1) (max_num/2)) ^ (String.sub t1.book_text i (max_num/2))
  
  (*the first List.map is O(1) because we only have 7 elements in that list at a maximum.*)
  let sort_highlights_colour t1 all_ann =
    let retrieved_lst = Perspective.highlight_by_colour all_ann in
	let internal_function = (fun (s,e) -> (s, highlight_surroundings s e t1)) in
	List.map (fun (c,lst) -> (c, List.map internal_function lst)) retrieved_lst
			 
  let sort_notes_colour t1 all_ann max_num =
    let retrieved_lst = Perspective.note_by_colour all_ann in
	let checking_function = (fun (i, s) -> (i, s, note_surroundings i max_num t1)) in
	List.map (fun (c,lst) -> (c,List.map checking_function lst)) retrieved_lst	
	
  let search term all_ann = Perspective.search_notes all_ann term
  
(**************************** BOOKSHELF & BOOKS *****************************************)

  let bookshelf_list () =
    let bs_lst = list_bookshelves in
	List.map (fun x -> (x, get_bookshelf_name x)) bs_lst
   
  let book_list shelf_id =
    let returned_lst = list_books shelf_id in
	List.map (fun x -> (get_book_id x, get_title x)) returned_lst
	
  let init_book max_char shelf_id book_id =
    let book = Bookshelf.get_book_text shelf_id book_id in
    let book_length = String.length book in
	(*get the beginning of the page in which the saved position belongs*)
	let curr_pos = ((get_current_position (get_book_data shelf_id book_id)) / max_char) * max_char in
	let (actual_start, actual_end) =
	  (*empty book*)
	  if book_length = 0 then raise (Book_Error "Empty Book")
	  (*single page book. If this is the case then curr_poss must also be
	  0 to ensure the entire page is displayed*)
	  else if max_char > book_length then (0, book_length - 1)
	  (*last page of book*)
	  else if curr_pos + max_char > book_length then (curr_pos, book_length - 1)
	  (*anywhere else in a book*)
	  else (curr_pos, curr_pos + max_char - 1) in 
    let new_content = String.sub book actual_start (actual_end + 1)  in
    let new_ann = Marginalia.get_page_overlay book_id (actual_start, actual_end) in
    { bookshelf = shelf_id ;
	  id = book_id ;
      book_text = book ;
      page_start = actual_start ;
      page_end = actual_end ;
      page_content = new_content ;
      page_annotations = Some new_ann }
	
  (*saves the absolute index of the current page as the reading position*)	
  let close_book t =
    Marginalia.save_page (debox_ann t.page_annotations) ;
	save_book_position t.bookshelf t.id t.page_start
	
end