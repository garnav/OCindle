# OCindle
We present to you, OCindle, the e-reader for OCaml. OCindle uses a GUI interface that works on the terminal to allow you to read, highlight and bookmark books as well as search through notes and definitions. 

This application was part of the final project for __CS 3110: Data Structures and Functional Programming__ at Cornell University during Fall 2016. 

## Key Features
* Aesthetically formatted pages
* Highlighting
* Bookmarking
* Note-making
* Searching for notes
* Searching for definitions
* Saving all annotations locally
* Displaying page numbers and percentage read
* Display a sorted list of notes and highlights (by color and indices)

## Installation
(Assuming a fresh CS 3110 2016 Virtual Machine)

1. Obtain WordNet-3.0 from `http://wordnet.princeton.edu/obtain` and place it in `src`.
2. Clone this repository onto the machine. Navigate to the cloned repo.
3. `cd OCindle/src`
4. Enter the command `./wordnet.sh` into the terminal. The terminal should ask your permission to install a number of dependencies.
5. Enter the command `source ~/.bash_profile` into the terminal.
6. Enter the command `make` into the terminal and enjoy the OCindle experience!

__Do NOT attempt to manipulate the size of the graphics window.__

## Usage

### Adding New Books
If a user would like to add a new .txt book, they can do so
by placing a .txt file in one of the directories placed in the directory named bookshelves.
The book's name <bookname> must be uniquely named with alphanumeric characters.
Furthermore, a file of the form <bookname>.json must be created based on the examples
available.

### Help
Type _v_ while reading any text to see all the commands available. 

### Commands

#### General Controls
_o_. Opens the current set of bookshelves on the user's folder.

_c_. Closes the current book.

Press any non-control key to return to the most recent page.

#### Page Controls
_d_. Next page.

_a_. Previous page.

#### Changing Colour
_1_. Current color <-- black. 

_2_. Current color <-- red. 

_3_. Current color <-- blue. 

_4_. Current color <-- yellow. 

_5_. Current color <-- green. 

_6_. Current color <-- purple.

#### Adding Annotations
_b_. Bookmarks current page. A bookmark is displayed on the top right corner.

_h_. Highlight the current page. The user will be prompted to select a start and end position on the screen. 

_n_. Makes a note on the current page. The user will be prompted to select a location to tether the note and can write the note itself in the terminal. A note is denoted by a coloured dot at the tethered location. 

_q_. Erases the bookmark on the current page. 

_x_. Erases the selected highlight on the current page. 

_e_. Erases the selected note on the current page. 

#### Searching for Annotations
 _s_. Searches the current set of notes for the given word. After pressing this key, the user will be prompted to enter the search term on the terminal. If found, the corresponding notes will be displayed on a new page. 

 _z_. Displays the set of current highlights with their page numbers sorted by colour and then by indices. The user will be then be prompted to return to the book: pressing '/' returns to the last read page, while entering a valid page will take the user to that page.

 _m_. Displays the set of current notes with their page numbers sorted by colour and then by indices. The user will be then be prompted to return to the book: pressing '/' returns to the last read page, while entering a valid page will take the user to that page.

#### Searching for Definitions
 _w_. Displays the meaning of the word selected by the user. The user will be prompted to highlight a word.
 
 ## Examples
 | Sample Page | Highlights Added |
 | ----------- | ---------------- |
 | <img src="https://github.com/garnav/OCindle/blob/master/images/page.PNG" width="400"> | <img src="https://github.com/garnav/OCindle/blob/master/images/highlights.PNG" width="400"> |
 
 | View All Highlights | Search for Definitions |
 | ------------------- | ---------------------- |
 | <img src="https://github.com/garnav/OCindle/blob/master/images/Sorted_highlights.PNG" width="400"> | <img src="https://github.com/garnav/OCindle/blob/master/images/Dictionary.PNG" width="400"> |
 
 ## Contributors
* Raghav Batra (rb698)
* Arnav Ghosh (ag983)
* Gregory Stepniak (gps43)
