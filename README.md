## Overview:
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

1. Clone this repository onto the machine. Navigate to the cloned repo.
2. `cd OCindle/src`
3. Enter the command `./wordnet.sh` into the terminal.
   a. The terminal should ask your permission to install a number of dependencies.
      Hit Enter when it does so.
4. Enter the command `source ~/.bash_profile` into the terminal.
5. Enter the command `make` into the terminal and enjoy the OCindle experience!

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

 * d. Goes to the next page.
 * a. Goes to the previous page. 
 * b. Bookmarks the current page. A bookmark is displayed on the top right corner 
 * h. Highlight the current page. After pressing this key, the user will be prompted to select a start and end position on the screen respectively. The highlight is made in the current color 
 * n. Makes a note on the current page. After pressing this key,the user will be prompted to select the letter corresponding to the note.The user will then be prompted on the terminal to write the note.The presence of a note is signified by a dot below the letter the notewas made. 
 * q. Erases the bookmark on the current page. 
 * x. Erases the selected highlight on the current page. 
 * e. Erases the selected note on the current page. 
 * o. Opens the current set of bookshelves on the user's folder.The user is then prompted to select one, then choose and open a book inside it. The book is opened to the last saved position 
 * w. Displays the meaning of the word selected by the user. After pressing this key, the user will be prompted to highlight a word, as is done for highlighting. If the word meaning exists, it is displayed on a new page. The user should press any key besides the ones mentioned in this section to exit the definition page and return to the last read page 
 * s. Searches the current set of notes for the given word. After pressing this key, the user will be prompted to enter the search term on the terminal. The word is then searched, and if found, displayed on a new page. The user should press any key besides the ones mentioned in this section to exit the definition page and return to the last read page 
 * z. Displays the set of current highlights with their page numbers sorted by colour and then by indices. The user will be then be prompted to return to the book: pressing '/' returns to the last read page, while entering a valid page will take the user to that page
 * m. Displays the set of current notes with their page numbers sorted by colour and then by indices. The user will be then be prompted to return to the book: pressing '/' returns to the last read page, while entering a valid page will take the user to that page
 * c. Closes the current book. The user will then b
 * e. prompted to press 'q' to quit the program or 'o' to open another book
 * 1. Change the current color to black. 
 * 2. Change the current color to red. 
 * 3. Change the current color to blue. 
 * 4. Change the current color to yellow. 
 * 5. Change the current color to green. 
 * 6. Change the current color to purple. 
 
 ## Contributors
* Raghav Batra (rb698)
* Arnav Ghosh (ag983)
* Gregory Stepniak (gps43)
