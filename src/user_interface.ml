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
  (* maps all points within a certain range of the y coordinate to a single
  point. Helps in drawing and erasing points/lines *)
  let within_y_range y = (y / char_height) * char_height

  (* maps all points within a certain range of the x coordinate to a single
  point. Helps in drawing and erasing points/lines *)
  let within_x_range x = (x / char_width) * char_width

  (* maps a point [(x,y)] to its relative index on the current page *)
  let relative_index x y =
    let line_number = (top_edge - y) / char_height in
    let within_line = (x - left_edge) / char_width in
    (line_number * chars_line) + within_line + line_number

  (* maps a relative index [ri] on the current page to a point (x, y). Inverse
  function of [relative_index] *)
  let rel_index_to_pixels ri =
    let actual_line_number = ri mod 84 in
    let x = (char_width * actual_line_number) + left_edge in
    let y = top_edge - char_height * (ri - ri mod 84)/(chars_line + 1) in
    (x, y)

  (* Converts a Graphics.colour to Colours.t *)
  let color_to_colour c =
    if c = Graphics.black then BLACK
    else if c = Graphics.red then RED
    else if c = Graphics.blue then BLUE
    else if c = Graphics.yellow then YELLOW
    else if c = Graphics.magenta then PURPLE
    else if c = Graphics.green then GREEN
    else raise Invalid_Colour

  (* Converts a Colours.t to a Graphics.colour. Inverse of [color_to_colour] *)
  let colour_to_color c =
    if c = BLACK then Graphics.black
    else if c = RED then Graphics.red
    else if c = BLUE then Graphics.blue
    else if c = YELLOW then Graphics.yellow
    else if c = PURPLE then Graphics.magenta
    else if c = GREEN then Graphics.green
    else raise Invalid_Colour


(************** PRINTING & HIGHLIGHTING ON THE GRAPHICS WINDOWS ***************)

  (* Custom function to underline all points from [(x1, y1)] to [(x2, y2)] in
  the Graphics window *)
  let rec custom_highlight x1 y1 x2 y2 =
    if (y2 < y1)
    then (Graphics.moveto x1 y1 ;
           Graphics.lineto right_edge y1;
           custom_highlight left_edge (y1 - char_height) x2 y2)
  else Graphics.moveto x1 y1 ; Graphics.lineto x2 y2

  (* Custom function to print [str] starting from [(x, y)] in the Graphics
  window, taking care of margin considerations and other formatting *)
  let rec custom_print str x y =
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

  (* draws the page number and percentage read of the current page in the
  footer of the Graphics window *)
  let draw_page_data t1 =
    let page_number = DataController.page_number t1 max_char in
    let percent_read = int_of_float (DataController.percent_read t1 *. 100.0) in
    let page_number_string = string_of_int page_number in
    let percent_read_string = string_of_int percent_read in
    Graphics.set_color blue; Graphics.moveto 248 13;
    Graphics.draw_string (page_number_string ^ " | " ^ percent_read_string ^ "%");
    Graphics.set_color black

  (* Bookmarks the current page and draws a bookmark of color [colour] on the
  far right corner on the Graphics window to signify the same  *)
  let draw_bookmark colour t1 =
    try
       Graphics.set_color colour;
       Graphics.fill_circle 510 636 10;
       Graphics.set_color black; (* original color *)
       let new_t = DataController.add_bookmarks t1 (color_to_colour colour) in
       new_t;
    with
      | DataController.Annotation_Error ->
      print_endline "A bookmark already exists"; t1

  (* Erases the bookmark of the current page on the Graphics window *)
  let erase_bookmark t1 =
    try
      Graphics.set_color white;
      Graphics.fill_circle 510 636 10;
      Graphics.set_color black; (* original color *)
      let new_t = DataController.delete_bookmarks t1 in new_t
    with
      | DataController.Annotation_Error ->
      print_endline "The bookmark doesn't exist" ; t1

  (* Takes user input of a position on the Graphics window, saving a related note
  (by taking user input once again). Displays the created note by plaxing a small
  dot of color [colour] below the position which was clicked on on the Graphics
  window *)
  let draw_notes colour t1 =
    try
      print_endline ("Please select on the window where you want to place the note"
      ^ " and after that type in the associated note here: ");
      let first_pos = Graphics.wait_next_event [Button_down] in
      let note_text = read_line () in
      let start_x = within_x_range first_pos.mouse_x in
      let start_y = within_y_range first_pos.mouse_y in
      let new_t = DataController.add_notes
                   (relative_index start_x start_y)
                   note_text
                   (color_to_colour colour) t1 in
      Graphics.set_color colour;
      Graphics.fill_circle start_x (start_y - 5) 2;
      Graphics.set_color black;
      new_t
    with
      | DataController.Annotation_Error ->
      print_endline "Notes can't be added at this point" ; t1

  (* Takes user input of a position on the Graphics window corresponding to the
  note that must be deleted. Erases that note of the current page on the
  Graphics window *)
  let erase_notes t1 =
    (* call helper function in perspective to add these notes *)
    try
      print_endline "Please select the note you want to erase";
      let first_pos = Graphics.wait_next_event [Button_down] in
      let start_x = within_x_range first_pos.mouse_x in
      let start_y = within_y_range first_pos.mouse_y in
      let new_t = DataController.delete_notes
                   (relative_index start_x start_y)
                   t1 in
      Graphics.set_color white;
      Graphics.fill_circle start_x (start_y - 5) 2;
      Graphics.set_color black;
      new_t
    with
      | DataController.Annotation_Error ->
      print_endline "The note doesn't exist" ; t1

  (* Takes a start and end position from the user and highlights all text between
  those positions with color [colour] on the Graphics window *)
  let draw_highlights colour t1 =
    print_endline ("Click on the screen twice: once for the start position" ^
    " and then for the end position: ");
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
      | DataController.Annotation_Error ->
      print_endline "A highlight already exists" ; t1

    (* Takes the start position from the user and deletes any highlights that
    contains that position *)
  let erase_highlights t =
    print_endline ("Click on the screen twice: once for the start position" ^
    " and then for the end position: ");
    let first_pos = Graphics.wait_next_event [Button_down] in
    let s_x = within_x_range first_pos.mouse_x in
    let s_y = within_y_range first_pos.mouse_y in
    try
      let new_t = DataController.delete_highlights (relative_index s_x s_y) t in
      let second_pos = Graphics.wait_next_event [Button_down] in
      let e_x = within_x_range second_pos.mouse_x in
      let e_y = within_y_range second_pos.mouse_y in
      Graphics.set_color white;
      custom_highlight s_x s_y e_x e_y;
      new_t
    with
      | DataController.Annotation_Error ->
      print_endline "No highlight starts at this position." ; t

  (* Takes the start and end position from the user and tries to find the
  meaning of that word, displaying it on the Graphics window*)



  (* Draws the current highlights, if any, of the page on the Graphics window *)
  let rec draw_existing_highlights lst =
    match lst with
    | (s, (c, e))::t -> Graphics.set_color (colour_to_color c);
              let (start_x, start_y) = rel_index_to_pixels s in
              let (end_x, end_y) = rel_index_to_pixels e in
              custom_highlight start_x start_y end_x end_y;
              draw_existing_highlights t
    | [] -> Graphics.set_color black

  (* Draws the current notes, if any, of the page on the Graphics window *)
  let rec draw_existing_notes lst =
    match lst with
    | (s, (c, n_t))::t -> Graphics.set_color (colour_to_color c);
              let (start_x, start_y) = rel_index_to_pixels s in
              Graphics.fill_circle start_x (start_y - 5) 2;
              draw_existing_notes t
    | [] -> Graphics.set_color black

  (* Draws the current bookmark, if any, of the page on the Graphics window *)
  let draw_existing_bookmark col_option =
    match col_option with
    | Some c -> Graphics.set_color (colour_to_color c);
              Graphics.fill_circle 510 636 10
    | None -> ()

  (* Draws the page, complete with formatted text and all annotations *)
  let draw_page which t =
    try
      let new_t =
      match which with
      | `Prev -> DataController.prev_page max_char t
      | `Next -> DataController.next_page max_char t
      | `Curr -> t in
      Graphics.clear_graph ();
      custom_print new_t.page_content left_edge top_edge;
      draw_existing_highlights (DataController.page_highlights new_t);
      draw_existing_notes (DataController.page_notes new_t);
      draw_existing_bookmark (DataController.page_bookmark new_t);
      draw_page_data new_t; new_t

    with
      | DataController.Page_Undefined _ -> print_string "Can't draw page"; t

  (* helper function to recurse through a list *)
  let rec highlights_rec counter lst =
    match lst with
    | (start, content)::t -> custom_print content 18 !counter;
    counter := !counter - 13; highlights_rec counter t
    | [] -> ()
  (* helper function for display_highlights *)
  let rec color_highlights counter all_parts =
    match all_parts with
    | (colour, other_part)::t -> Graphics.set_color (colour_to_color colour);
      moveto left_edge !counter ;lineto right_edge !counter;
      Graphics.set_color black; counter := !counter - 26;
      highlights_rec counter other_part; color_highlights counter t
    | [] -> ()

  (* Displays all highlights of the book on the Graphics window, in their resp
  -ective colors *)
  let display_highlights t =
    clear_graph ();
    let all_ann = DataController.meta_annotations t in
    let all_highlights = DataController.sort_highlights_colour t all_ann in
    color_highlights (ref 611) all_highlights;
    let ans = wait_next_event [Key_pressed] in
    if ans.keypressed = true then draw_page `Curr t else t

  (* CHECK *)
  (* helper function to recurse through a list *)
  let rec notes_rec counter lst =
    match lst with
    | (start, info, content)::t -> custom_print content 18 !counter;
    counter := !counter - 13; notes_rec counter t
    | [] -> ()

  (* helper function for display_notes *)
  let rec color_notes counter all_parts =
    match all_parts with
    | (colour, other_part)::t -> Graphics.set_color (colour_to_color colour);
      moveto left_edge !counter ;lineto right_edge !counter;
      Graphics.set_color black; counter := !counter - 26;
      notes_rec counter other_part; color_notes counter t
    | [] -> ()

  (* Displays all notes of the book on the Graphics window, in their
  respective colors *)
  let display_notes t =
    clear_graph ();
    let all_ann = DataController.meta_annotations t in
    let all_notes = DataController.sort_notes_colour t all_ann max_char in
    color_notes (ref 611) all_notes;
    let ans = wait_next_event [Key_pressed] in
    if ans.keypressed = true then draw_page `Curr t else t

  let draw_meaning t =
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
      let word_meaning = DataController.return_definition extr_str in

      (* Clear page and print definition if it exists *)
      Graphics.clear_graph ();
      custom_print ("Definition: " ^ extr_str) left_edge top_edge;
      (* return current page on key press *)
      let ans = wait_next_event [Key_pressed] in
      if ans.keypressed = true then draw_page `Curr t else t

    with
    | _ -> print_string ("You didn't choose a single word " ^
                        "or no meaning of the word exists"); t

  (* helper function to recurse throught a list *)
  let rec print_lst counter bookshelf =
    match bookshelf with
    | (id, bs)::t -> print_int !counter; print_endline (": " ^ bs); incr counter;
    print_lst counter t
    | [] -> ()


(****************** OPENING AND CLOSING THE BOOK ***************************)
  (* Opens the book specified by the bookshelf_id and book_id and displays the
  last saved page on the Graphics window *)
  let open_book bookshelf_id book_id =
    try
      Graphics.open_graph window_size;
      Graphics.set_window_title window_title;
      let t1 = DataController.init_book max_char bookshelf_id book_id in
      draw_page `Curr t1
    with
    | _ -> failwith "Can't open book"


  (* CHECK *)

  (* Helper function to choose a book from a bookshelf (referenced through a
  bookshelf_id) on the terminal *)
  let rec choose_book bookshelf_id =
  (* print a list of books on this bookshelf given by a helper function *)
  try
    let lst_of_books = DataController.book_list bookshelf_id in
    print_endline "Choose a book"; print_lst (ref 0) lst_of_books;
    print_endline "Please choose a book by entering the index before the book: ";
    let int_input = read_int () in
    let array_of_bookshelves = Array.of_list lst_of_books in
    let reqd_bookshelf = array_of_bookshelves.(int_input) in
    open_book bookshelf_id (fst reqd_bookshelf)


  with
    | _ -> print_endline "Can't choose book; please choose again";
        choose_book bookshelf_id

  (* CHECK *)

  (* Displays the current list of bookshelves on the user's computer on the
  terminal *)
  let rec choose_bookshelf () =
  try
    let lst_of_bookshelves = DataController.bookshelf_list () in
    print_endline "Choose a bookshelf"; print_lst (ref 0) lst_of_bookshelves;
    print_endline ("Please choose a bookshelf by entering the index before the"
    ^ "bookshelf");
    let int_input = read_int () in
    let array_of_bookshelves = Array.of_list lst_of_bookshelves in
    let reqd_bookshelf = array_of_bookshelves.(int_input) in
    choose_book (fst reqd_bookshelf)

  with
    | _ -> failwith "Can't open bookshelf; please choose again"

  (* CHECK for error handling*)

  (* Closes the current book *)
  let close_book t =
    DataController.close_book t;
    Graphics.close_graph ();
    print_endline "You closed the book" (* add book name here *)

  (* searching notes *)

(******************************** REPL ***********************************)

  (* CHECK *)

  (* The REPL is a loop that ensures the user can continously interact with
  the OCindle interface *)
  let rec repl t colour =
      let keys = Graphics.wait_next_event [Key_pressed] in
      match keys.key with
      | 'd' -> Graphics.set_color black; let t1 = draw_page `Next t in repl t1 colour
      | 'a' -> Graphics.set_color black; let t1 = draw_page `Prev t in repl t1 colour
      | 'b' -> let t1 = draw_bookmark colour t  in repl t1 colour
      | 'h' -> let t1 = draw_highlights colour t in repl t1 colour
      | 'n' -> let t1 = draw_notes colour t in repl t1 colour
      | 'q' -> let t1 = erase_bookmark t in repl t1 colour
      | 'w' -> let t1 = erase_highlights t in repl t1 colour
      | 'e' -> let t1 = erase_notes t in repl t1 colour
      | 'o' -> let t1 = choose_bookshelf () in repl t1 colour
      | 'c' -> close_book t;
        print_string "Press o to open another book or q to quit: ";
        let ans = read_line () in
        if ans = "o" then let t1 = choose_bookshelf () in repl t1 black
      else exit 0
      | '1' -> repl t black
      | '2' -> repl t red
      | '3' -> repl t blue
      | '4' -> repl t yellow
      | '5' -> repl t green
      | '6' -> repl t white
      | _ -> print_string "You pressed an incorrect key. Press again!"; exit 0

  (* Allows the user to open a book and passes control to the REPL to perform
  further actions *)
  let main () =
    let t = choose_bookshelf () in
    repl t black;

end