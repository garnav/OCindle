module DataController = struct

type t = 
    {book_name: string; mutable num_pages: int; mutable curr_page: int; book_text = string; mutable font_color : ANSITerminal.color; mutable word_pos : int}

let open_file name = 
    (* initialize values *)
    let book_data = Bookshelf.get_book_data [name] in 
    let book_details = {book_name = name; book_text = book_data.text; curr_page = 0; num_pages = [pages]; font_color = Black; word_pos = 0}
    
    (* actually display page *)
    print_string (sub x word_pos word_pos + 300);

let close_file t =
    (* save data before erasing *)
    Marginalia.save_page t;
    
    (* actually erase text *)
    ANSITerminal.erase Above;
    
let change_font_color color t =
    t.font_color <- color

let find_meaning word = 
    get_definition word
    
let curr_page t =
    t.curr_page

let percent_read t =
    (t.curr_page/t.num_pages)

let next_page t =

    (* erase previous content *)
    ANSITerminal.erase Above;
    
    (* change curr_pos *)
    t.curr_pos <- t.curr_pos + 1;
    
    (* actually display page and update word counter *)
    print_string (sub x word_pos word_pos + 300);
    word_pos <- word_pos + 300;
    
let prev_page t =

    (* erase previous content *)
    ANSITerminal.erase Above;
    
    (* change curr_pos *)
    t.curr_pos <- t.curr_pos - 1;
    
    (* actually display page and update word counter *)
    print_string (sub x word_pos word_pos + 300);
    word_pos <- word_pos - 300;
    
let notes_page t = 
    failwith "Unimplemented"
    (* call helper function in perspective to bookmark current page *)
    (* return page with bookmark? *)

let bookmark_page t = 
    failwith "Unimplemented"
    (* call helper function in perspective to bookmark current page *)
    (* return page with bookmark? *)
    
let notes_page t = 
    failwith "Unimplemented"
    (* find subset of page to add notes to *)
    (* call helper function in perspective to add these notes *)
    (* return page with some way to convey notes have been added? *)

end