module type Perspective = sig

  open Marginalia
  
  (* [t] represents the annotation present over a
  specified range of an entire book. *) 
  type t
	
  (* [create range id range] is [t] for book of [id], over the
  given [range]. The latter is of the form (s,t) where s and t are
  the starting and ending indices, incluseive, respectively.*) 
  val create_range : int -> int * int -> t

  (* [search_notes t1 str] is a list of the notes that contain the
  given string [str] within them within [t1]. Specifically, the result is a list of
  (i, (c, note)) where note is the corrresponding note, i is its index
  position and c is it's colour. No guarantee is given as to the order
  of elements in the list.*)
  val search_notes : t -> string -> (int * (Colours.t * string)) list

  (* [note_by_colour t1] is a list of colours with each corresponding to
  a list of notes. The list of notes are sorted by the index they are at, from
  smallest to largest. The overall list is sorted by colour,
  from least to greatest. The sequence of colours is as
  determined by the Colours module. *)
  val note_by_colour : t -> (Colours.t * (int * string) list) list
  
  (* [note_by_loc t1] is a list of all the notes present in [t1], sorted
  in order of the index they are present at, from smallest to largest.*)
  val note_by_loc : t -> (int * (Colours.t * string)) list
  
  (* [highlight_by_loc t1] is a list of all the highlights present in [t1], sorted
  in order of the index they start at, from smallest to largest.*)
  val highlight_by_loc : t -> (int * (Colours.t * int)) list
  
  (* [highlight_by_colour t1] is a list of colours with each corresponding to
  a list of highlights. The list of notes are sorted by the index they start at,
  from smallest to largest. The overall list is sorted by colour,
  from least to greatest. The sequence of colours is as
  determined by the Colours module. *)
  val highlight_by_colour : t -> (Colours.t * (int * int) list) list

end