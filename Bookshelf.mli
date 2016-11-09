type bookshelf_id = int

type book_id = int

type book_list = string list

type book_data = {id : book_id; title : string; author : string; 
	num_pages : int; current_position : int}

val list_books : bookshelf_id -> book_list

val open_book : book_id -> string

val close_book : book_id -> boolean

val get_num_books : bookshelf_id -> int

val get_book_data : book_id -> book_data