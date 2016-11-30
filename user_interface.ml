module UserInterface = struct

  open DataController
  open Colours

  exception Invalid_Colour

  type t = DataController.t

  (* Window Constants *)
  let char_height = 13
  let char_width = 6
  let left_edge = 18   (* left edge of first char in any line *)
  let right_edge = 516 (* left edge of final char in any line *)
  let top_edge = 611   (* bottom of chars in the top line *)
  let bot_edge = 26    (* bottom of chars in the last line *)
  let chars_line = 83  (* max divisions in a line. chars are chars_line + 1 *)
  let max_char = 3780 (* maximum number of characters on a page *)
  let window_size = " 540x650"
  let window_title = "OCindle - no, it's not the Kindle"

  let within_y_range y = (y / char_height) * char_height

  let within_x_range x = (x / char_width) * char_width

  let relative_index x y =
    let line_number = (top_edge - y) / 13 in (*0-indexed*)
    let within_line = (x - left_edge) / char_width in
    (line_number * chars_line) + within_line + line_number

  (* Graphics Colours to Colours module *)
  let color_to_colour c =
    if c = Graphics.black then BLACK
    else if c = Graphics.red then RED
    else if c = Graphics.blue then BLUE
    else if c = Graphics.yellow then YELLOW
    else if c = Graphics.magenta then PURPLE
    else if c = Graphics.green then GREEN
    else raise Invalid_Colour

      (* Printing *)
  let rec custom_print str x y =
    Graphics.set_color Graphics.black ;
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


  (* Initialization *)
  let open_file name =

    (* RAISE AND DEFINE exception *)

    Graphics.open_graph window_size;
    Graphics.set_window_title window_title;

    let page_contents = [get_book_data name] in 
    ;

    (* The user is presented with a list of bookshelves, each containing a list of books. *)
    (* Display list of bookshelves; choose bookshelf; display list of books;
    choose book; display first/last saved page of book *)

    (* initialize values *)


  let rec custom_highlight x1 y1 x2 y2 =
  if y2 < y1
    then ( Graphics.moveto x1 y1 ;
           Graphics.lineto right_edge y1 ;
           custom_highlight left_edge (y1 - char_height) x2 y2 )
  else ( Graphics.moveto x1 y1 ; Graphics.lineto x2 y1 )

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
      | Annotation_Error -> print_string "A highlight already exists" ; t1

  (*NOTE: Technically only needs the start index to begin. Uses, the second
  index to understand what line to draw too.*)

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
      | Annotation_Error -> print_string "No highlight starts at this position." ; t

  let draw_notes color t1 =
    (* call helper function in perspective to add these notes *)
    let first_pos = Graphics.wait_next_event [Button_down] in
    (* try/with, prompt with nice message *)
    let note_text = read_line ();
    let start_x = within_range first_pos.mouse_x in
    let start_y = within_range first_pos.mouse_y - 5 in
    try
      let new_t = DataController.add_notes
                   (relative_index start_x start_y)
                   note_text
                   (color_to_colour colour) t1 in
       Graphics.set_color colour;
       Graphics.fill_circle start_x start_y 2;
       new_t
    with
      | Annotation_Error -> print_string "A note already exists" ; t1

  let erase_notes t1 =
    (* call helper function in perspective to add these notes *)
    let first_pos = Graphics.wait_next_event [Button_down] in
    let start_x = within_range first_pos.mouse_x in
    let start_y = within_range first_pos.mouse_y - 5 in
    try
      let new_t = DataController.delete_notes
                   (relative_index start_x start_y)
                   t1 in
       Graphics.set_color colour;
       Graphics.set_color white;
       Graphics.fill_circle start_x start_y 2;
       new_t
    with
      | Annotation_Error -> print_string "A note doesn't exist" ; t1

  let draw_bookmark colour t1 =
    try
       let new_t = DataController.add_bookmark
                   (relative_index start_x start_y)
                   (relative_index end_x end_y)
                   (color_to_colour colour) t1 in
       Graphics.set_color colour;
       Graphics.fill_circle 510 636 10;
       Graphics.set_color black; (* original color *)
       new_t
    with
      | Annotation_Error -> print_string "A bookmark already exists" ; 

  let erase_bookmark t1 =
    try
       let new_t = DataController.delete_bookmark
                   (relative_index start_x start_y) t1 in
      Graphics.set_color white;
      Graphics.fill_circle 510 636 10;
      Graphics.set_color black; (* original color *)
       new_t
    with
      | Annotation_Error -> print_string "A bookmark doesn't exist" ; t1

  let draw_meaning word t =
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
    

  (* Testing Purposes *)
  let check a =
    (* call function in perspective to add highlights to the current page *)
    let first_pos = Graphics.wait_next_event [Button_down] in
    let start_x = within_x_range first_pos.mouse_x in
    let start_y = within_y_range first_pos.mouse_y in
    print_int (relative_index start_x start_y) ;


  let draw_page which color t =
  try
      (* match mouse click with buttons *)
      let new_t = 
      match which with 
      | `Prev -> DataController.prev_page max_char t
      | `Next -> DataController.next_page max_char t
      | `Curr -> t in
      Graphics.clear_graph ();
      custom_print t.page_content left_edge top_edge; 
  with
  | Page_Undefined -> print_string "Can't draw page";


(*LIST OF POSSIBLE COMMANDS:
(DOES IT DEPEND ON STATE THOUGH)
'w' : next page in a book
's' : previous page in a book
'a' : intention to add something
      FOLLOWED BY - 'b' : book mark
                    'h' : highlight
                    'n' : note
'd' : intention to delete something
      FOLLOWED BY - 'b' : book mark
                    'h' : highlight
                    'n' : note
'b' : go to list of bookshelfs


*)

(*
  let command = read_int () in
  match command with
  |   ->
  |   ->
  |   ->*)

(* trigger input *)

(**)

end


