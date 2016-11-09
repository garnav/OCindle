(* [t'] represents either a Question (Q) or
Answer (A)*)
type t' = Q | A
  
(* [post t1 str] is [true] if the
statement [str] is added as a question
or answer [t1] to the database.
[false] otherwise.*)
val post : t' -> string -> bool

(* [post t1 i] is [str], the question or answer
with id [i] in the database. [t1] determines
whether the retrieved [str] is a question
or answer.*)
val get : t' -> int -> string 

(* [delete t1 i] is [true], if the the question or answer
with id [i] is successfully deleted from the database.
[t1] determines whether the retrieved [str] is a question
or answer.*)
val delete : t' -> int -> bool

(* [question_list ()] is the list of question present in the given
database and id's they correspond too.*)
val question_list : unit -> int * string list

====================================
TODO:
How do you recognize what each question is
if its encapsulated
How to post to a specific server/db?
How are we getting answers to related questions

