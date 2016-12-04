open Wordnet

module Dictionary = struct

  (* exception - no definition was found for the given string *)
  exception Word_Not_Found
  
  type definition = string
  
  let ptype_to_string = function
    | NOUN -> "noun"
    | VER -> "verb"
    | ADJ -> "adjective"
    | ADV -> "adverb"
    | SAT -> "sat"
  
  let rec sense_list_to_string count ptype = function
    | [] -> ""
    | h::t ->
      "(" ^ ptype_to_string ptype ^ " #" ^ string_of_int count ^ ") " ^ getGloss h ^ " \n " ^ 
        sense_list_to_string (count + 1) ptype t
  
  let get_def_string word ptype =
    try sense_list_to_string 1 ptype (getSenses (getWord word ptype)) with
    | WN_Not_found -> ""

  (* [get_definition word] Returns the definition of [word],
  or raises Word_Not_Found exception if the word was not found *)
  let get_definition word =
    let s = get_def_string word NOUN ^ get_def_string word VER ^ 
      get_def_string word ADJ ^ get_def_string word ADV ^ 
      get_def_string word SAT in
    if s = "" then
      raise Word_Not_Found
    else 
      s
    
end