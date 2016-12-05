(* Controls interactions with the WordNet Dictionary API *)
	
(* The type of a definition *)
type definition

(* [get_definition word chars_per_line] Returns the definition of [word]
and formats the returned definition to fit line width chars_per_line,
or raises Word_Not_Found exception if the word was not found *)
val get_definition : string -> int -> definition
  