module type UserInterface = sig

(* this single function in user interface pattern matches a keypress
to call various functions in DataController which perform the required task
and makes it visible to the user.
Graphics.status contains information about mouse clicks and keyboard
presses  *)
val main : Graphics.status -> unit

end