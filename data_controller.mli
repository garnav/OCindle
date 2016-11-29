module DataController = sig

  (* the type of the data structure that stores relevant information
  about the book including, but not limited to the book name, book text and 
  font color. *)
  type t 

  (* Opens the book with the same name as the string passed to it. Raises
  exception Book_Does_Not_Exist if such a book is not in the current bookshelf. *)
  val open_file: string -> unit

  (* Closes the current book, returning the user to the terminal. *)
  val close_file: t -> unit

  (* Finds the meaning of the given word; raises exception [Word_Not_Found] if 
  word is incorrectly spelt or not in the dictionary *)
  val find_meaning: string -> string

  (* Returns the percentage of the current book read, upto 2 decimal places *)
  val percent_read: t -> float

  (* Turns to the next page of the current book. Raises an exception if this is
  the last page *)
  val next_page: t -> t
  
  (* Turns to the last page of the current book. Raises an exception if this is
  the first page *)
  val prev_page: t -> t

  (* Allows the user to add a bookmark to this page. *)
  val add_bookmark: t -> t
  
  (* Allows the user to delete a bookmark from this page *)
  val delete_bookmark: t -> t

  (* Allows the user to add notes regarding this page *)
  val add_notes: t -> t
  
  (* Allows the user to delete notes regarding this page *)
  val delete_notes: t -> t
  
  (* Allows the user to add highlights regarding this page *)
  val add_highlights: t -> t
  
  (* Allows the user to delete notes regarding this page *)
  val delete_highlights: t -> t
 
end