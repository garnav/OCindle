module UserInterface :
    (* [custom_highlight start_x start_y end_x end_y] underlines all text
      between (start_x, start_y) and (end_x, end_y)*)                                                           sig                                                                               exception Invalid_Colour
    val custom_highlight : int -> int -> int -> int -> unit


    (* [custom_print str start_x start_y] draws string [str] on the Graphics
    window starting from (start_x, start_y), taking into account the margin on
    all sides *)
    val custom_print : string -> int -> int -> unit


    (* [draw_bookmark colour t] puts a bookmark of color [colour] on the current
    page represented by [t] and returns an updated [t] type *)
    val draw_bookmark : int -> t -> t


    (* [erase_bookmark t] erases the bookmark on the current page
    represented by [t] and returns an updated [t] type *)
    val erase_bookmark : t -> t


    (* [draw_notes colour t] puts a note of color [colour] related to a word
     on the current page represented by [t]. The presence of a note is repres
     -ented by a small dot below the letter from where the note starts. This
     function returns an updated [t] type *)
    val draw_notes : int -> t -> t


    (* [erase_notes t] erases a note that exists on the current page
      represented by [t] and returns a new [t] type *)
    val erase_notes : t -> t


    (* [draw_highlights colour t] highlights a string on the page represented by
    [t] with color [colour] and returns an updated [t] type *)
    val draw_highlights : int -> t -> t


    (* [erase_highlights  t] highlights the string on the page represented by
    [t] and returns an updated [t] type *)
    val erase_highlights : t -> t


    (* [display_highlights t] displays all the highlights that exist in the
    current book represented by [t], sorted by color and displayed on a fresh
     page. Returns the last read page after the highlights have been seen *)
    val display_highlights : t -> t


    (* [display_notes t] displays all the notes that exist in the
    current book represneted by [t], sorted by color and displayed on a fresh
    page. Returns the last read page after the notes have been seen *)
    val display_notes : t -> t


    (* [draw_meaning t] draws the meaning of a word highlighted by the user on
    the current page represented by [t] *)
    val draw_meaning : t -> t


    (* [search_notes t] searches the current set of notes with search text
    entered by the user *)
    val search_notes : t -> t


    (* [open_book bookshelf_id book_id] opens the book corresponding to
    bookshelf ID [bookshelf_id] and book ID [book_id] and displays the last read
    page *)
    val open_book : string -> int -> t


    (* [close_book t] closes the current book reprenseted by [t] and allows the
    user to either open another existing book or quit the program *)
    val close_book : t -> unit


  end
