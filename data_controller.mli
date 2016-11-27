module DataController = sig

  (* the type of the data structure that stores relevant information
  about the book such as the book name, number of pages, current page, book text, font size, etc. *)
  type t 

  (* Opens the current file *)
  val open_file: string -> unit

  (* Closes the current file *)
  val close_file: t -> unit

  (* Change font color *)
  val change_font_color: ANSITerminal.color -> t -> unit

  (* Returns the current page being read *)
  val curr_page: t -> int

  (* finds the meaning of the given word *)
  val find_meaning: string -> string

  (* Outputs the percentage of the book read *)
  val percent_read: t -> float

  (* Turn to next page *)
  val next_page: t -> t
  
  (* Turn to previous page *)
  val prev_page: t -> t

  (* Allows the user to add a bookmark to this page *)
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