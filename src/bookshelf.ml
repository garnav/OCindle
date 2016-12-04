(* Controls and stores data about available books *)
module Bookshelf = struct
  
  (* The type of the text that represents the content of a book *)
  type book_text = string
  
  (* The unique identifier for a bookshelf *)
  type bookshelf_id = string
  
  (* The unique identifier for a book *)
  type book_id = int
  
  (* The data contained by an individual book *)
  type book_data = { id : book_id; title : string; author : string;
    current_position : int; total_chars : int }
  
  (* Convenience functions, to make long functions names more compact and  *)
  (* readable.                                                             *)
  let member = Yojson.Basic.Util.member
  let to_list = Yojson.Basic.Util.to_list
  let to_string = Yojson.Basic.Util.to_string
  let to_int = Yojson.Basic.Util.to_int
  let to_lc = String.lowercase_ascii
  
  let to_sub str start end' =
    String.sub str start (end' - start)
  
  let string_after str after_pos =
    let len = String.length str in
    String.sub str after_pos (len - after_pos)
  
  let get_last_char str =
    if String.length str <= 1 then str
    else
      let len = String.length str in
      string_after str (len - 1)
  
  let rec get_bookshelf_ids bookshelf_folder = function
    | [] -> []
    | h:: t ->
        try
          let path = bookshelf_folder ^ Filename.dir_sep ^ h in
          if Sys.is_directory (path) &&
            ((to_sub h 0 1) <> "." && (to_sub h 0 1) <> "_") then
            h:: (get_bookshelf_ids bookshelf_folder t)
          else 
            get_bookshelf_ids bookshelf_folder t
        with
        | Sys_error e -> failwith ("Bookshelf not found: " ^ e) 
  
  let list_bookshelves =
    let parent_folder = to_sub (Sys.getcwd ()) 0 ((String.rindex (Sys.getcwd ()) '/') + 1) in
    let bookshelf_folder = parent_folder ^ "bookshelves" in
    let all_files = Sys.readdir (bookshelf_folder) in
    get_bookshelf_ids bookshelf_folder (Array.to_list all_files)
    
  let get_bookshelf_path bookshelf_id =
    (Sys.getcwd ()) ^ Filename.dir_sep ^ bookshelf_id
  
  let rec list_to_string = function
    | [] -> ""
    | h:: t ->
        let h = String.trim h in
        (* Checks for hyphen at end of line - commenting out since proj. *)
        (* gutenberg books don't hyphenate between lines *)
        (* if get_last_char h = "-" then     *)
        (*   let len = String.length h in    *)
        (*   let h = to_sub h 0 (len - 1) in *)
        (*   h ^ (list_to_string t)          *)
        (* else                              *)
        h ^ " " ^ (list_to_string t)
  
  (* Returns the text of a book given a book id I wrote this function      *)
  (* after looking at the following page on Stack Overflow:                *)
  (* http://stackoverflow.com/questions/5774934/[...]                      *)
  (* [...]how-do-i-read-in-lines-from-a-text-file-in-ocaml                 *)
  let get_book_text bookshelf_id book_id : book_text =
    let lines = ref [] in
    let in_chan = Pervasives.open_in (bookshelf_id ^
      Filename.dir_sep ^ (string_of_int book_id) ^ ".txt") in
    try
      while true; do
        lines := Pervasives.input_line in_chan :: !lines
      done;
      list_to_string !lines
    with
    | End_of_file ->
        Pervasives.close_in in_chan;
        list_to_string (List.rev !lines)
  
  let get_record_from_json bs_id f =
    let j = Yojson.Basic.from_file ((get_bookshelf_path bs_id) ^ Filename.dir_sep ^ f) in
    let id = (to_int (member "id" j)) in
    { title = (to_string (member "title" j));
      author = (to_string (member "author" j)); id = id;
      current_position = (to_int (member "current_position" j));
      total_chars = (to_int (member "total_chars" j)) }
  
  let rec get_books bs_id = function
    | [] -> []
    | h:: t ->
        let last_dot_pos = String.rindex h '.' in
        let extension = string_after h last_dot_pos in
        (match extension with
          | ".json" -> (get_record_from_json bs_id h):: (get_books bs_id t)
          | _ -> get_books bs_id t
        )
  
  (* Lists the books currently on the bookshelf with the given ID *)
  let list_books bookshelf_id =
    let all_files = Sys.readdir (get_bookshelf_path bookshelf_id) in
    get_books bookshelf_id (Array.to_list all_files)
  
  (* Deprecated: use save_book_position instead. *)
  let close_book book_id cur_pos =
    failwith "Deprecated"
  
  (* Returns the number of books in the given bookshelf *)
  let get_num_books bookshelf_id =
    let books = list_books bookshelf_id in
    List.length books
  
  (* Returns the data for a given book *)
  let get_book_data bookshelf_id book_id =
    let j = Yojson.Basic.from_file ((get_bookshelf_path bookshelf_id) ^ Filename.dir_sep ^
          ((string_of_int book_id) ^ ".json")) in
    let title = to_lc (to_string (member "title" j)) in
    let author = to_lc (to_string (member "author" j)) in
    let current_position = (to_int (member "current_position" j)) in
    let total_chars = (to_int (member "total_chars" j)) in
    { title = title; author = author; current_position = current_position;
      total_chars = total_chars; id = book_id }
      
  (* [save_book_position bid position] Closes the book with book id [bid]  *)
  (* and saves current reading position at [position]. Returns true if     *)
  (* save was successful                                                   *)
  let save_book_position bookshelf_id book_id cur_pos =
    let d = get_book_data bookshelf_id book_id in
    (* let book_data = {book_data with current_position = cur_pos} in *)
    let json = `Assoc [ ("title", `String d.title); ("author", `String d.author);
      ("current_position", `Int cur_pos); ("total_chars", `Int d.total_chars);
      ("id", `Int d.id) ] in
    Yojson.Basic.to_file ((get_bookshelf_path bookshelf_id) ^ Filename.dir_sep ^
      ((string_of_int book_id) ^ ".json")) json
      
  let get_bookshelf_name bookshelf_id =
    bookshelf_id
	
  let get_current_position bd = bd.current_position
  let get_book_id bd = bd.id
  let get_title bd = bd.title
  let get_total_chars bd = bd.total_chars
  
  
end