#include <sqlite3.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>  
#include <curses.h>

#include "dialog.h"

int main(int argc, char *argv[]) {

    	WINDOW * mainwin;
	FILE *conf;
	FILE *serial;
	conf = fopen(CONF_DB, "r");
	if ( conf == NULL ) {
		sprintf(tty, "%s", SPECTRO_TTY);
	}

	if ((serial = fopen(tty, "rw")) == NULL){
		newterm(getenv("TERM"), serial, serial);
    	}
    
    /*  Initialize ncurses  */

    if ( (mainwin = initscr()) == NULL ) {
	fprintf(stderr, "Error initialising ncurses.\n");
	exit(EXIT_FAILURE);
    }

    mvaddstr(13, 33, "Hello, world!");
    refresh();

    /*  Clean up after ourselves  */

    delwin(mainwin);
    endwin();
    refresh();
    //fprintf(stderr, "Nombre de lignes: %d\n", LINES);
    //fprintf(stderr, "Nombre de colonnes: %d\n", COLS);

    return EXIT_SUCCESS;
}
