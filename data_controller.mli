(* Controls the flow of data and returns relevant output to the UserInterface
to display *)

module DataController = sig
  (* the type of the data structure that stores relevant information
  about the book such as number of pages, fontsize, current page, etc. *)
  type t 
  
  (* Allows the user to increase or decrease the fontsize *)
  val change_fontsize: t -> t
  (* Allows the user to change the font *)
  val change_font: t -> t
  (* Returns the current page being read *)
  val curr_page: t -> int
  (* Opens the current file *)
  val open_file: string -> t
  (* Closes the current file *)
  val close_file: string -> t 
  (* finds the meaning of the given word *)
  val find_meaning: string -> string
  (* Outputs the percentage of the book read *)
  val percent_read: t -> float
  (* Allows the user to bookmark this page *)
  val bookmark: t -> t
  (* Allows the user to make notes relating to the current page *)
  val make_note: t -> t
end