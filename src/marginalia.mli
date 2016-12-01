module type Marginalia = sig
  
	open Colours

  (* type [t] represents the annotations,
  ie: highlights, notes and bookmark status on a given
  page. *)
  type t
  
  (* type [page] represents the range of indices of a book
	with relevant content. [page] is of the form (s,t),
	ie: the starting (s) and ending (t) indices, inclusive. *)
  type page = int * int

  (* [get_range t1] is the [page] that [t1] contains annotations for.*)
  val get_range : t -> int * int
   
  (* [get_page_overlay book_id range] is [t] for annotations
  present on the page of a book, denoted by it's unique book_id [book_id].
  Annotations beginning within the page are retrieved.
  requires:
  - [range], ie (s,t), where s and t are non-negative
  and are smaller than or equal to the greatest index of the book. t > s*)
  val get_page_overlay : int -> page -> t

  (* [add_note note i c t1] is [t2] with [note] of colour [c]
  added at index [i]. Exception Already_Exists
  is thrown if [t1] already contains a note at i.
  requires:
  - [i] must be within [t1]'s page.*)
  val add_note : string -> int -> Colours.t -> t -> t
  
 (* [delete_note i t1] is [t2] with the note at index [i] removed.
  Exception Not_found is thrown if [t1] does not contain a note
  at i.
  requires:
  - [i] must be within [t1]'s page. *)
  val delete_note : int -> t -> t

  (* [add_highlight i e c t1] is [t2] with a highlight of colour
  [c] added at starting index [i] and ending index [e].
  Exception Already_Exists is thrown if [t1]
  already contains a highlight at i.
  requires:
  - [i] must be within [t1]'s page.
  - [e] must be greater than [i] and smaller than the largest index of the book.*)
  val add_highlight : int -> int -> Colours.t -> t -> t
  
  (* [delete_highlight i t1] is [t2] with the highlight at index [i] removed.
  Exception Not_found is thrown if [t1] does not contain a highlight
  at i.
  requires:
  - [i] must be within [t1]'s page. *)
  val delete_highlight : int -> t -> t

  (* [is_bookmarked t1] is [true] if the page [t1]
  refers to is bookmarked. [false] otherwise. *)
  val is_bookmarked : t -> bool 

  (* [add_bookmark t1 c1] is [t2] with all the properties
  of [t1], only bookmarked with colour [c1]. Exception Already_Exists
  is thrown if the page is already bookmarked.*)
  val add_bookmark : t -> Colours.t -> t
  
  (* [remove_bookmark t1] is [t2] with all the properties
  of [t1], only with it's bookmark removed. Exception Not_found
  is thrown if the page is not bookmarked.*)
  val remove_bookmark : t -> t
	
	(* [notes_list t1] is a list of all the notes
	present on the page that t1 represents. Specifically,
	this returns a list of (s, (c, note)) where s is the index position
	of the note and c is it's colour.*)
	val notes_list : t -> (int * (Colours.t * string)) list
	
	(* [highlights_list t1] is a list of all the highlights
	present on the page that t1 represents. Specifically,
	this returns a list of (s, (c, e)) where s is the starting and
	e is the ending index and c is the colour of the highlight.*)
	val highlights_list : t -> (int * (Colours.t * int)) list
	
	(* [save_page t1] ensures that the page represent by [t1] is
	stored in local memory. *)
	val save_page : t -> unit

end