open Marginalia
open QA

(* [t] represents a type of multiple pages. *)
type t 

(* [update_page_range it1 i] is [t] with the page represented by
[it1] present along with i consecutive pages.*)
val update_page_range : int * int -> int -> t

val page_annotations : t -> [> H of ]

val skim : t -> 

(* [flash_card str] is a list of strings, present as annotations,
relevant to the given term [str] and the indices at which these strings
begin and end. *)
val flash_card : string -> (int * int) * string list

(* [search_notes str] is a list of the beginning
and ending of notes that contain the term [str].*)
val search_notes : string -> int * int list

(* [question qa str] is the id of the corresponding
question or answer [str] stored in the QA database.
[qa] represents the type of the statement being added
of type QA.t' *)
val question : QA.t' -> string -> int