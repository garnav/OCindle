(* Controls interactions with the WordNet Dictionary API *)

open Wordnet
  
(* exception - no definition was found for the given string *)
exception Word_Not_Found

let ptype_to_string = function
  | NOUN -> "noun"
  | VER -> "verb"
  | ADJ -> "adjective"
  | ADV -> "adverb"
  | SAT -> "sat"

let rec get_spaces n =
  if n > 0 then
    " " ^ get_spaces (n-1)
  else 
    ""
  
let rec add_padding line_width position str =
  let chars_left = (String.length str) - position in  
  if chars_left <= line_width then
    str ^ (get_spaces (line_width - chars_left))
  else 
    add_padding line_width (position + line_width) str
  
let rec sense_list_to_string count line_width ptype = function
  | [] -> ""
  | h::t ->
    let def_string = "(" ^ ptype_to_string ptype ^ " #" ^ 
      string_of_int count ^ ") " ^ getGloss h in
    let def_string = add_padding line_width 0 def_string in 
    def_string ^ (sense_list_to_string (count + 1) line_width ptype t)
  
let get_def_string word line_width ptype =
  try sense_list_to_string 1 line_width ptype (getSenses (getWord word ptype)) with
  | WN_Not_found -> ""

(* [get_definition word lw] Returns the definition of [word] formatted to line_width lw,
or raises Word_Not_Found exception if the word was not found *)
let get_definition word line_width =
  let lw = line_width in
  let s = get_def_string word lw NOUN ^ get_def_string word lw VER ^ 
    get_def_string word lw ADJ ^ get_def_string word lw ADV ^ 
    get_def_string word lw SAT in
  if s = "" then
    raise Word_Not_Found
  else 
    s
