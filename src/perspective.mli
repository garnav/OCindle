module type Perspective = sig

  open Marginalia
  
  (* [t] represents the annotations present over a
  specified range of an entire book. *) 
  type t
	
  (* [create range shelf_id id range] is [t] for book of [id] in
	bookshelf of [shelf_id], over the given [range].
	The latter is of the form (s,t) where s and t are
  the starting and ending indices, inclusive, respectively.*) 
  val create_range : string -> int -> int * int -> t

  (* [search_notes t1 str] is a list of the notes that contain the
  given string [str] within them within [t1]. Specifically, the result is a list of
  (i, (c, note)) where note is the corrresponding note, i is its index
  position and c is it's colour. No guarantee is given as to the order
  of elements in the list.*)
  val search_notes : t -> string -> (int * (Colours.t * string)) list

  (* [note_by_colour t1] is a list of colours, each corresponding to a
	list that details notes of this colour within t1's range. Specifically, this second
	list has elements of the form (i, note) where i is the index of [note].
	The list of notes is sorted by the index they are at, from
  smallest to largest. The overall list is sorted by colour,
  from least to greatest. The sequence of colours is as
  determined by the Colours module. *)
  val note_by_colour : t -> (Colours.t * (int * string) list) list
  
  (* [highlight_by_colour t1] is a list of colours, each corresponding to a
	list that details highlights of this colour within t1's range.
	Specifically, this second list has elements of the form (b, e)
	where b is the starting and e is the ending index of the highlight.
	The list of highlights are sorted by the index they start at,
  from smallest to largest. The overall list is sorted by colour,
  from least to greatest. The sequence of colours is as
  determined by the Colours module. *)
  val highlight_by_colour : t -> (Colours.t * (int * int) list) list

end