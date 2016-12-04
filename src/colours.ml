(*module type Colours = sig
   type t
   val compare_colours : t -> t -> int
   val colorify : string -> t
   val decolorify : t -> string		
end *)

module Colours (*: Colours*) = struct

   type t = RED | BLUE | GREEN | YELLOW | PURPLE | BLACK
 
   (*[rank_by_shade c] ranks colours by their brightness.
   Hence, the order is as follows 1. Yellow 2. Red
   3. Purple 4. Blue 5. Green 6. Black. This functions returns,
   the colours position in this sequence.*)
   let rank_by_shade c =
     match c with
	 | RED    -> 2
	 | BLUE   -> 4
	 | GREEN  -> 5
	 | YELLOW -> 1
	 | PURPLE -> 3
	 | BLACK  -> 6
   
   let compare_colours c1 c2 =
     Pervasives.compare (rank_by_shade c1) (rank_by_shade c2)
	 
   let colorify str =
     match str with
	 | "red"    -> RED
	 | "blue"   -> BLUE
	 | "green"  -> GREEN
	 | "yellow" -> YELLOW
	 | "purple" -> PURPLE
	 | "black"  -> BLACK
	 | _        -> raise Not_found

   let decolorify c =
     match c with
	 | RED    -> "red"
	 | BLUE   -> "blue"
	 | GREEN  -> "green" 
	 | YELLOW -> "yellow"
	 | PURPLE -> "purple"
	 | BLACK  -> "black"
	 
end