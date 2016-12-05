(* Controls and stores data about available books *)

(* The type of the text that represents the content of a book *)
type book_text

(* The data contained by an individual book *)
type book_data

val list_bookshelves : string list

(* Lists the books currently on the bookshelf with the given ID *)
val list_books : string -> book_data list

(* Formats a book text to a specified line width *)
(* val format_book_text : book_text -> num_chars_per_line -> book_text *)

(* [get_book_text bs_id b_id chars_per_line] Returns the text of a book with *)
(* book_id b_id on bookshelf with bookshelf_id bs_id and formatted to fit *)
(* line width chars_per_line *)
val get_book_text : string -> int -> int -> book_text

(* [close_book bid position] Closes the book with book id [bid] and saves
current reading position at [position]. Returns true if save was 
successful *)
val close_book : int -> int -> bool
(* DEPRECATED: use save_book_position instead *)

val save_book_position : string -> int -> int -> unit

(* Returns the number of books in the given bookshelf *)
val get_num_books : string -> int

(* Returns the data for a given book *)
val get_book_data : string -> int -> book_data

val get_book_string : book_text -> string

(* Getters for book_data information *)
val get_book_id : book_data -> int
val get_title : book_data -> string
val get_author : book_data -> string
val get_current_position : book_data -> int
val get_total_chars : book_data -> int
