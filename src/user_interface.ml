module UserInterface = struct

  open DataController
  open Colours

  exception Invalid_Colour

  type t = DataController.t

(**************************** WINDOW CONSTANTS *******************************)

  let char_height = 13 (* height of a character *)
  let char_width = 6   (* width of a character *)
  let left_edge = 18   (* left edge of first char in any line *)
  let right_edge = 516 (* left edge of final char in any line *)
  let top_edge = 611   (* bottom of chars in the top line *)
  let bot_edge = 26    (* bottom of chars in the last line *)
  let chars_line = 83  (* max divisions in a line. chars are chars_line + 1 *)
  let max_char = 3780  (* maximum number of characters on a page *)
  let window_size = " 540x650" (* width x height *)
  let window_title = "OCindle - no, it's not the Kindle" (* title *)


(**************************** WINDOW HELPERS *******************************)

  let within_y_range y = (y / char_height) * char_height

  let within_x_range x = (x / char_width) * char_width

  let relative_index x y =
    let line_number = (top_edge - y) / char_height in (* 0-indexed *)
    let within_line = (x - left_edge) / char_width in
    (line_number * chars_line) + within_line + line_number

  let rel_index_to_pixels ri =
    let actual_line_number = ri mod 84 in
    let x = (char_width * actual_line_number) + left_edge in
    let y = top_edge - char_height * (ri - ri mod 84)/(chars_line + 1) in
    (x, y)

  (* Graphics Colours to Colours module *)
  let color_to_colour c =
    if c = Graphics.black then BLACK
    else if c = Graphics.red then RED
    else if c = Graphics.blue then BLUE
    else if c = Graphics.yellow then YELLOW
    else if c = Graphics.magenta then PURPLE
    else if c = Graphics.green then GREEN
    else raise Invalid_Colour

  (* Colours to Graphics Colours module *)
  let colour_to_color c =
    if c = BLACK then Graphics.black
    else if c = RED then Graphics.red
    else if c = BLUE then Graphics.blue
    else if c = YELLOW then Graphics.yellow
    else if c = PURPLE then Graphics.magenta
    else if c = GREEN then Graphics.green
    else raise Invalid_Colour


(************** PRINTING & HIGHLIGHTING ON THE GRAPHICS WINDOWS ***************)

  let rec custom_highlight x1 y1 x2 y2 =
    if (y2 < y1)
    then (Graphics.moveto x1 y1 ;
           Graphics.lineto right_edge y1;
           custom_highlight left_edge (y1 - char_height) x2 y2)
  else Graphics.moveto x1 y1 ; Graphics.lineto x2 y1


  let rec custom_print str x y =
    Graphics.set_color black ;
    let print_chars = chars_line + 1 in
    if (String.length str > print_chars)
      then
        (Graphics.moveto x y;
        Graphics.draw_string (String.sub str 0 print_chars);
        custom_print (String.sub str print_chars
                     (String.length str - print_chars))
                     left_edge (y - char_height))
    else
        (Graphics.moveto x y;
        Graphics.draw_string str)


(****************** DRAWING PAGES, ANNOTATIONS & MEANING *********************)

  let draw_page_data t =
    let page_number = DataController.page_number t max_char in
    let percent_read = DataController.percent_read t in
    let page_number_string = string_of_int page_number in
    let percent_read_string = string_of_int (int_of_float percent_read) in
    Graphics.set_color blue; Graphics.moveto 270 13;
    Graphics.draw_string (page_number_string ^ " | " ^ percent_read_string ^ "%");
    Graphics.set_color black

  let draw_bookmark colour t1 =
    try
       Graphics.set_color colour;
       Graphics.fill_circle 510 636 10;
       Graphics.set_color black; (* original color *)
       let new_t = DataController.add_bookmarks t1 (color_to_colour colour) in
       new_t;
    with
      | DataController.Annotation_Error -> print_string "A bookmark already exists"; t1


  let erase_bookmark t1 =
    try
      Graphics.set_color white;
      Graphics.fill_circle 510 636 10;
      Graphics.set_color black; (* original color *)
      let new_t = DataController.delete_bookmarks t1 in new_t
    with
      | DataController.Annotation_Error -> print_string "The bookmark doesn't exist" ; t1


  let draw_notes colour t1 =
    try
      print_endline ("Please select on the window where you want to place the note"
      ^ "and after that type in the associated note here: ");
      let first_pos = Graphics.wait_next_event [Button_down] in
      let note_text = read_line () in
      let start_x = within_x_range first_pos.mouse_x in
      let start_y = within_y_range (first_pos.mouse_y - 5) in
      let new_t = DataController.add_notes
                   (relative_index start_x start_y)
                   note_text
                   (color_to_colour colour) t1 in
      Graphics.fill_circle start_x start_y 2;
      new_t
    with
      | DataController.Annotation_Error -> print_string "Notes can't be added at this point" ; t1


  let erase_notes t1 =
    (* call helper function in perspective to add these notes *)
    try
      print_endline "Please select the note you want to delete";
      let first_pos = Graphics.wait_next_event [Button_down] in
      let start_x = within_x_range first_pos.mouse_x in
      let start_y = within_y_range first_pos.mouse_y - 5 in
      let new_t = DataController.delete_notes
                   (relative_index start_x start_y)
                   t1 in
      Graphics.set_color white;
      Graphics.fill_circle start_x start_y 2;
      new_t
    with
      | DataController.Annotation_Error -> print_string "The note doesn't exist" ; t1


  let draw_highlights colour t1 =
    let first_pos = Graphics.wait_next_event [Button_down] in
    let second_pos = Graphics.wait_next_event [Button_down] in
    let start_x = within_x_range first_pos.mouse_x in
    let start_y = within_y_range first_pos.mouse_y in
    let end_x = within_x_range second_pos.mouse_x in
    let end_y = within_y_range second_pos.mouse_y in
    try
       let new_t = DataController.add_highlights
                   (relative_index start_x start_y)
                   (relative_index end_x end_y)
                   (color_to_colour colour) t1 in
       Graphics.set_color colour;
       custom_highlight start_x start_y end_x end_y;
       new_t
    with
      | DataController.Annotation_Error -> print_string "A highlight already exists" ; t1


  let erase_highlights t =
    let first_pos = Graphics.wait_next_event [Button_down] in
    let s_x = within_x_range first_pos.mouse_x in
    let s_y = within_y_range first_pos.mouse_y in
    try
      let new_t = DataController.delete_highlights (relative_index s_x s_y) t in
      let second_pos = Graphics.wait_next_event [Button_down] in
      let e_x = within_x_range second_pos.mouse_x in
      let e_y = within_y_range second_pos.mouse_y in
      Graphics.set_color Graphics.white ;
      custom_highlight s_x s_y e_x e_y ;
      new_t
    with
      | DataController.Annotation_Error -> print_string "No highlight starts at this position." ; t

  (* TEST *)
  let draw_meaning word t =
  try
    (* Highlight word *)
    let first_pos = Graphics.wait_next_event [Button_down] in
    let second_pos = Graphics.wait_next_event [Button_down] in
    let start_x = within_x_range first_pos.mouse_x in
    let start_y = within_y_range first_pos.mouse_y in
    let end_x = within_x_range second_pos.mouse_x in
    let end_y = within_y_range second_pos.mouse_y in
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
    then (custom_print t.page_content left_edge top_edge;)
  else ();

  with
  | _ -> print_string ("You didn't choose a single word " ^
                      "or no meaning of the word exists")

  let rec print_lst counter bookshelf =
    match bookshelf with
    | (id, bs)::t -> print_int !counter; print_endline (": " ^ bs); incr counter;
    print_lst counter t;
    | [] -> ()

  let rec rec_thru_list counter lst =
  match lst with
  | (b, context)::t -> custom_print context 18 !counter; counter := !counter - 13;
  rec_thru_list counter t;
  | [] -> ()

  let rec color_parts all_parts =
  match all_parts with
  | (colour, other_part)::t1 -> Graphics.set_color colour; rec_thru_list (ref 611) other_part;
                             color_highlights t1;
  | [] -> ()

  let rec draw_existing_highlights t1 =
    match DataController.page_highlights t1 with
    | (s, (c, e))::t -> Graphics.set_color (colour_to_color c);
              let (start_x, start_y) = rel_index_to_pixels s in
              let (end_x, end_y) = rel_index_to_pixels e in
              custom_highlight start_x start_y end_x end_y;
              draw_existing_highlights t1;
    | [] -> Graphics.set_color black


  let rec draw_existing_notes t1 =
    match DataController.page_notes t1 with
    | (s, (c, n_t))::t -> Graphics.set_color (colour_to_color c);
              let (start_x, start_y) = rel_index_to_pixels s in
              Graphics.fill_circle start_x start_y 2;
              draw_existing_notes t1;
    | [] -> Graphics.set_color black

  let draw_existing_bookmark t1 =
    match DataController.page_bookmark t1 with
    | Some c -> Graphics.set_color (colour_to_color c);
              Graphics.fill_circle 510 636 10;
    | None -> ()

  let draw_page which t =
    try
      let new_t =
      match which with
      | `Prev -> DataController.prev_page max_char t
      | `Next -> DataController.next_page max_char t
      | `Curr -> t in
      Graphics.clear_graph ();
      custom_print new_t.page_content left_edge top_edge; new_t
      draw_existing_highlights new_t;
      draw_existing_notes new_t;
      draw_existing_bookmark new_t;
      draw_page_data new_t;

    with
      | DataController.Page_Undefined _ -> print_string "Can't draw page"; t

  let rec display_notes t =
    let all_ann = DataController.meta_annotations t in
    let all_notes = DataController.sort_notes_color t all_ann in
    color_parts all_notes

  let display_highlights t =
    let all_ann = DataController.meta_annotations t in
    let all_highlights = DataController.sort_highlights_colour t all_ann in
    color_parts all_highlights

(****************** OPENING AND CLOSING THE BOOK ***************************)

  let open_book bookshelf_id book_id =
    Graphics.open_graph window_size;
    Graphics.set_window_title window_title;
    let t1 = DataController.init_book max_char bookshelf_id book_id in
    draw_page `Curr t1

  let choose_book bookshelf_id =
  (* print a list of books on this bookshelf given by a helper function *)
  try
    let lst_of_books = DataController.book_list bookshelf_id in
    print_endline "Choose a book"; print_lst (ref 0) lst_of_books;
    print_endline "Please choose a book by entering the index before the book";
    let int_input = read_int () in
    let array_of_bookshelves = Array.of_list lst_of_bookshelves in
    let reqd_bookshelf = array_of_bookshelves.(int_input) in
    open_book bookshelf_id (fst reqd_bookshelf)

  with
    | _ -> print_endline "Can't open book"

  let choose_bookshelf () =
  try
    let lst_of_bookshelves = DataController.bookshelf_list () in
    print_endline "Choose a bookshelf"; print_lst (ref 0) lst_of_bookshelves;
    print_endline "Please choose a bookshelf by entering the index before the bookshelf";
    let int_input = read_int () in
    let array_of_bookshelves = Array.of_list lst_of_bookshelves in
    let reqd_bookshelf = array_of_bookshelves.(int_input) in
    choose_book fst (reqd_bookshelf)

  with
    | _ -> failwith "Can't open bookshelf"


  let close_book t =
    failwith "Unimplemented"

    (* save book data (type t) locally *)
    DataController.close_book t;
`
    (* Graphics.close_graph () *)
    Graphics.close_graph ();

    (* display message *)
    print_endline "You closed the book "; (* add book name here *)

  (* searching notes *)

(******************************** REPL ***********************************)


  let rec repl () =
    try
      match Graphics.wait_next_event [Key_pressed] with
      | 'd' -> let t1 = draw_page `Next in repl t1
      | 'a' -> let t1 = draw_page `Prev in repl t1
      | 'b' -> let t1 = draw_bookmark colour t in repl t1
      | 'h' -> let t1 = draw_highlights colour t in repl t1
      | 'n' -> let t1 = draw_notes colour t in repl t1
      | 'q' -> let t1 = erase_bookmark t in repl t1
      | 'w' -> let t1 = erase_highlights t in repl t1
      | 'e' -> let t1 = erase_notes t in repl t1
      | 'o' -> let t1 = choose_bookshelf () in repl t1
      | 'c' -> close_book t

      with
      | _ -> print_endline "You pressed an incorrect key";

  let main () =
    repl ()

end


