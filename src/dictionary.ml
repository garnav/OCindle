(* open Wordnet *) (* Will uncomment later *)

module Dictionary = struct

  (* exception - no definition was found for the given string *)
  exception Word_Not_Found
  
  type definition = string

  (* [get_definition word] Returns the definition of [word],
  or raises Word_Not_Found exception if the word was not found *)
  let get_definition word =
    "placeholder definition for: " ^ word
     (* Wordnet.getWord "chair" Wordnet.NOUN *)
    
end