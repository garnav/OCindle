module DataController = struct


type t = 
    {book_name: string; book_text : string; mutable curr_page : int;
     mutable ind_pos : int; curr_page_cont : string}


let rec custom_print str x y =
    if (String.length str > 0 || x < 540 || y < 650) 
    then
    Graphics.moveto x y;
    Graphics.draw_string (String.sub str 0 83);
    custom_print (String.sub str 83 (String.length str)) x (y - 13);
    else
    ();

let rec custom_highlight t pos_1 pos_2 pos_3 pos_4 =
    if (String
    then

    else
    ();
    (* if before end of page or t is smaller, draw straight line *)
    (* recursively call *)


let open_file name = 

    (* Number of characters: 3735 *)
    (* Window resolution: 540 x 650 *)

    Graphics.open_graph " 540x650";
    Graphics.set_window_title "OCindle";

    (* Display list of bookshelves; choose bookshelf; display list of books;
    choose book; display first/last saved page of book *)

    (* initialize values *)
    let book_details = {book_name = name; book_text = []; 
                        curr_page = []; 
                        ind_pos = []; curr_page_cont = String.sub [] ind_pos (ind_pos + 3735)} in 
    
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

    (* change position to write definition; *)
    Graphics.draw_string word_def
    
let percent_read t =
    ((float_of_int t.ind_pos) /. (float_of_int (String.length t.book_text)))
    (* format string using printf *)

let next_page t =

    (* erase previous content *)
    Graphics.clear_graph ();
    
    (* change curr_page *)
    t.curr_page <- t.curr_page + 1;
    
    (* actually display page and update word counter *)
    try
        t.ind_pos <- t.ind_pos + 3735;
        t.curr_page_cont <- String.sub t.book_text ind_pos (ind_pos + 3735);

        (* position cursor *)
        Graphics.moveto 18 611;

        (* recursive function to draw string *)
        custom_print t.book_text 18 611;

        Marginalia.save_page t;
    with
    | _ -> failwith "Can't go to next page!"
    
let prev_page t =

    (* erase previous content *)
    Graphics.clear_graph ();
    
    (* change curr_page *)
    t.curr_page <- t.curr_page - 1;
    
    (* actually display page and update word counter *)
    try
        t.ind_pos <- t.ind_pos - 3735;
        t.curr_page_cont <- String.sub t.book_text ind_pos (ind_pos + 3735);
        Graphics.moveto 18 611;

        (* recursive function to draw string *)
        custom_print t.book_text 18 611;

        Marginalia.save_page t;
    with
    | _ -> failwith "Can't go to previous page!"
    
let add_notes t = 
    failwith "Unimplemented"
    (* call helper function in perspective to add these notes *)
    (* return page with all lines pertaining to notes underlined:
    capture start and end; highlight *)

let add_bookmark t = 
    (* call function in perspective to add a bookmark to the current page *)
    Graphics.set_color blue;
    Graphics.draw_circle 510 636 10;
    Graphics.set_color black;

let delete_bookmark t = 
    (* call function in perspective to delete a bookmark to the current page *)
    Graphics.set_color white;
    Graphics.draw_circle 510 636 10;
    Graphics.set_color black;

let add_highlights t = 
    (* call function in perspective to add highlights to the current page *)
    let first_pos = wait_next_event [Button_down];;
    let second_pos = wait_next_event [Button_down];;
    custom_highlight t first_pos.mouse_x first_pos.mouse_y second_pos.mouse_x second_pos.mouse_y;


end