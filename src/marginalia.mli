  open Colours
	
	(* type [t] represents the annotations,
  ie: highlights, notes and bookmark status of a given
  page. *)
  type t
  
  (* type [page] represents an arbitrary range of indices of a book.
	[page] is of the form (s,t), ie: the starting (s) and
	ending (t) indices, inclusive. *)
  type page = int * int

  (* [get_range t1] is the [page] that [t1] contains annotations for.*)
  val get_range : t -> page
   
  (* [get_page_overlay shelf_id book_id range] is [t] for annotations
  present on the page of a book, denoted by it's unique book_id [book_id]
	within shelf of [shelf_id].
  Annotations beginning within the page are retrieved.
  requires:
  - [range], ie (s,t), where s and t are non-negative. t > s*)
  val get_page_overlay : Bookshelf.bookshelf_id -> Bookshelf.book_id -> page -> t

  (* [add_note i note c t1] is [t2] with [note] of colour [c]
  added at index [i]. Exception Already_Exists
  is thrown if [t1] already contains a note at i.
  requires:
  - [i] must be within [t1]'s page.*)
  val add_note : int -> string -> Colours.t -> t -> t
  
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
  - [e] must be greater than [i]. *)
  val add_highlight : int -> int -> Colours.t -> t -> t
  
  (* [delete_highlight i t1] is [t2] with the highlight at index [i] removed.
  Exception Not_found is thrown if [t1] does not contain a highlight
  at i.
  requires:
  - [i] must be within [t1]'s page. *)
  val delete_highlight : int -> t -> t

  (* [is_bookmarked t1] is [Some c] if the page [t1]
  refers to is bookmarked with colour c. [None] otherwise. *)
  val is_bookmarked : t -> Colours.t option

  (* [add_bookmark t1 c1] is [t2] with all the properties
  of [t1], only bookmarked with colour [c1]. Exception Already_Exists
  is thrown if (is_bookmarked t1) is not None*)
  val add_bookmark : t -> Colours.t -> t
  
  (* [remove_bookmark t1] is [t2] with all the properties
  of [t1], only with it's bookmark removed. Exception Not_found
  is thrown if (is_bookmarked t1) is None*)
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
	
	(* [save_page t1 dir] ensures that the page represent by [t1] is
	stored in local memory, within directory [dir].
	raises Corrupted_Data if not successfully saved.*)
	val save_page : t -> string -> unit
	
	exception Already_Exists
  exception Corrupted_Data
