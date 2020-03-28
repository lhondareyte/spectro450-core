#
#  $Id$
LIB     = libspectro.so
CFLAGS	= -O2 -Wall -I /usr/include -I /usr/local/include
LDFLAGS = -shared -fPIC -Wl,-soname,$(LIB).1

HEADERS       = spectro450.h
SOURCES       = spectro450.c
OBJECTS       = spectro450.o

$(LIB): $(OBJECTS) Makefile
	@printf "Linking   $@:"
	@$(CC) $(LDFLAGS) $(CFLAGS) $(OBJECTS) -o $@
	@ln -s $(LIB) $(LIB).1
	@printf "\tdone.\n"

clean:
	@rm -f  $(OBJECTS) *~ $(LIB) $(LIB).1
	@chmod 644 $(SOURCES) $(HEADERS) $(ASMSRCS)

.c.o:
	@printf "Compiling $<:"
	@$(CC) $(CFLAGS) -Os -c $< -o $@
	@printf "\tdone.\n"
