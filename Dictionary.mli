type single_definition = {typ : string; sub_definition : string}

type all_definitions = single_definition list

val get_definition : string -> all_definitions