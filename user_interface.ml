module UserInterface = struct

  open DataController
  open Colours

  exception Invalid_Colour

  type t = DataController.t

  (*Window Constants*)
  let char_height = 13
  let char_width = 6
  let left_edge = 18   (*left edge of first char in any line*)
  let right_edge = 516 (*left edge of final char in any line*)
  let top_edge = 611   (*bottom of chars in the top line*)
  let bot_edge = 26    (*bottom of chars in the last line*)
  let chars_line = 83  (*max divisions in a line. chars are chars_line + 1*)

  let within_y_range y = (y / char_height) * char_height

  let within_x_range x = (x / char_width) * char_width

  let relative_index x y =
    let line_number = (top_edge - y) / 13 in (*0-indexed*)
    let within_line = (x - left_edge) / char_width in
    (line_number * chars_line) + within_line + line_number

  (* Graphics Colours to Colours Module *)
  let color_to_colour c =
    match c with
    | black   -> BLACK
    | red     -> RED
    | blue    -> BLUE
    | yellow  -> YELLOW
    | magenta -> PURPLE
    | green   -> GREEN
    | _       -> raise Invalid_Colour

  (* Highlight Manipulation *)
  let rec custom_highlight x1 y1 x2 y2 =
  if y2 < y1
    then ( Graphics.moveto x1 y1 ;
           Graphics.lineto right_edge y1 ;
           custom_highlight left_edge (y1 - char_height) x2 y2 )
  else ( Graphics.moveto x1 y1 ; Graphics.lineto x2 y1 )

  let draw_highlight colour t1 =
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
       Graphics.set_color colour ;
       custom_highlight start_x start_y end_x end_y ;
       new_t
    with
      | Annotation_Error -> print_string "A highlight already exists" ; t1

  (* Printing *)
  let rec custom_print str x y =
    let print_chars = chars_line + 1 in
    if (String.length str > print_chars)
      then
        (Graphics.moveto x y;
        Graphics.draw_string (String.sub str 0 print_chars);
        custom_print (String.sub str print_chars
                     (String.length str - print_chars))
                     18 (y - char_height))
    else
        (Graphics.moveto x y;
        Graphics.draw_string str)





  (*Testing Purposes*)
  let check a =
    (* call function in perspective to add highlights to the current page *)
    let first_pos = Graphics.wait_next_event [Button_down] in
    let start_x = within_x_range first_pos.mouse_x in
    let start_y = within_y_range first_pos.mouse_y in
    print_int (relative_index start_x start_y) ;


  let command = read_int () in
  match command with
  |   ->
  |   ->
  |   ->

(* trigger input *)

end
