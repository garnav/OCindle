(* [t'] represents either a Question (Q) or
Answer (A)*)
type t' = Q | A
  
type qa_data
  
(* val get_questions : int -> *)
  
  
(* [post t1 str] is [true] if the
statement [str] is added as a question
or answer [t1] to the database.
[false] otherwise.*)
(* val post : t' -> string -> bool *)

(* [get book_id from to] is a list of the question and answer data *)
(* stored on the database between character positions from and to for book *)
(* with book id book_id *)
val get : int -> int -> int -> string Lwt.t (*qa_data list*)

(* [delete t1 i] is [true], if the the question or answer
with id [i] is successfully deleted from the database.
[t1] determines whether the retrieved [str] is a question
or answer.*)
(* val delete : t' -> int -> bool *)

(* [question_list ()] is the list of question present in the given
database and ids they correspond too.*)
(* val question_list : unit -> int * string list *)


(* Interaction                                                                *)
(* QA (Think of these as dicussion threads?)                                  *)
(* POSSIBLE USES: See answers to often difficult concepts,                    *)
(* have a poll about a certain topic if you're reading a newspaper,           *)
(* on current issues -> ask about certain policies and reference to           *)
(* important sites.                                                           *)
(* Take a list of popular questions (be able upvote them even more)           *)
(* -> refine this by searching for questions                                  *)
(* Be able to answer and ask                                                  *)
(* Delete your own questions or answers                                       *)
(* Only get to see the rest                                                   *)

(* --------------                                                             *)
(* IMPLEMENTATION                                                             *)
(* General DB with tables for different books.                                *)
(* So if you're reading a certain book then you have access to that table.    *)
(* And you can modify that table only.                                        *)


(* Sharing of Notes                                                           *)
(* Public notes aren't as useful as you would think. You can get more insight *)
(* by asking your own questions than by reading some static thing that you've *)
(* read. Seems more like you can also insight better discussion.              *)