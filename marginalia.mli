module type Marginalia = sig

  open Colours

  (* [t] is a type representing the annotations,
  ie: highlights, notes and bookmark in/of a given
  page. *)
  type t

  (* [get_page_overlay book it1 t1] is [t] for
  annotations present in [book] between the starting (s)
  and ending index (t), inclusive. [it1] is (s,t) *)
  val get_page_overlay : string -> int * int -> t

  (* [add_note note it1 t1] is [t2] with a note added
  between the starting (s) and ending index (t), inclusive.
  [it1] is (s,t) *)
  val add_note : string -> int * int -> t -> t

  (* [notes t1] is [slst], representing
  the list of all notes and their bounding indices,
  present in the page denoted by [t1] *)
  val notes : t -> (int * int) * string list

  (* [add_highlight it1 c1 t1] is [t2] with a highlight of colour
  c1 added between the starting (s) and ending index (t), inclusive.
  [it1] is (s,t) *)
  val add_highlight : int * int -> Colours.t -> t -> t

  (* [highlights t1 it1] is [hlst], representing
  the list of bounding indices and the colour of highlights 
  for each.*)
  val highlights : t -> (int * int) * Colours.t list

  (* [is_bookmarked t1] is [true] if the page [t1]
  refers to is bookmarked. [false] otherwise. *)
  val is_bookmarked : t -> bool 

  (* [add_bookmark t1 c1] is [t2] with the page [t1]
  bookmarked with colour [c1]. [false] otherwise. *)
  val add_bookmark : t -> Colours.t -> bool

  (* [bookmarks book] returns the list of bookmarks
  associated with the book of title [book]. *)
  val bookmarks : string -> (int * int) * Colours.t list

end