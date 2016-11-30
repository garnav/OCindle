module DataController = struct

  exception Annotation_Error
  exception No_Annotation

  (*Main Functions*)

  type possible_ann = None | Some of Marginalia.t

  (* [t] is a record containing important information about the book *)
  type t = {
            id : int ;
            book_text : string ;
            page_start : int ;
            page_end : int ;
            page_content : string ;
            page_annotations : possible_ann
           }

  let debox_ann ann =
    match ann with
    | Some x -> x
    | None   -> No_Annotation

  let add_highlights beg ending colour t1 =
    let absolute_start = t1.page_start + beg in
    let absolute_end = t1.page_start + ending in
    try
      let new_ann = Marginalia.add_highlight
                    absolute_start absolute_end colour (debox_ann t1.page_annotations) in
      {t1 with page_annotations = new_ann}
    with
      | Marginalia.Already_Exists -> raise Annotation_Error

  let delete_highlights beg t1 =
    let absolute_start = t1.page_start + beg in
    try
      let new_ann = Marginalia.delete_highlight
                    absolute_start (debox_ann t1.page_annotations) in
      {t1 with page_annotations = new_ann}
    with
      | Not_found -> raise Annotation_Error

  let add_notes beg note colour t1 =
    let absolute_start = t1.page_start + beg in
    try
      let new_ann = Marginalia.add_note note
                    absolute_start colour (debox_ann t1.page_annotations) in
      {t1 with page_annotations = new_ann}
    with
      | Marginalia.Already_Exists -> raise Annotation_Error

  let delete_notes beg t1 =
    let absolute_start = t1.page_start + beg in
    try
      let new_ann = Marginalia.delete_note
                    absolute_start (debox_ann t1.page_annotations) in
      {t1 with page_annotations = new_ann}
    with
      | Not_found -> raise Annotation_Error

let find_meaning word =
try
    (* Highlight word *)
    let first_pos = Graphics.wait_next_event [Button_down] in
    let second_pos = Graphics.wait_next_event [Button_down] in
    let start_x = within_x_range first_pos.mouse_x in
    let start_y = within_y_range first_pos.mouse_y in
    let end_x = within_x_range second_pos.mouse_x in
    let end_y = within_y_range second_pos.mouse_y in
    Graphics.set_color colour;
    custom_highlight start_x start_y end_x end_y;

    (* Convert to English word *)
    let start_pos = relative_index start_x start_y in 
    let end_pos = relative_index end_x end_y in 
    let extr_str = String.sub t.page_content start_pos (end_pos - start_pos + 1) in
    (* Don't know whether this is a single word or not *)

    (* Find word meaning *)
    let word_meaning = DataController.find_meaning extr_str in

    (* Clear page and print definition if it exists *)
    Graphics.clear_graph ();
    custom_print ("Definition: " ^ extr_str) left_edge top_edge;

    (* return previous page on key press *)
    if (Graphics.key_pressed () = true) 
    (* Unsure how this works *)
    then custom_print t.page_content left_edge top_edge;
  else ();

  with
  | Word_Not_Found -> print_string "You didn't choose a single word " ^
                      "or no meaning of the word exists"

(*
let close_file t =
    (* save data before erasing *)
    Marginalia.save_page t;

    (* actually erase text *)
    Graphics.close_graph ();

let find_meaning word =
    let word_def =
    (try
        Bookshelf.get_definition word
     with
     | Word_Not_Found -> failwith "Please type in a correct word") in

    (* IMPLEMENT: change position to write definition; erase page and display
    word definition until clicked again *)
    Graphics.draw_string word_def;

let percent_read t =
    ((float_of_int t.ind_pos) /. (float_of_int (String.length t.book_text)))
    (* format string using printf *)

let next_page t =
    (* RAISE EXCEPTION *)

    (* erase previous content *)
    Graphics.clear_graph ();

    (* actually display page and update word counter *)
    try
        t.ind_pos := !t.ind_pos + 3735;
        t.curr_page_cont <- actual_sub t.book_text !t.ind_pos (ind_pos + 3735);

        (* position cursor *)
        Graphics.moveto 18 611;

        (* recursive function to draw string *)
        custom_print t.book_text 18 611;

        Marginalia.save_page t;
    with
    | _ -> failwith "Can't go to next page!"

let prev_page t =
    (* RAISE EXCEPTION *)
    (* erase previous content *)
    Graphics.clear_graph ();

    (* actually display page and update word counter *)
    try
        t.ind_pos := !t.ind_pos - 3735;
        t.curr_page_cont := actual_sub t.book_text !t.ind_pos (!t.ind_pos + 3735);
        Graphics.moveto 18 611;

        (* recursive function to draw string *)
        custom_print t.book_text 18 611;

        Marginalia.save_page t;
    with
    | _ -> failwith "Can't go to previous page!"

let add_notes t =
    (* call helper function in perspective to add these notes *)
    let first_pos = Graphics.wait_next_event [Button_down] in
    let start_x = first_pos.mouse_x in
    let start_y = first_pos.mouse_y - 5 in
    (* change color if needbe *)
    Graphics.fill_circle start_x start_y 2;

let delete_notes t =
    (* call helper function in perspective to delete these notes *)
    let first_pos = Graphics.wait_next_event [Button_down] in
    let start_x = first_pos.mouse_x in
    let start_y = first_pos.mouse_y - 5 in
    Graphics.set_color white;
    Graphics.fill_circle start_x start_y 2;

let add_bookmark colour =
    (* call function in perspective to add a bookmark to the current page *)
    Graphics.set_color colour;
    Graphics.fill_circle 510 636 10;
    Graphics.set_color black;

let delete_bookmark t =
    (* call function in perspective to delete a bookmark to the current page *)
    Graphics.set_color white;
    Graphics.fill_circle 510 636 10;
    Graphics.set_color black;

    (* This is a helper function to find the substring of [str] from index position
[s] to index position [e] *)
let actual_sub str s e = String.sub str s (e - s + 1)

*)
end