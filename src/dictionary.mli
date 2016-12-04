(* Controls interactions with the WordNet Dictionary API *)
module type Dictionary = sig
	
	(* The type of a definition *)
  type definition

	(* [get_definition word] Returns the definition of [word],
	or raises Word_Not_Found exception if the word was not found *)
	val get_definition : string -> definition
	
end