#
#  $Id$
PRG     = dialog
CFLAGS	= -O2 -Wall -I /usr/include -I /usr/local/include
CFLAGS	+= -D __WITH_SQLITE__ -D SQLITE_TEMP_STORE=3

LDFLAGS = -lsqlite3 -L/usr/local/lib -lncurses

#HEADERS       = spectro450.h
SOURCES       = dialog.c
OBJECTS       = dialog.o

$(PRG): $(OBJECTS) Makefile
	@printf "Linking   $@:"
	@$(CC) $(LDFLAGS) $(CFLAGS) $(OBJECTS) -o $@
	@printf "\tdone.\n"

clean:
	@rm -f  $(OBJECTS) *~ $(PRG)
	@chmod 644 $(SOURCES) $(HEADERS) $(ASMSRCS)

.c.o:
	@printf "Compiling $<:"
	@$(CC) $(CFLAGS) -Os -c $< -o $@
	@printf "\tdone.\n"
