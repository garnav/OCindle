(* Controls and stores data about available books *)
module type Bookshelf = sig
  
  (* The unique identifier for a bookshelf *)
  type bookshelf_id
  
  (* The unique identifier for a book *)
  type book_id
  
  (* The type of the text that represents the content of a book *)
  type book_text
  
  (* The data contained by an individual book *)
  type book_data
  
  val list_bookshelves : bookshelf_id list
  
  (* Lists the books currently on the bookshelf with the given ID *)
  val list_books : bookshelf_id -> book_data list
  
  (* Returns the text of a book given a book id *)
  val get_book_text : bookshelf_id -> book_id -> book_text
  
  (* [close_book bid position] Closes the book with book id [bid] and saves
  current reading position at [position]. Returns true if save was 
  successful *)
  val close_book : book_id -> int -> bool
  (* DEPRECATED: use save_book_position instead *)
  
  val save_book_position : bookshelf_id -> book_id -> int -> bool
  
  (* Returns the number of books in the given bookshelf *)
  val get_num_books : bookshelf_id -> int
  
  (* Returns the data for a given book *)
  val get_book_data : bookshelf_id -> book_id -> book_data
  
  (* Getters for book_data information *)
  val get_book_id : book_data -> book_id
  val get_title : book_data -> string
  val get_author : book_data -> string
  val get_current_position : book_data -> int
  val get_total_chars : book_data -> int
  
  val get_bookshelf_name : bookshelf_id -> string
  
end