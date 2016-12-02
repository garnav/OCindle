module type UserInterface = sig
    open DataController

  (* the type of the data structure that stores relevant information
  about the book including, but not limited to the book ID, book text and 
  page content. *)
  type t 

  (* Opens the book with the same name as the string passed to it. Raises
  exception Book_Does_Not_Exist if such a book is not in the current bookshelf. *)
  val open_book: string -> unit

  (* Closes the current book, returning the user to the terminal. *)
  val close_book: t -> unit

  (* Displays the meaning of the given word; raises exception [Word_Not_Found] if 
  word is incorrectly spelt or not in the dictionary. *)
  val draw_meaning: string -> t -> word

  (* Draws the content of the current page. *)
  val draw_page: t -> unit
  
  (* Allows the user to add and draw a bookmark to this page. Raises 
  [Annotation_Error] if bookmark is already present there. *)
  val draw_bookmark: Graphics.color -> t -> t
  
  (* Allows the user to delete a bookmark from this page. Raises 
  [Annotation_Error] if no bookmark is present. *)
  val erase_bookmark: t -> t

  (* Allows the user to add notes regarding some text on the page. Raises 
  [Annotation_Error] if note is already present there. *)
  val draw_notes: Graphics.color -> t -> t
  
  (* Allows the user to delete notes regarding this page. Raises 
  [Annotation_Error] if no note is present.*)
  val erase_notes: t -> t
  
  (* Allows the user to add and draw highlights regarding text on this page. 
  Raises [Annotation_Error] if higlight is already present there. *)
  val draw_highlights: Graphics.color -> t -> t
  
  (* Allows the user to delete notes regarding this page. Raises 
  [Annotation_Error] if no highligh is present. *)
  val erase_highlights: t -> t
 
end

end