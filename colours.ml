module Colours = struct

   type t = RED | BLUE | GREEN | YELLOW | PURPLE | PINK | BLACK

   let compare_colours c1 c2 t =
     failwith "Unimplemented"

   let colorify str =
     match str with
	 | "red"    -> RED
	 | "blue"   -> BLUE
	 | "green"  -> GREEN
	 | "yellow" -> YELLOW
	 | "purple" -> PURPLE
	 | "pink"   -> PINK
	 | "black"  -> BLACK

   let decolorify c =
     match c with
	 | RED    -> "redcd "
	 | BLUE   -> "blue"
	 | GREEN  -> "green" 
	 | YELLOW -> "yellow"
	 | PURPLE -> "purple"
	 | PINK   -> "pink"
	 | BLACK  -> "black

end