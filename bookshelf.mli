(* Controls and stores data about available books *)

module Bookshelf = sig
	(* The unique identifier for a bookshelf *)
  type bookshelf_id = int
  
	(* The unique identifier for a book *)
  type book_id = int
  
	(* The string of text that represents the content of a book *)
  type book_text = string
  
	(* The data contained by an individual book *)
  type book_data = {id : book_id; title : string; author : string; 
      current_position : int}
  
	(* Lists the books currently on the bookshelf with the given ID *)
  val list_books : bookshelf_id -> book_list
  
	(* Returns the text of a book *)
  val get_book : book_id -> book_text
  
	(* Closes a book and saves current reading position *)
  val close_book : book_id -> bool
  
	(* Returns the number of books in the given bookshelf *)
  val get_num_books : bookshelf_id -> int
  
	(* Returns the data for a given book *)
  val get_book_data : book_id -> book_data
end