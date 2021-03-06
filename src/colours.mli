
  
	 (* [t] is the type representing
   conventional colours. These are defined as
   red, blue, green, yellow, purple and black.*)
   type t

   (* [compare c1 c2] is -1 if [c1] is less than [c2],
   0 if [c1] is equal to [c2], or 1 if [c1] is
   greater than [c2]. *)
   val compare_colours : t -> t -> int

   (* [colorify str] is str represented as a colour.
   requires:
   - [str] may only be one of the following
     'red', 'blue', 'green', 'yellow', 'purple', 'black' *)
   val colorify : string -> t

   (* [decolorify c] is colour represented as
   a lowercase string. The returned string are exactly
	 one of the following 'red', 'blue', 'green', 'yellow',
	 'purple', 'black'*)
   val decolorify : t -> string
				
