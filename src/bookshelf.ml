(* Controls and stores data about available books *)
  
(* The type of the text that represents the content of a book *)
type book_text = string

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
    
let p = 
  print_endline (string_of_int Pervasives.__LINE__)
    
let get_bookshelves_path =
  let parent_folder = to_sub (Sys.getcwd ()) 0 ((String.rindex (Sys.getcwd ()) '/') + 1) in
  p;
  parent_folder ^ "bookshelves"

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
  let bookshelf_folder = get_bookshelves_path in
  let all_files = Sys.readdir (bookshelf_folder) in
  get_bookshelf_ids bookshelf_folder (Array.to_list all_files)
  
let get_bookshelf_path bookshelf_id =
  get_bookshelves_path ^ Filename.dir_sep ^ bookshelf_id
  
let rec get_spaces n =
  if n > 0 then
    " " ^ get_spaces (n-1)
  else 
    ""
    
let rec remove_multiple_spaces_helper str cur_idx last_char =
  if cur_idx >= String.length str then
    ""
  else
    let cur_char = String.get str cur_idx in
    if last_char = ' ' && cur_char = ' ' then
      remove_multiple_spaces_helper str (cur_idx + 1) cur_char
    else
      Char.escaped cur_char ^ 
        remove_multiple_spaces_helper str (cur_idx + 1) cur_char
        
let remove_multiple_spaces str =
  remove_multiple_spaces_helper str 0 '-'
  
let rec is_only_whitespace_helper str cur_idx len =
  if cur_idx >= len then
    true
  else
    let cur_char = String.get str cur_idx in
    if cur_char <> ' ' && cur_char <> '\t' && cur_char <> '\n' && 
      cur_char <> '\r' && cur_char <> '\012' then
      false
    else 
      is_only_whitespace_helper str (cur_idx + 1) len
      
let is_only_whitespace str =
  is_only_whitespace_helper str 0 (String.length str)

let rec list_to_string line_width = function
  | [] -> ""
  | h:: t ->
      (* let h = String.trim h in *)
      (* Checks for hyphen at end of line - commenting out since proj. *)
      (* gutenberg books don't hyphenate between lines *)
      (* if get_last_char h = "-" then     *)
      (*   let len = String.length h in    *)
      (*   let h = to_sub h 0 (len - 1) in *)
      (*   h ^ (list_to_string t)          *)
      (* else                              *)
      if is_only_whitespace h then
        let h = (get_spaces (line_width - (String.length h))) in
        h ^ (list_to_string line_width t)
      else
        let h = h ^ (get_spaces (line_width - (String.length h))) in
        h ^ (list_to_string line_width t)
  
(* Returns the text of a book given a book id I wrote this function      *)
(* after looking at the following page on Stack Overflow:                *)
(* http://stackoverflow.com/questions/5774934/[...]                      *)
(* [...]how-do-i-read-in-lines-from-a-text-file-in-ocaml                 *)
let get_book_text bookshelf_id book_id line_width : book_text =
  let lines = ref [] in
  let in_chan = Pervasives.open_in (get_bookshelf_path bookshelf_id ^
    Filename.dir_sep ^ (string_of_int book_id) ^ ".txt") in
  try
    while true; do
      lines := Pervasives.input_line in_chan :: !lines
    done;
    list_to_string line_width !lines
  with
  | End_of_file ->
      Pervasives.close_in in_chan;
      list_to_string line_width (List.rev !lines)

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
        | ".json" -> 
          if (not (String.contains h '_')) then
            (get_record_from_json bs_id h):: (get_books bs_id t)
          else get_books bs_id t
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
    ((string_of_int book_id) ^ ".json")) json;
  true
    
(* Getters for book_data, to maintain type abstraction *)
let get_current_position bd = bd.current_position
let get_book_id bd = bd.id
let get_title bd = bd.title
let get_author bd = bd.author
let get_current_position bd = bd.current_position
let get_total_chars bd = bd.total_chars
