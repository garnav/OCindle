module DataController = struct

(* [t] is a record containing important information about the book *)
type t = 
    {book_name: string; book_text : string; book_id : int; mutable ind_pos : int; 
    curr_page_cont : string}

(* This is a helper function to find the substring of [str] from index position 
[s] to index position [e] *)
let actual_sub str s e =
String.sub str s (e - s + 1)

(* This is a helper function that prints [str] on the Graphics window starting
from [(x,y)]. *)
let rec custom_print str x y =
    if (String.length str > 83) 
    then
        (Graphics.moveto x y;
        Graphics.draw_string (actual_sub str 0 83);
        custom_print (actual_sub str 83 (String.length str - 1)) 18 (y - 13))
    else
        (Graphics.moveto x y;
        Graphics.draw_string str)

(* This is a helper function that draws a line from [(pos1_x, pos1_y)] to 
[(pos2_x, pos2_y)] on the Graphics window. Used in [add_highlights] and 
[delete_highlights] *)
let rec custom_highlight x1 y1 x2 y2 =
  if (y2 < y1)
    then (moveto x1 y1 ;
         Graphics.lineto 522 y1 ;
         draw_highlight 18 (y1 - 13) x2 y2)
  else
    (moveto x1 y1 ; 
    Graphics.lineto x2 y1)

    (* if before end of page or t is smaller, draw straight line *)

let open_file name = 

    (* Number of characters: 3735 *)
    (* Window resolution: 540 x 650 *)
    (* RAISE AND DEFINE exception *)

    Graphics.open_graph " 540x650";
    Graphics.set_window_title "OCindle";

    (* The user is presented with a list of bookshelves, each containing a list of books. *)
    (* Display list of bookshelves; choose bookshelf; display list of books;
    choose book; display first/last saved page of book *)

    (* initialize values *)
    let book_details = {book_name = name; book_text = []; book_id = []; 
                        ind_pos = []; curr_page_cont = actual_sub [] ind_pos (ind_pos + 3735)} in 
    
    (* actually display page *)
    Graphics.draw_string t.curr_page_cont;

let close_file t =
    (* save data before erasing *)
    Marginalia.save_page t;
    
    (* actually erase text *)
    Graphics.close_graph ();
    
let find_meaning word =
    let word_def = 
    (try
        get_definition word
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

let add_bookmark t = 
    (* call function in perspective to add a bookmark to the current page *)
    Graphics.set_color blue;
    Graphics.fill_circle 510 636 10;
    Graphics.set_color black;

let delete_bookmark t = 
    (* call function in perspective to delete a bookmark to the current page *)
    Graphics.set_color white;
    Graphics.fill_circle 510 636 10;
    Graphics.set_color black;

let add_highlights t = 
    (* call function in perspective to add highlights to the current page *)
    let first_pos = Graphics.wait_next_event [Button_down] in 
    let second_pos = Graphics.wait_next_event [Button_down] in 
    let start_x = first_pos.mouse_x in 
    let start_y = first_pos.mouse_y in 
    let end_x = second_pos.mouse_x in 
    let end_y = second_pos.mouse_y in
    (* change color if needbe *)
    custom_highlight start_x start_y end_x end_y;

let delete_highlights t = 
    (* call function in perspective to delete highlights to the current page *)
    let first_pos = Graphics.wait_next_event [Button_down] in 
    let second_pos = Graphics.wait_next_event [Button_down] in 
    let start_x = first_pos.mouse_x in 
    let start_y = first_pos.mouse_y in 
    let end_x = second_pos.mouse_x in 
    let end_y = second_pos.mouse_y in
    Graphics.set_color white;
    custom_highlight start_x start_y end_x end_y;


end