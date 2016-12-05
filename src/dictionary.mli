(* Controls interactions with the WordNet Dictionary API *)

(* exception - no definition was found for the given string *)
exception Word_Not_Found

(* [get_definition word chars_per_line] Returns the definition of [word]
and formats the returned definition to fit line width chars_per_line,
or raises Word_Not_Found exception if the word was not found *)
val get_definition : string -> int -> string
  