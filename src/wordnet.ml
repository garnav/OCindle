(****************************************************************)
(* Module [Wordnet]: Provides an Ocaml interface to WordNet     *)
(* For more info on WordNet refer http://wordnet.princeton.edu/ *)
(*                                                              *)
(* Author: Ramu Ramamurthy ramu_ramamurthy at yahoo dot com     *)
(* (C) 2006                                                     *)
(*                                                              *)
(* This is released under the BSD license                       *)
(****************************************************************)

(**
  This interface is for version 2.1 of WordNet                 
 The environment variable WNSEARCHDIR must be set to point    
 to the WordNet dictionary directory                          
*)

(** get path to wordnet dictionary files *)
let get_dict_path () = 
  try
    Sys.getenv "WNSEARCHDIR"
  with
      Not_found -> ""
;;

if get_dict_path () = "" 
then 
  failwith "Cant find path to WordNet dictionary. \
            Install WordNet and set the WNSEARCHDIR \
            environment variable to point to the \
            WordNet dictionary directory"
            

(**
  {b -------------The following are utilities--------------}
*)


(** obtain a slice of a list from st to en *)
let rec list_slice l st en =
  if (st = en) then [] else (List.nth l st)::(list_slice l (st+1) en)
;;

(** splits a string into a list of strings based on separator char c *)
let split_str str c = 
  let rec split str c lis =
    (
      try 
	let ind = String.index_from str 0 c in
	  if ind = 0 then lis@(split (String.sub str (ind+1) ((String.length str)-ind - 1)) c [])
	  else (
	    lis@[String.sub str 0 ind]@
	      (split (String.sub str (ind+1) ((String.length str)-ind - 1)) c [])
	  )
	with 
	  | Not_found -> if (String.length str) > 0 then lis@[str] else lis
	  | Invalid_argument (x) -> lis
      )
  in
    split str c []

(**
  End of Utils
*)



(**
  {b ----------------The following are types and definitions----------------}
*)

type posType = 
  | NOUN
  | VER
  | ADJ
  | ADV
  | SAT
;;

let all_pos = [NOUN; VER; ADJ; ADV]
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
(** exception *)
exception WN_Not_found
;;

let verb_frames = [
    "";
    "Something ----s";
    "Somebody ----s";
    "It is ----ing";
    "Something is ----ing PP";
    "Something ----s something Adjective/Noun";
    "Something ----s Adjective/Noun";
    "Somebody ----s Adjective";
    "Somebody ----s something";
    "Somebody ----s somebody";
    "Something ----s somebody";
    "Something ----s something";
    "Something ----s to somebody";
    "Somebody ----s on something";
    "Somebody ----s somebody something";
    "Somebody ----s something to somebody";
    "Somebody ----s something from somebody";
    "Somebody ----s somebody with something";
    "Somebody ----s somebody of something";
    "Somebody ----s something on somebody";
    "Somebody ----s somebody PP";
    "Somebody ----s something PP";
    "Somebody ----s PP";
    "Somebody's (body part) ----s";
    "Somebody ----s somebody to INFINITIVE";
    "Somebody ----s somebody INFINITIVE";
    "Somebody ----s that CLAUSE";
    "Somebody ----s to somebody";
    "Somebody ----s to INFINITIVE";
    "Somebody ----s whether INFINITIVE";
    "Somebody ----s somebody into V-ing something";
    "Somebody ----s something with something";
    "Somebody ----s INFINITIVE";
    "Somebody ----s VERB-ing";
    "It ----s that CLAUSE";
    "Something ----s INFINITIVE";
    ""
]
;;

let map_to_pos_str n = 
  match n with 
    | NOUN -> "noun"
    | VER -> "verb"
    | ADJ -> "adj"
    | ADV -> "adv"
    | SAT -> "adj"
;;

let map_to_pos_int n = 
  match n with 
    | NOUN -> 1
    | VER -> 2
    | ADJ -> 3
    | ADV -> 4
    | SAT -> 5
;;

let map_to_pos c = 
  match c with 
    | 'n' -> NOUN
    | 'v' -> VER
    | 'a' -> ADJ
    | 'r' -> ADV
    | 's' -> SAT
    |  _  -> raise WN_Not_found
;;

(* TBD - how or where is this used in WordNet ? *)
(* arm may hurt                                 *)
type adjMarker =
  | PADJ           (* predicative *)
  | NPADJ          (* attributive *)
  | IPADJ          (* immed postnominal *)
;;


(** get the ptr type given the string *)
let getPtrType str = 
  match str with 
    | "!" -> ANTPTR
    | "@" -> HYPERPTR
    | "~" -> HYPOPTR
    | "*" -> ENTAILPTR
    | "&" -> SIMPTR
    | "#m" -> ISMEMBERPTR
    | "#s" -> ISSTUFFPTR
    | "#p" -> ISPARTPTR
    | "%m" -> HASMEMBERPTR
    | "%s" -> HASSTUFFPTR
    | "%p" -> HASPARTPTR
    | "%" -> MERONYM
    | "#" -> HOLONYM
    | ">" -> CAUSETO
    | "<" -> PPLPTR
    | "^" -> SEEALSO
    | "\\" -> PERTPTR
    | "=" -> ATTRIBUTE
    | "$" -> VERBGROUP
    | "+" -> NOMINALIZATIONS
    | ";" -> CLASSIFICATION
    | "-" -> CLASS
    | ";c" -> CLASSIF_CATEGORY
    | ";u" -> CLASSIF_USAGE
    | ";r" -> CLASSIF_REGIONAL
    | "-c" -> CLASS_CATEGORY
    | "-u" -> CLASS_USAGE
    | "-r" -> CLASS_REGIONAL
    | "@i" -> INSTANCE
    | "~i" -> INSTANCES
    | _ -> NONEPTR
;;

(**
  End of types and definitions
*)


(**
 {b --------The following are managing the dictionary files------}
*)

let getDataFile pos = get_dict_path() ^ "/data" ^ "." ^ pos
;;
let getIndexFile pos = get_dict_path() ^ "/index" ^ "." ^ pos
;;
let getSenseFile = get_dict_path() ^ "/index.sense"
;;
let getCntFile = get_dict_path() ^ "/cntlist"
;;
let getCntRevFile = get_dict_path() ^ "/cntlist.rev"
;;
let getExceptionFile pos = get_dict_path() ^ "/" ^ pos ^ ".exc"
;;
let channels = Hashtbl.create 15
;;

let get_channel name = 
  try 
    Hashtbl.find channels name
  with
      Not_found -> (
	try
(*	  let () = Printf.printf "opening file %s\n" name in *)
	  let in_c = open_in name in
	  let () = Hashtbl.add channels name in_c in 
	    in_c
	with
	    x -> Printf.printf "Unable to open file %s\n" name; raise x
      )
;;
	
(**
  End of path and file management
*)

(**
 {b -----------Start of Parsers----------------}
*)

(** parses a string in the index file 
   example shown for a noun index line
   accord n 4 3 @ ~ + 4 0 13785042 07078262 06682659 04657889  

*)
type indexType = {
  it_word: string;
  it_pos: posType;
  it_syns: int list;
  it_ptrs: string list;
  it_tags: int;
}
;;

let parseIndex str = 
  let lis = split_str str ' ' in
  let ptrCnt = int_of_string (List.nth lis 3) in
  let ptrList = list_slice lis 4 (4+ptrCnt) in
  let synList = list_slice lis (6+ptrCnt) (List.length lis) in
  let synIntList = List.map (function s -> int_of_string s) synList in
  let tagCnt = int_of_string (List.nth lis (5+ptrCnt)) in
  let index = {it_word = (List.hd lis);
	       it_pos  = map_to_pos ((List.nth lis 1).[0]);
	       it_syns = synIntList;
	       it_ptrs = ptrList;
	       it_tags = tagCnt;
	      }
  in
    index
;;
(**
  End of parse index
*)


(** parses a string in the data file 
   example shown for a noun data line
09884000 18 n 02 dresser 0 actor's_assistant 0 003 @ 09671165 n 0000 + 00047400 v 0101 + 00045989 v 0101 | a wardrobe assistant for an actor  

*)
type pType = {
  pt_ptr: ptrType;
  pt_syn: int;
  pt_pos: posType;
  pt_src: int;
  pt_tgt: int;
}
;;

type wType = {
  wt_w: string;
  wt_lex_id: int;
}
;;

type frameType = {
  ft_fr: int;
  ft_word: int;
}
;;

type synsetType = {
  sst_off: int;
  sst_lex_file: int;
  sst_sstyp: posType;
  sst_words: wType list;
  sst_ptrs: pType list;
  sst_frames: frameType list;
  sst_gloss: string;
}
;;

let parseWords dataLis start cnt =
  let wList = ref [] in
  let () =
    for i = 0 to cnt-1 do
      let w = {wt_w = (List.nth dataLis (start+2*i));
	       wt_lex_id = (Scanf.sscanf (List.nth dataLis (start+2*i+1)) "%x" (function x -> x));
	      } in
	wList := (List.append !wList [w]);
    done in
    !wList
;;

let parsePtrs dataLis start cnt =
  let pList = ref [] in
  let () =
    for i = 0 to cnt-1 do
      let ptr = { pt_ptr = (getPtrType (List.nth dataLis (start+4*i)));
		  pt_syn = int_of_string (List.nth dataLis (start+4*i+1));
		  pt_pos = map_to_pos ((List.nth dataLis (start+4*i+2)).[0]);
		  pt_src = (	  
		    let str = (List.nth dataLis (start+4*i+3)) in
		      Scanf.sscanf (String.sub str 0 2) "%x" (function x -> x)
		  );
		  pt_tgt = (
		    let str = (List.nth dataLis (start+4*i+3)) in
		      Scanf.sscanf (String.sub str 2 2) "%x" (function x -> x)
		  );
		} in
 	pList := (List.append !pList [ptr]);
    done in
    !pList
;;

let parseFrames dataLis start cnt =
  let fList = ref [] in
  let () =
    for i = 0 to cnt-1 do
      let frame = { ft_fr = int_of_string (List.nth dataLis (start+3*i+1));
		    ft_word = Scanf.sscanf (List.nth dataLis (start+3*i+2)) "%x" (function x -> x);
		  } in
 	fList := (List.append !fList [frame]);
    done in
    !fList
;;

let parseSynset str = 
  let lis = split_str str '|' in
  let dataStr = List.hd lis in
  let dataLis = split_str dataStr ' ' in
  let wStart = 3 in
  let wCnt =  Scanf.sscanf (List.nth dataLis wStart) "%x" (function x -> x) in
  let wList = parseWords dataLis (wStart+1) wCnt in
  let pStart = wStart + 1 + 2*wCnt in
  let pCnt = int_of_string (List.nth dataLis pStart) in
  let pList = parsePtrs dataLis (pStart+1) pCnt in
  let fStart = pStart + 1 + 4 * pCnt in
  let fList = 
    if fStart < (List.length dataLis) then (
      let fCnt = int_of_string (List.nth dataLis fStart) in
	parseFrames dataLis (fStart+1) fCnt ) else
      []
  in
  let data = {
    sst_off = int_of_string (List.hd dataLis );
    sst_lex_file = int_of_string (List.nth dataLis 1);
    sst_sstyp = map_to_pos ((List.nth dataLis 2).[0]);
    sst_words = wList;
    sst_ptrs = pList;
    sst_frames = fList;
    sst_gloss = (List.nth lis 1)
  } in
    data
;;
(**
  End of Parse Data
*)



(**
  Parse the Sense Index Files
  example
  apartment%1:06:00:: 02700857 1 32
*)
type senseKeyType = {
  skt_lemma: string;
  skt_ss_type: int;
  skt_lex_file: int;
  skt_lex_id: int;
  skt_head_word: string;
  skt_head_id: int;
}
;;

type sType = {
  st_key: senseKeyType;
  st_syn: int;
  st_sense_num: int;
  st_tag_cnt: int;
}
;;

let parseSenseKey str = 
  let lis = split_str str '%' in
  let sense_str = (List.nth lis 1) in 
  let sense_lis = split_str sense_str ':' in
  let ss_type = int_of_string (List.nth sense_lis 0) in
  let hd_w = if (ss_type = 5) then (List.nth sense_lis 3) else "" in
  let hd_id = if (ss_type = 5) then int_of_string (List.nth sense_lis 4) else 0 in
  let key = {
    skt_lemma = List.hd lis;
    skt_ss_type = int_of_string (List.nth sense_lis 0);
    skt_lex_file = int_of_string (List.nth sense_lis 1);
    skt_lex_id = int_of_string (List.nth sense_lis 2);
    skt_head_word = hd_w;
    skt_head_id = hd_id;
  }
  in
    key
;;

let parseSense str = 
  let lis = split_str str ' ' in
  let sense = {
    st_key = parseSenseKey (List.hd lis);
    st_syn = int_of_string (List.nth lis 1);
    st_sense_num = int_of_string (List.nth lis 2);
    st_tag_cnt = int_of_string (List.nth lis 3);
  }
  in 
    sense
;;
(**
  End of parse Sense Index
*)


(**
  Parse the countlist files
  Example:
  1268 business%1:14:00:: 1
*)
type countList = {
  cl_key: senseKeyType;
  cl_tag_cnt: int;
  cl_sense_num: int;
}
;;

let parseCount str = 
  let lis = split_str str ' ' in
  let cnt = {
    cl_tag_cnt = int_of_string (List.nth lis 0);
    cl_key = parseSenseKey (List.nth lis 1);
    cl_sense_num = int_of_string (List.nth lis 2);
  }
  in 
    cnt
;;

let parseCountRev str = 
  let lis = split_str str ' ' in
  let cnt = {
    cl_key = parseSenseKey (List.nth lis 0);
    cl_sense_num = int_of_string (List.nth lis 1);
    cl_tag_cnt = int_of_string (List.nth lis 2);
  }
  in 
    cnt
;;
(**
  End of parse count list 
*)

(**
 parse exception list
*)
let parseException str =
  split_str str ' '
;;
(**
  End of Parsers
*)

(**
 {b ---------The following are binary search related---------}
*)


(** binary search for a word in a file from st to en *)
let rec binsearch in_c word st en =
  try
    let mid = st + (en-st)/2 in
    let () = seek_in in_c (mid-1) in
    let () = 
      if (mid != st) then
	let _ = input_line in_c in ()
    in
    let str = input_line in_c in
   (* let () = Printf.printf "%s, %d-%d-%d\n" str st en mid in *)
    let lis = split_str str ' ' in
    let head = (List.hd lis) in 
      if (word = head) then str
      else
	if (en - st)/2 = 0 then raise WN_Not_found 
	else
	  if (word < head) then
	    binsearch in_c word st mid
	  else
	    binsearch in_c word mid en
  with x -> raise WN_Not_found
;;

(** get the index for a given word and pos *)
let getIndex word pos = 
  let in_c = get_channel (getIndexFile (map_to_pos_str pos)) in
  let str = binsearch in_c word 1730 (in_channel_length in_c) in
    parseIndex str
;;

(** get the index for a given word and pos *)
let getSynset pos file_loc = 
  let in_c = get_channel (getDataFile (map_to_pos_str pos)) in
  let () = seek_in in_c file_loc in
  let str = input_line in_c in
    parseSynset str
;;
  
let get_ith_w sense i =
  if i = 0 then "" else
    let w = List.nth sense.sst_words (i-1) in 
      w.wt_w
;;

(** get the exception for this word and pos
    used by the morphology analyzer         *)
let getException word pos = 
  let in_c = get_channel (getExceptionFile (map_to_pos_str pos)) in
    try
      let str = binsearch in_c word 1 (in_channel_length in_c) in
      let lis =	parseException str in
	List.nth lis 1
    with
	x -> ""
;;

(** get the sense count for this sensekey     *)
let get_sense_count sensekey = 
  let in_c = get_channel getCntRevFile in
  let str = binsearch in_c sensekey 1 (in_channel_length in_c) in
  let cnt =	parseCountRev str in
    cnt.cl_tag_cnt
;;

(** get normalized form of string                         *)
let normalize str = 
  let str1 = String.lowercase str in
  let () = 
    while (String.contains str1 ' ') do
      let ind = String.index str1 ' ' in 
	String.set str1 ind '_'
    done
  in
    str1
;;

(**
  {b ------------Begin Module API implementation-------------}
*)

type wordType = indexType
;;

type senseType = synsetType
;;

(**
  {b ------------The following are operations on words------}
*)

(** get a word given the form  and part of speech          *)
let getWord str pos =
  let str1 = normalize str in
    getIndex str1 pos
;;

(** get a word form given word                             *)
let getWordForm w =
  normalize w.it_word
;;

(** get a list of senses for the word                      *)
let getSenses w = 
  List.map (getSynset w.it_pos ) w.it_syns
;; 

(** get a list of all pointers that the word has in all    
    senses that contain it                                 *)
let getWordPtrs w = 
  List.map getPtrType w.it_ptrs
;;

(** get the number of senses of word that have been tagged
    in semantic concordance texts                          *)
let numTagged w =
  w.it_tags
;;

(** get the pos for this word                              *)
let getPos w =
  w.it_pos
;;

(** check if the pos is applicable for the word form       *)
let isDefined str pos = 
  try 
    let _ = getWord str pos in
      true
  with
      x -> false
;;

(** check for equality                                     *)
let isEqualWord w1 w2 = 
  if (w1.it_word = w2.it_word) && (w1.it_pos = w2.it_pos) 
  then true
  else false
;;

(**
  {b --------The following are operations on senses--------}
*)

(** get the gloss (description) for this sense            *)
let getGloss sense = 
  sense.sst_gloss
;;

(** get the pos type for this sense                       *)
let getPosType sense =
  sense.sst_sstyp
;;

(** get the word forms mapping to this sense              *)
let getWordForms sense =
  List.map (function w -> normalize w.wt_w) sense.sst_words
;;

(** get all pointers - each pointer has a pos, and a word
   form to which the pointer applies for lexical         
   relations - For semantic relations the word is ""     *)
let getSensePtrs  sense = 
  let tupler p = (p.pt_ptr, p.pt_pos, (get_ith_w sense p.pt_src)) in
    List.map tupler sense.sst_ptrs
;;

(** get the senses pointed to by the pointer              *)
let getPtrSense ptr sense = 
  let applyFn x = if ptr = x.pt_ptr then [getSynset x.pt_pos x.pt_syn] else [] in
  List.flatten (List.map applyFn sense.sst_ptrs)
;;

(** get the senses pointed to by the pointer for          
    lexical relations for word form                       *)
let getPtrWordSense word ptr sense = 
  let applyFn x = 
    if (ptr = x.pt_ptr) && 
      (* either a semantic relation or a lexical relation *)
       (x.pt_src = 0 || 
	((x.pt_src <> 0) && (word = (get_ith_w sense x.pt_src)))
       )
    then [getSynset x.pt_pos x.pt_syn] 
    else [] 
  in
  List.flatten (List.map applyFn sense.sst_ptrs)
;;

(** gets the lex id for word form in sense    *)
let get_lexid_in_sense word sense = 
  let apply_fn w = 
    if word = w.wt_w then [w.wt_lex_id] else []
  in
    List.hd (List.flatten (List.map apply_fn sense.sst_words))

let get_sense_key word sense =
  if (sense.sst_sstyp = SAT) then
    (let simsenses = getPtrSense SIMPTR sense in
     let sense1 = (List.hd simsenses) in
     let headw = (List.hd sense1.sst_words) in
       Printf.sprintf "%s%%%-1.1d:%-2.2d:%-2.2d:%s:%-2.2d" word
	 (map_to_pos_int sense.sst_sstyp)
	 sense.sst_lex_file (get_lexid_in_sense word sense) 
	 headw.wt_w headw.wt_lex_id
    )
  else
    Printf.sprintf "%s%%%-1.1d:%-2.2d:%-2.2d::" word
      (map_to_pos_int sense.sst_sstyp)
      sense.sst_lex_file (get_lexid_in_sense word sense)	
;;

(** how many times has this sense been tagged in         
    concordance texts                                      *)
let getWordSenseCount w s =
  try
    let sensekey = get_sense_key w s in
      get_sense_count sensekey
  with
      x -> 0
;;

(** check for equality                                     *)
let isEqualSense s1 s2 = 
  if (s1.sst_off = s2.sst_off) && 
    (s1.sst_lex_file = s2.sst_lex_file) &&
    (s1.sst_sstyp = s2.sst_sstyp)
  then true
  else false
;;


(** for verbs, get the example frame for that verb        *)
let getVerbFrames w sense =
  if (getPosType sense) <> VER then raise (WN_Not_found)
  else (
    let apply_fn x = 
      if ((x.ft_word = 0) || (get_ith_w sense x.ft_word) = w)
      then [List.nth verb_frames x.ft_fr]
      else []
    in
      List.flatten (List.map apply_fn sense.sst_frames)
  )
;;

(** print details of the sense                            *)
let printSense sense =
  let wflis = getWordForms sense in
  let concat s1 s2 = s1 ^ "," ^ s2 in
  let str = List.fold_right concat wflis "" in
    Printf.printf "(%s) -- %s\n" str (getGloss sense)
;;

(** print details of the word                              *)
let printWord w = 
  let () = Printf.printf "%s : %s\n" w.it_word (map_to_pos_str w.it_pos) in
  let () = Printf.printf "%d senses, %d tagged\n" (List.length w.it_syns) w.it_tags in
  let () = Printf.printf "Senses:\n" in
  let senses = getSenses w in
  let printsense sense =
    Printf.printf "(%d) - " (getWordSenseCount w.it_word sense); printSense sense
  in
    List.iter printsense senses
;;

(**
  {b ------The following are word morphing functions----}
*)

(** standard morphs from wordnet                          *)
let noun_sufx_map = [("s",""); ("ses","s"); ("xes", "x"); 
		     ("zes","z"); ("ches","ch"); ("shes","sh"); 
		     ("men","man"); ("ies", "y")]
;;
let ver_sufx_map = [("s",""); ("ies","y"); ("es","e"); 
		    ("es",""); ("ed", "e"); ("ed", ""); 
		    ("ing", "e"); ("ing", "")]
;;
let adj_sufx_map = [("er",""); ("est",""); ("er","e"); ("est","e")]
;;

(** does str1 end with str2 - shouldnt this be in the standard lib? *)
let ends_with str1 str2 =
  try
    let len2 = String.length str2 in
    if (str2 = (String.sub str1 ((String.length str1)-len2) len2))
    then true
    else false
  with x -> false
;;

(** replace the end of str with end2 if it ended in end1 *)
let replace_end str end1 end2 =
  if (ends_with str end1) then
    (String.sub str 0 ((String.length str)-(String.length end1)))^end2
  else 
    ""
;;

let check_fixed_morphs str pos map =
  try
    let apply_fn (x,y) = 
      let s = replace_end str x y in
	if (s <> "") && (isDefined s pos) then [s] else []
    in
    let lis = List.flatten (List.map apply_fn map) in
(*    let () = List.iter (Printf.printf "%s,") lis in *)
      List.hd lis
  with x -> ""
;;

(** morphs the word form to its base form                 *)
let morph str pos = 
  let exc = getException str pos in
    if (exc <> "") then exc
    else
      if (pos = ADV) then "" 
      else
	match pos with
	  | NOUN -> check_fixed_morphs str pos noun_sufx_map
	  | ADJ  -> check_fixed_morphs str pos adj_sufx_map
	  | VER  -> check_fixed_morphs str pos ver_sufx_map
	  | _    -> ""
;;


(**
   The following are administrative 
*)
let getVersion () = "0.1"
;;

(**
  {b ------------The following are unit tests-------------}
*)

let skip_lines in_c n = 
  for i = 1 to n do 
    let _ = input_line in_c in ()
  done

(** make sure that we can navigate to all words and all 
senses in wordnet *)
let utWordnetNavigation pos =
  let in_c = open_in (getIndexFile (map_to_pos_str pos)) in
    skip_lines in_c 29;
    try
      while true do
	let str = input_line in_c in
	let w = parseIndex str in
	let word = w.it_word in
	let () = Printf.printf "try %s" word in 
	let w1 = getIndex word pos in
	let _ = getSenses w1 in
	  Printf.printf "+%s OK\n" (getWordForm w1); flush stdout
      done
    with
      | WN_Not_found -> Printf.printf "bug in code\n"
      | End_of_file -> Printf.printf "Successful\n"
;;

(** make sure that we can find all exception words *)
let utMorphs pos =
  let in_c = open_in (getExceptionFile (map_to_pos_str pos)) in
(*    skip_lines in_c 1; *)
    try
      while true do
	let str = input_line in_c in
	let lis = parseException str in
	let () = Printf.printf "try %s -" str in 
	let w = morph (List.hd lis) pos in
	  if w = (List.nth lis 1) then
	    Printf.printf "+%s OK\n" w
          else 
	    failwith "bug in morph"
      done
    with
      | WN_Not_found -> Printf.printf "bug in code\n"
      | End_of_file -> Printf.printf "Successful\n"
;;

(** make sure that we can find all sensekeys *)
let utCntlist () =
  let in_c = open_in getCntRevFile in
    try
      while true do
	let str = input_line in_c in
	let lis = split_str str ' ' in
	let key = List.hd lis in
	let () = Printf.printf "try %s -" key in 
	let cnt = get_sense_count key in
	let cnt_str = parseCountRev str in
	  if cnt = cnt_str.cl_tag_cnt then
	    Printf.printf "+%d OK\n" cnt
          else 
	    failwith "bug in cntlist"
      done
    with
      | WN_Not_found -> Printf.printf "bug in code\n"
      | End_of_file -> Printf.printf "Successful\n"
;;

