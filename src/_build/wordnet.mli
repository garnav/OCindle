(**
  Module [Wordnet]: Provides an Ocaml interface to WordNet 2.1    
  For more info on WordNet refer http://wordnet.princeton.edu/
  Author: Ramu Ramamurthy ramu_ramamurthy at yahoo dot com     
  (C) 2006                                                     
  This software is released under the BSD license         
*)

(**
 {b --------The following are Types---------- }
*)


(** parts of speech *)
type posType = 
  | NOUN
  | VER
  | ADJ
  | ADV
  | SAT    
;;

(** pointer types *)
type ptrType = 
  | ANTPTR
  | HYPERPTR
  | HYPOPTR
  | ENTAILPTR
  | SIMPTR
  | ISMEMBERPTR
  | ISSTUFFPTR
  | ISPARTPTR
  | HASMEMBERPTR
  | HASSTUFFPTR
  | HASPARTPTR
  | MERONYM
  | HOLONYM
  | CAUSETO
  | PPLPTR
  | SEEALSO
  | PERTPTR
  | ATTRIBUTE
  | VERBGROUP
  | NOMINALIZATIONS
  | CLASSIFICATION
  | CLASS
  | CLASSIF_CATEGORY
  | CLASSIF_USAGE
  | CLASSIF_REGIONAL
  | CLASS_CATEGORY
  | CLASS_USAGE
  | CLASS_REGIONAL
  | INSTANCE
  | INSTANCES
  | NONEPTR
;;

(** exception - not found in the Wordnet database   *)
exception WN_Not_found
;;

(** The word type - refers to a word form and the
    meanings it represents                          *)
type wordType
;;

(** The sense type - refers to a meaning 
    and the word forms it represents                *)
type senseType
;;

(**
 {b --------The following are operations on the wordType---------- }
*)

(** check if the pos is applicable for the word form       *)
val isDefined: string -> posType -> bool

(** get a word given the form  and part of speech   
    @raise WN_Not_found if word form not found             *)
val getWord : string -> posType -> wordType

(** get a wordform given the word                          *)
val getWordForm : wordType -> string

(** get a list of senses for the word                      *)
val getSenses : wordType -> senseType list

(** get a list of all pointers that the word has in all    
    senses that contain it                                 *)
val getWordPtrs : wordType -> ptrType list

(** get the number of senses of word that have been tagged 
    in semantic concordance texts                          *)
val numTagged: wordType -> int

(** get the pos for this word                              *)
val getPos: wordType -> posType

(** compare two words for equality                         *)
val isEqualWord: wordType -> wordType -> bool

(** print details of the word                              *)
val printWord: wordType -> unit

(**
 {b --------The following are operations on the senseType---------- }
*)

(** get the gloss (description) for this sense            *)
val getGloss: senseType -> string

(** get the pos type for this sense                       *)
val getPosType: senseType -> posType

(** get the word forms mapping to this sense              *)
val getWordForms: senseType -> string list

(** get all pointers - each pointer has a pos, and a word
    form for that sense to which the pointer applies      
    For semantic relations, the word is ""                *)
val getSensePtrs:  senseType -> (ptrType * posType * string) list

(** get the senses pointed to by the pointer              *)
val getPtrSense: ptrType -> senseType -> senseType list

(** get the senses pointed to by the pointer for          
    lexical relations for word form                       *)
val getPtrWordSense: string -> ptrType -> senseType -> senseType list

(** how many times has this sense for the word 
    been tagged in concordance texts                      *)
val getWordSenseCount: string -> senseType -> int

(** for verbs, given word and sense, get example frames   *)
val getVerbFrames: string -> senseType -> string list

(** compare two senses for equality                       *)
val isEqualSense: senseType -> senseType -> bool

(** print details of the sense                            *)
val printSense: senseType -> unit


(**
 {b --------The following are word morphology functions---------- }
*)

(** morphs the word form to its base form                *)
val morph: string -> posType -> string 


(**
 {b --------The following are utilities------------ }
*)

(** get the version of this api                          *)
val getVersion: unit -> string




(*********************************************************) 
(*  End of core API                                      *)
(*********************************************************)

(*********************************************************) 
(*  Unit tests                                           *)
(*********************************************************)
(************
val utWordnetNavigation: posType -> unit
val utMorphs: posType -> unit
val utCntlist: unit -> unit
val normalize: string -> string
************)
