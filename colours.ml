module Colours = struct

   type t = RED | BLUE | GREEN | YELLOW | PURPLE | PINK | BLACK
 
   (*[rank_by_shade c] ranks colours by their brightness.
   Hence, the order is as follows 1. Yellow 2. Pink 3. Red
   4. Purple 5. Blue 6. Green 7. Black. This functions returns,
   the colours position in this sequence.*)
   let rank_by_shade c =
     match c with
	 | RED    -> 3
	 | BLUE   -> 5
	 | GREEN  -> 6
	 | YELLOW -> 1
	 | PURPLE -> 4
	 | PINK   -> 2
	 | BLACK  -> 7
   
   let compare_colours c1 c2 =
     Pervasives.compare (rank_by_shade c1) (rank_by_shade c2)
	 
   let colorify str =
     match str with
	 | "red"    -> RED
	 | "blue"   -> BLUE
	 | "green"  -> GREEN
	 | "yellow" -> YELLOW
	 | "purple" -> PURPLE
	 | "pink"   -> PINK
	 | "black"  -> BLACK
	 | _        -> raise Not_found

   let decolorify c =
     match c with
	 | RED    -> "red"
	 | BLUE   -> "blue"
	 | GREEN  -> "green" 
	 | YELLOW -> "yellow"
	 | PURPLE -> "purple"
	 | PINK   -> "pink"
	 | BLACK  -> "black"

end