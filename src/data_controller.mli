  exception Annotation_Error
  exception No_Annotation
  exception Page_Undefined of string
  exception Book_Error of string
	
	(* [t] maintains important meta-information about the book
	and the current index range, ie: page, of the book being
	considered. This range is hereby referred to as page.*)
  type t
	
	(*************** PAGE META-INFORMATION ********************************)
	
 (* [page_number t1] returns the page number of the
	* page in the book that t1 corresponds to. *)
	val page_number : t -> int
	
 (* [percent_read t1] returns the ratio of the book's length
  * that the upper limit of t1's page covers.
	* Returns a value between 0.0 and 1.0.
	*  requires
	*  - t1 refers to a book whose length is greater than the
	*    upper limit of t1's page. *)
  val percent_read : t -> float
	
	(*************** PAGE ANNOTATIONS ********************************)
	
	(* [add_highlights b e c t1] is [t] with all the details of [t1] and
	 * details of a highlight of colour c added with start index b and ending index e.
	 * b and e are relative to the start of t1's page. *)
	val add_highlights : int -> int -> Colours.t -> t -> t
	
 (* [delete_highlights i t1] is [t] with all the details of [t1] but
	* details of a highlight starting at index [i], relative to t1's page, removed. *)
  val delete_highlights : int -> t -> t
	
 (* [page_highlights t1] is a list of highlights that start in t1's current
    page range. Specifically each element is of the form (i(c,e)), where i and
		e are the starting and ending indices of the highlight, relative
		to the start of t1's page. c is the colour of the highlight. *)
  val page_highlights : t -> (int * (Colours.t * int)) list
	
 (* [add_notes i note c t1] is [t] with all the details of [t1] and
	* details of a [note] of colour [c] added at index [i].
	* [i] is relative to the start of t1's page. *)
  val add_notes : int -> string -> Colours.t -> t -> t
	
 (* [delete_notes i t1] is [t] with all the details of [t1] but
	* details of a note at index [i], relative to t1's page, removed. *)
  val delete_notes : int -> t -> t
	
 (* [page_notes t1] is a list of notes in t1's current
    page range. Specifically each element is of the form (i(c,note)),
		where i is the index of the note, relative
		to the start of t1's page. c is the colour of the note. *)
  val page_notes : t -> (int * (Colours.t * string)) list
	
 (* [add_bookmarks t1 c] is [t] with all the details of [t1] and
	* a bookmark of colour [c] added for the page t1 represents. *)
  val add_bookmarks : t -> Colours.t -> t
	

  val delete_bookmarks : t -> t

  val page_bookmark : t -> Colours.t option
	
	(*************** PAGE MANIPULATION ********************************)
	
 (* [next_page word_num t1] is [t] with book meta-information
  * of [t1] but details corresponding to a page immediately following
	* t1's page. The lower limit of the new page is at one index higher
	* than the upper limit of t1's page.
	* This new page is of maximum length word_num.
	*	raises Page_Undefined "End of Book" if such a page can't be retrieved.
	*  requires
	*  - word_num is non-negative *)
	val next_page : int -> t -> t
	
 (* [prev_page word_num t1] is [t] with book meta-information
  * of [t1] but details corresponding to a page immediately preceding
	* t1's page. The upper limit of the new page is at one index lower
	* than the lower limit of t1's page.
	* This new page is of length word_num.
	*	raises Page_Undefined "Can't Go Back" if such a page can't be retrieved.
	*  requires:
	*  - word_num is non-negative *)
  val prev_page : int -> t -> t
 
 (* [get_page index t1] is [t] with book meta-information of [t1]
  * but details corresponding to a page containing [index]. Let t1's usual
	* page length be max_num. Then, this page starts at the highest
	*	multiple of word_num lower than index and is of maximum length
	*	word_num.
	* requires:
	* - index is non-negative and smaller than the length of the book
	*   represented by t1.*)
  val get_page : int -> t-> t
	
	(*************** BOOK META-ANNOTATIONS ********************************)
 (* [meta_annotations t] returns the details of annotations present
 in the book t1 refers too.*)
	val meta_annotations : t -> Perspective.t
	
 (* [search term meta_ann] *)
  val search : string -> Perspective.t -> (int * (Colours.t * string)) list
  val sort_highlights_colour :
    t -> Perspective.t -> (Colours.t * (int * string) list) list
  val sort_notes_colour :
    t -> Perspective.t -> int -> (Colours.t * (int * string * string) list) list
		
 (* [return_definition word] returns the definition(s) of the given word.
	*  raises Annotations_Error if no definition exists. *)
	val return_definition : string -> string
	
	(*************** BOOKS AND BOOKSHELVES ********************************)
	
 (* [bookshelf_list unit] returns a list of available bookshelf ids and
  * their corresponding names. *)
  val bookshelf_list : unit -> (Bookshelf.bookshelf_id * string) list
	
 (* [book_list shelf_id] returns a list books available in bookshelf of [shelf_id].
  * Specifically each element in the list is of the form (id, title, author). *)
  val book_list : Bookshelf.bookshelf_id -> (Bookshelf.book_id * string * string) list
	
 (* [init_book page_length shelf_id book_id] is [t] for a book of [book_id] in
  *  bookshelf of [shelf_id]. [t]'s page is of maximum length [page_length]. *)
  val init_book : int -> Bookshelf.bookshelf_id -> Bookshelf.book_id -> t
	
 (* [close_book t1] ensures that data of the current reading session, including
  * the reading position and updated annotations are correctly saved in local memory. *)
  val close_book : t -> unit