  open Data_controller
  open Colours
  open Graphics

  exception Invalid_Colour

  type t = Data_controller.t

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


(**************************** WINDOW HELPERS *********************************)

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
    if c = Graphics.black then colorify "black"
    else if c = Graphics.red then colorify "red"
    else if c = Graphics.blue then colorify "blue"
    else if c = Graphics.yellow then colorify "yellow"
    else if c = Graphics.magenta then colorify "purple"
    else if c = Graphics.green then colorify "green"
    else raise Invalid_Colour


  (* Converts a Colours.t to a Graphics.colour. Inverse of [color_to_colour] *)
  let colour_to_color c =
    if c = colorify "black" then Graphics.black
    else if c = colorify "red" then Graphics.red
    else if c = colorify "blue" then Graphics.blue
    else if c = colorify "yellow" then Graphics.yellow
    else if c = colorify "purple" then Graphics.magenta
    else if c = colorify "green" then Graphics.green
    else raise Invalid_Colour


(************** PRINTING & HIGHLIGHTING ON THE GRAPHICS WINDOWS **************)

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


(************************ HELPERS FOR MAIN FUNCTIONS *************************)

  (* first element of a triple *)
  let first (x,y,z) = x

  (* helper function for [color_highlights] *)
  let rec highlights_rec counter lst =
    match lst with
    | (page_number, content)::t ->
    let page_no = string_of_int page_number in
    custom_print (page_no ^ " : " ^ content) 18 !counter;
    let str_length = String.length content in
    counter := !counter - 13 * ((str_length / (chars_line + 1)) + 1);
    highlights_rec counter t
    | [] -> ()


  (* helper function for [display_highlights] *)
  let rec color_highlights counter all_parts =
    match all_parts with
    | (colour, other_part)::t -> print_endline " "; Graphics.set_color (colour_to_color colour);
      Graphics.moveto left_edge !counter ;Graphics.lineto right_edge !counter;
      Graphics.set_color Graphics.black; counter := !counter - 26;
      highlights_rec counter other_part;
       color_highlights counter t
    | [] -> ()


  (* helper function for [color_notes] *)
  let rec notes_rec counter lst =
    match lst with
    | (page_number, note_info, context)::t ->
    let page_no = string_of_int page_number in
    custom_print (page_no ^ " | Note: " ^ note_info ^ " | Context: " ^ context) 18 !counter;
    let str_length = String.length (note_info ^ context) in
    counter := !counter - 13 * ((str_length / (chars_line + 1)) + 1);
    notes_rec counter t
    | [] -> ()


  (* helper function for [display_notes] *)
  let rec color_notes counter all_parts =
    match all_parts with
    | (colour, other_part)::t -> Graphics.set_color (colour_to_color colour);
      Graphics.moveto left_edge !counter ;Graphics.lineto right_edge !counter;
      Graphics.set_color Graphics.black; counter := !counter - 26;
      notes_rec counter other_part;
      print_endline " ";
      color_notes counter t
    | [] -> ()


  (* helper function to recurse throught a list *)
  let rec print_lst_bookshelf counter bookshelf =
    match bookshelf with
    | (id, bs)::t -> print_int !counter; print_endline (": " ^ bs);
    incr counter; print_lst_bookshelf counter t
    | [] -> ()

  (* helper function to recurse throught a list *)
  let rec print_lst_book counter bookshelf =
    match bookshelf with
    | (id, title, author)::t -> print_int !counter;
    print_endline (": Title - " ^ title ^ " | Author - " ^ author);
    incr counter; print_lst_book counter t
    | [] -> ()


  (* helper function for [search_notes] *)
  let rec search_lst text lst =
    match lst with
    | (colour, (s, words)):: t ->
      if text = words
      then
        (Graphics.clear_graph (); Graphics.set_color colour;
        custom_print text left_edge top_edge; Graphics.set_color Graphics.black)
      else search_lst text t
    | [] -> Graphics.clear_graph (); failwith "Text not found in notes"


(************ DRAWING PAGES, ANNOTATIONS, MEANINGS AND SEARCH ****************)

  (* draws the page number and percentage read of the current page in the
  footer of the Graphics window *)
  let draw_page_data t1 =
    let page_number = Data_controller.page_number t1 in
    let percent_read = int_of_float (Data_controller.percent_read t1 *. 100.0) in
    let page_number_string = string_of_int page_number in
    let percent_read_string = string_of_int percent_read in
    Graphics.set_color Graphics.blue; Graphics.moveto 248 13;
    Graphics.draw_string (page_number_string ^ " | " ^ percent_read_string ^ "%");
    Graphics.set_color Graphics.black


  (* Bookmarks the current page and draws a bookmark of color [colour] on the
  far right corner on the Graphics window to signify the same  *)
  let draw_bookmark colour t1 =
    try
       let new_t = Data_controller.add_bookmarks t1 (color_to_colour colour) in
       Data_controller.close_book t1; 
      Graphics.set_color colour;
       Graphics.fill_poly [|(522, 624); (522,648); (538, 648); (538, 624); (530, 635);
       (522, 624) |];
       Graphics.set_color Graphics.black;
      new_t
    with
      | Data_controller.Annotation_Error ->
      print_endline " ";
      print_endline "A bookmark already exists"; t1


  (* Erases the bookmark of the current page on the Graphics window *)
  let erase_bookmark t1 =
    try
      let new_t = Data_controller.delete_bookmarks t1 in
      Data_controller.close_book t1; 
      Graphics.set_color Graphics.white;
      Graphics.fill_poly [|(522, 624); (522,648); (538, 648); (538, 624); (530, 635);
      (522, 624) |];
      Graphics.set_color Graphics.black; (* original color *)
      new_t
    with
      | Data_controller.Annotation_Error ->
        print_endline " ";
        print_endline "The bookmark doesn't exist" ; t1


  (* Takes user input of a position on the Graphics window, saving a related note
  (by taking user input once again). Displays the created note by plaxing a small
  dot of color [colour] below the position which was clicked on on the Graphics
  window *)
  let draw_notes colour t1 =
    try
      print_endline " ";
      Pervasives.print_string ("Please select on the window where you want to"
      ^ " place the note and after that type in the associated note here: ");
      let first_pos = Graphics.wait_next_event [Button_down] in
      let note_text = read_line () in
      let start_x = within_x_range first_pos.mouse_x in
      let start_y = within_y_range first_pos.mouse_y in
      let new_t = Data_controller.add_notes
                   (relative_index start_x start_y)
                   note_text
                   (color_to_colour colour) t1 in Data_controller.close_book t1;
      Graphics.set_color colour;
      Graphics.fill_circle start_x (start_y - 3) 3;
      Graphics.set_color Graphics.black;
      new_t
    with
      | Data_controller.Annotation_Error ->
      print_endline " ";
      print_endline "Notes can't be added at this point" ; t1


  (* Takes user input of a position on the Graphics window corresponding to the
  note that must be deleted. Erases that note of the current page on the
  Graphics window *)
  let erase_notes t1 =
    (* call helper function in perspective to add these notes *)
    try
      print_endline " ";
      Pervasives.print_string "Please select the note you want to erase";
      let first_pos = Graphics.wait_next_event [Button_down] in
      let start_x = within_x_range first_pos.mouse_x in
      let start_y = within_y_range first_pos.mouse_y in
      let new_t = Data_controller.delete_notes
                   (relative_index start_x start_y)
                   t1 in Data_controller.close_book t1;
      Graphics.set_color Graphics.white;
      Graphics.fill_circle start_x (start_y - 3) 3;
      Graphics.set_color Graphics.black;
      new_t
    with
      | Data_controller.Annotation_Error ->
      print_endline " ";
      print_endline "The note doesn't exist" ; t1


  (* Takes a start and end position from the user and highlights all text between
  those positions with color [colour] on the Graphics window *)
  let draw_highlights colour t1 =
    print_endline " ";
    Pervasives.print_string ("Click on the screen twice: once for the start" ^
    " position and then for the end position: ");
    let first_pos = Graphics.wait_next_event [Button_down] in
    let second_pos = Graphics.wait_next_event [Button_down] in
    let start_x = within_x_range first_pos.mouse_x in
    let start_y = within_y_range first_pos.mouse_y in
    let end_x = within_x_range second_pos.mouse_x in
    let end_y = within_y_range second_pos.mouse_y in
    try
       let new_t = Data_controller.add_highlights
                   (relative_index start_x start_y)
                   (relative_index end_x end_y)
                   (color_to_colour colour) t1 in Data_controller.close_book t1;
       Graphics.set_color colour;
       custom_highlight start_x start_y end_x end_y;
       new_t
    with
      | Data_controller.Annotation_Error ->
      print_endline " ";
      print_endline "A highlight already exists" ; t1


    (* Takes the start position from the user and deletes any highlights that
    contains that position *)
  let erase_highlights t =
    print_endline " ";
    Pervasives.print_string ("Click on the screen twice: once for the start" ^
    " position and then for the end position: ");
    let first_pos = Graphics.wait_next_event [Button_down] in
    let s_x = within_x_range first_pos.mouse_x in
    let s_y = within_y_range first_pos.mouse_y in
    try
      let new_t = Data_controller.delete_highlights (relative_index s_x s_y) t in
      Data_controller.close_book t;
      let second_pos = Graphics.wait_next_event [Button_down] in
      let e_x = within_x_range second_pos.mouse_x in
      let e_y = within_y_range second_pos.mouse_y in
      Graphics.set_color Graphics.white;
      custom_highlight s_x s_y e_x e_y;
      new_t
    with
      | Data_controller.Annotation_Error ->
      print_endline " ";
      print_endline "No highlight starts at this position." ; t


  (* Draws the current highlights, if any, of the page on the Graphics window *)
  let rec draw_existing_highlights lst =
    match lst with
    | (s, (c, e))::t -> Graphics.set_color (colour_to_color c);
              let (start_x, start_y) = rel_index_to_pixels s in
              let (end_x, end_y) = rel_index_to_pixels e in
              custom_highlight start_x start_y end_x end_y;
              draw_existing_highlights t
    | [] -> Graphics.set_color Graphics.black


  (* Draws the current notes, if any, of the page on the Graphics window *)
  let rec draw_existing_notes lst =
    match lst with
    | (s, (c, n_t))::t -> Graphics.set_color (colour_to_color c);
              let (start_x, start_y) = rel_index_to_pixels s in
              Graphics.fill_circle start_x (start_y - 3) 3;
              draw_existing_notes t
    | [] -> Graphics.set_color Graphics.black


  (* Draws the current bookmark, if any, of the page on the Graphics window *)
  let draw_existing_bookmark col_option =
    match col_option with
    | Some c -> Graphics.set_color (colour_to_color c);
       fill_poly [|(522, 624); (522,648); (538, 648); (538, 624); (530, 635);
       (522, 624) |];
    | None -> ()


  (* Draws the page, complete with formatted text and all annotations *)
  let draw_page which t =
    try
      let new_t =
      match which with
      | `Prev -> Data_controller.prev_page max_char t
      | `Next -> Data_controller.next_page max_char t
      | `Curr -> t in
      Graphics.clear_graph ();
      custom_print (get_page_contents new_t) left_edge top_edge;
      draw_existing_highlights (Data_controller.page_highlights new_t);
      draw_existing_notes (Data_controller.page_notes new_t);
      draw_existing_bookmark (Data_controller.page_bookmark new_t);
      draw_page_data new_t; new_t

    with
      | Data_controller.Page_Undefined _ -> 
        print_endline "Can't turn page: end of book reached"; t


  (* Displays all highlights of the book on the Graphics window, in their resp
  -ective colors *)
  let display_highlights t =
  try
    Graphics.clear_graph ();
    let all_ann = Data_controller.meta_annotations t in
    let all_highlights = Data_controller.sort_highlights_colour t all_ann in
     if all_highlights = [] then
    custom_print "Currently no highlights! " left_edge top_edge
  else
    color_highlights (ref 611) all_highlights;
    Pervasives.print_string ("Enter page number to go. " ^
    "Enter '/' to go back to the current page: ");
    let page_to = read_line () in
    if page_to = "/" then draw_page `Curr t else
    (let int_page = int_of_string page_to in
    let new_t = Data_controller.get_page int_page t in
    draw_page `Curr new_t)
  with
    | _ -> print_endline " ";
    print_endline "Error in reading input! Returned to last viewed page";
    draw_page `Curr t


  (* Displays all notes of the book on the Graphics window, in their
  respective colors *)
  let display_notes t =
  try
    Graphics.clear_graph ();
    let all_ann = Data_controller.meta_annotations t in
    let all_notes = Data_controller.sort_notes_colour t all_ann 20 in
    if all_notes = [] then
    custom_print "Currently no notes! " left_edge top_edge
  else
    color_notes (ref 611) all_notes;
    Pervasives.print_string ("Enter page number to go. " ^
    "Enter '/' to go back to the current page: ");
    let page_to = read_line () in
    if page_to = "/" then draw_page `Curr t else
    (let int_page = int_of_string page_to in
    let new_t = Data_controller.get_page int_page t in
    draw_page `Curr new_t)
  with
    | _ -> print_endline " ";
    print_endline "Error in reading input!"; draw_page `Curr t


  (* displays the meaning of the word selected by user input or a message to
  convey there is no meaning or an incorrect word string was entered *)
  let draw_meaning t =
    try
      (* Highlight word *)
      print_endline ("Click on the screen twice: once for the start position" ^
    " and then for the end position: ");
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
      let extr_str = String.sub (get_page_contents t) start_pos (end_pos - start_pos + 1) in
      (* Don't know whether this is a single word or not *)

      (* Clear page and print definition if it exists *)
      Graphics.clear_graph ();
      (* Find word meaning *)
      let word_meaning = Data_controller.return_definition extr_str in
      Graphics.set_color Graphics.blue;
      custom_print ("Definition of " ^ extr_str ^ " :") left_edge top_edge;
      Graphics.set_color Graphics.black;
      custom_print word_meaning left_edge (top_edge - 26);
      (* return current page on key press *)
      let ans = wait_next_event [Key_pressed] in
      if ans.keypressed = true then draw_page `Curr t else t

    with
    | _ -> custom_print ("You didn't choose a single word " ^
                        "or no meaning of the word exists")
                        left_edge top_edge; t


  (* checks if keyword enters by user matches content in any notes and
  returns corresponding output on the Graphics window *)
  let search_notes t =
  try
    print_endline " ";
    print_endline "Enter the text to search: ";
    let text = read_line () in
    let all_ann = Data_controller.meta_annotations t in
    let search_list = Data_controller.search text all_ann in
    search_lst text search_list;
    let key_ans = wait_next_event [Key_pressed] in
      if key_ans.keypressed = true then draw_page `Curr t else t
  with
  | _ -> custom_print "Couldn't find this text in current set of notes"
   left_edge top_edge; t


(****************** OPENING AND CLOSING THE BOOK ***************************)

  (* Opens the book specified by the bookshelf_id and book_id and displays the
  last saved page on the Graphics window *)
  let rec open_book bookshelf_id book_id =
    try
      Graphics.open_graph window_size;
      Graphics.set_window_title window_title;
      let t1 = Data_controller.init_book max_char bookshelf_id book_id in
      draw_page `Curr t1
    with
    | _ -> print_endline " ";
    Pervasives.print_string ("Can't open book; Press 'q' to exit the program" ^
    " or any other key to choose another bookshelf: ");
    let ans = read_line () in
    if ans = "q" then exit 0 else open_book bookshelf_id book_id


  (* Helper function to choose a book from a bookshelf (referenced through a
  bookshelf_id) on the terminal *)
  let rec choose_book bookshelf_id =
  try
    print_endline " ";
    ANSITerminal.print_string [ANSITerminal.green] "Choose a book";
    print_endline " "; print_endline " ";
    let lst_of_books = Data_controller.book_list bookshelf_id in
    print_lst_book (ref 0) lst_of_books; print_endline " ";
    ANSITerminal.print_string [ANSITerminal.green]
    ("Please choose a book by entering the" ^
    " index before the book: ");
    let int_input = read_int () in
    let array_of_bookshelves = Array.of_list lst_of_books in
    let reqd_bookshelf = array_of_bookshelves.(int_input) in
    open_book bookshelf_id (first reqd_bookshelf)

  with
    | _ -> print_endline " ";
    print_endline "Can't choose book.";
    Pervasives.print_string ("Press 'q' to exit the program" ^
    " or any other key to choose another book: ");
    let ans = read_line () in
    if ans = "q" then exit 0 else choose_book bookshelf_id


  (* Displays the current list of bookshelves on the user's computer on the
  terminal *)
  let rec choose_bookshelf () =
  try
    print_endline " ";
    ANSITerminal.print_string [ANSITerminal.green] "List of bookshelves: ";
    print_endline " ";
    let lst_of_bookshelves = Data_controller.bookshelf_list () in
    print_lst_bookshelf (ref 0) lst_of_bookshelves; print_endline "";
    ANSITerminal.print_string [ANSITerminal.green]
     ("Please choose a bookshelf by entering the index before the"
    ^ " bookshelf: ");
    let int_input = read_int () in
    let array_of_bookshelves = Array.of_list lst_of_bookshelves in
    let reqd_bookshelf = array_of_bookshelves.(int_input) in
    choose_book (fst reqd_bookshelf)

     with
    | _ -> print_endline " ";
    Pervasives.print_string ("Can't choose bookshelf." ^
    " Press 'q' to exit the program" ^
    " or any other key to choose another bookshelf: ");
    let ans = read_line () in
    if ans = "q" then ( exit 0)
  else choose_bookshelf ()


  (* Closes the current book *)
  let close_book t =
    Data_controller.close_book t;
    Graphics.close_graph ();
    print_endline "";
    ANSITerminal.print_string [ANSITerminal.green] ("You closed the book. " ^
    "We hope you enjoyed using the OCindle interface!")


  (* Displays the help menu*)
  let help () =
  ANSITerminal.print_string [ANSITerminal.yellow] ("The commands and their" ^
  "explanations: ");
  print_endline " ";
  ANSITerminal.print_string [ANSITerminal.yellow] "The default color is black.";
  print_endline " ";
  ANSITerminal.print_string [ANSITerminal.green] "  d ";
  print_endline ": Goes to the next page.";
  ANSITerminal.print_string [ANSITerminal.green] "  a ";
  print_endline ": Goes to the previous page. ";
  ANSITerminal.print_string [ANSITerminal.green] "  b ";
  print_endline (": Bookmarks the current page. A bookmark is displayed on the " ^
  "top right corner ");
  ANSITerminal.print_string [ANSITerminal.green] "  h ";
  print_endline (": Highlight the current page. After pressing this key, the " ^
  "user will be prompted to select a start and end position on the screen " ^
  "respectively. The highlight is made in the current color ");
  ANSITerminal.print_string [ANSITerminal.green] "  n ";
  print_endline (": Makes a note on the current page. After pressing this key," ^
  "the user will be prompted to select the letter corresponding to the note." ^
  "The user will then be prompted on the terminal to write the note." ^
  "The presence of a note is signified by a dot below the letter the note" ^
  "was made. ");
  ANSITerminal.print_string [ANSITerminal.green] "  q ";
  print_endline ": Erases the bookmark on the current page. ";
  ANSITerminal.print_string [ANSITerminal.green] "  x ";
  print_endline ": Erases the selected highlight on the current page. ";
  ANSITerminal.print_string [ANSITerminal.green] "  e ";
  print_endline ": Erases the selected note on the current page. ";
  ANSITerminal.print_string [ANSITerminal.green] "  o ";
  print_endline (": Opens the current set of bookshelves on the user's folder." ^
  "The user is then prompted to select one, then choose and open a book inside it. " ^
  "The book is opened to the last saved position ");
  ANSITerminal.print_string [ANSITerminal.green] "  w ";
  print_endline (": Displays the meaning of the word selected by the user. " ^
  "After pressing this key, the user will be prompted to highlight a word, " ^
  "as is done for highlighting. If the word meaning exists, it is displayed on " ^
  "a new page. The user should press any key besides the ones mentioned in this " ^
  "section to exit the definition page and return to the last read page ");
  ANSITerminal.print_string [ANSITerminal.green] "  s ";
  print_endline (": Searches the current set of notes for the given word. " ^
  "After pressing this key, the user will be prompted to enter the search term " ^
  "on the terminal. The word is then searched, and if found, displayed on a new " ^
   "page. The user should press any key besides the ones mentioned in this " ^
   "section to exit the definition page and return to the last read page ");
  ANSITerminal.print_string [ANSITerminal.green] "  z ";
  print_endline (": Displays the set of current highlights with their page " ^
  "numbers sorted by colour and then by indices. The user will be then be " ^
  "prompted to return to the book: pressing '/' returns to the last read page, " ^
   "while entering a valid page will take the user to that page");
  ANSITerminal.print_string [ANSITerminal.green] "  m ";
  print_endline (": Displays the set of current notes with their page numbers " ^
  "sorted by colour and then by indices. The user will be then be prompted to " ^
  "return to the book: pressing '/' returns to the last read page, while " ^
  "entering a valid page will take the user to that page");
  ANSITerminal.print_string [ANSITerminal.green] "  c ";
  print_endline (": Closes the current book. The user will then be " ^
  "prompted to press 'q' to quit the program or 'o' to open another book");
  ANSITerminal.print_string [ANSITerminal.green] "  1 ";
  print_endline ": Change the current color to black. ";
  ANSITerminal.print_string [ANSITerminal.green] "  2 ";
  print_endline ": Change the current color to red. ";
  ANSITerminal.print_string [ANSITerminal.green] "  3 ";
  print_endline ": Change the current color to blue. ";
  ANSITerminal.print_string [ANSITerminal.green] "  4 ";
  print_endline ": Change the current color to yellow. ";
  ANSITerminal.print_string [ANSITerminal.green] "  5 ";
  print_endline ": Change the current color to green. ";
  ANSITerminal.print_string [ANSITerminal.green] "  6 ";
  print_endline ": Change the current color to purple. "

(******************************** REPL ***********************************)


  (* The REPL is a loop that ensures the user can continously interact with
  the OCindle interface *)
  let rec repl t colour =
    let keys = Graphics.wait_next_event [Key_pressed] in
    match keys.key with
      | 'd' -> Graphics.set_color Graphics.black;
              let t1 = draw_page `Next t in repl t1 colour
      | 'a' -> Graphics.set_color Graphics.black;
              let t1 = draw_page `Prev t in repl t1 colour
      | 'b' -> let t1 = draw_bookmark colour t  in repl t1 colour
      | 'h' -> let t1 = draw_highlights colour t in repl t1 colour
      | 'n' -> let t1 = draw_notes colour t in repl t1 colour
      | 'q' -> let t1 = erase_bookmark t in repl t1 colour
      | 'x' -> let t1 = erase_highlights t in repl t1 colour
      | 'e' -> let t1 = erase_notes t in repl t1 colour
      | 'o' -> let t1 = choose_bookshelf () in repl t1 colour
      | 'w' -> let t1 = draw_meaning t in repl t1 colour
      | 's' -> let t1 = search_notes t in repl t1 colour
      | 'z' -> let t1 = display_highlights t in repl t1 colour
      | 'm' -> let t1 = display_notes t in repl t1 colour
      | 'v' -> help (); repl t colour
      | '1' -> repl t Graphics.black
      | '2' -> repl t Graphics.red
      | '3' -> repl t Graphics.blue
      | '4' -> repl t Graphics.yellow
      | '5' -> repl t Graphics.green
      | '6' -> repl t Graphics.magenta
      | 'c' -> close_book t; print_endline " ";
      Pervasives.print_string ("Press 'q' to exit the program" ^
      " or any other key to choose another bookshelf: ");
      let ans = read_line () in
      if ans = "q" then (exit 0)
      else choose_bookshelf ()
      | _ -> print_endline " ";
      print_endline "You pressed an incorrect key. Press again!"; repl t colour


  (* Allows the user to open a book and passes control to the REPL to perform
  further actions *)
  let main () =

    ANSITerminal.print_string [ANSITerminal.yellow]
    "Welcome to OCindle - the e-reader for OCaml!";
    print_endline " ";
    ANSITerminal.print_string [ANSITerminal.yellow] ("You will now be prompted" ^
    " to choose a book from a bookshelf. Instructions follow.");
    let t = choose_bookshelf () in
    repl t Graphics.black;