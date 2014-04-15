CC?=gcc
CFLAGS=-g -Wall -Wextra -Wno-unused-parameter -O2
LDFLAGS=-lrt
SRCDIR=src
TESTDIR=tests
LIB_OBJS=bitstring.o encparams.o hash.o idxgen.o key.o mgf.o ntru.o poly.o rand.o sha1.o sha2.o
TEST_OBJS=test_bitstring.o test_hash.o test_idxgen.o test_key.o test_ntru.o test.o test_poly.o test_util.o
VERSION=0.2
INST_PFX=/usr
INST_HEADERS=ntru.h types.h key.h encparams.h hash.h rand.h err.h

LIB_OBJS_PATHS=$(patsubst %,$(SRCDIR)/%,$(LIB_OBJS))
TEST_OBJS_PATHS=$(patsubst %,$(TESTDIR)/%,$(TEST_OBJS))
DIST_NAME=libntru-$(VERSION)

.PHONY: all
all: lib

.PHONY: lib
lib: $(LIB_OBJS_PATHS)
	$(CC) $(CFLAGS) -shared -Wl,-soname,libntru.so -o libntru.so $(LIB_OBJS_PATHS) $(LDFLAGS)

.PHONY: install
install: lib
	test -d $(INST_PFX) || mkdir -p $(INST_PFX)
	test -d $(INST_PFX)/lib || mkdir $(INST_PFX)/lib
	test -d $(INST_PFX)/include/libntru || mkdir -p $(INST_PFX)/include/libntru
	test -d $(INST_PFX)/share/doc/libntru || mkdir -p $(INST_PFX)/share/doc/libntru
	install -m 0755 libntru.so $(INST_PFX)/lib/libntru.so
	install -m 0644 README.md $(INST_PFX)/share/doc/libntru/README.md
	for header in $(INST_HEADERS); do \
	    install -m 0644 $(SRCDIR)/$$header $(INST_PFX)/include/libntru/; \
	done

.PHONY: uninstall
uninstall:
	rm -f $(INST_PFX)/lib/libntru.so
	rm -f $(INST_PFX)/share/doc/libntru/README.md
	rmdir $(INST_PFX)/share/doc/libntru/
	for header in $(INST_HEADERS); do \
	    rm $(INST_PFX)/include/libntru/$$header; \
	done
	rmdir $(INST_PFX)/include/libntru/

.PHONY: dist
dist:
	rm -rf $(DIST_NAME)
	mkdir $(DIST_NAME)
	mkdir $(DIST_NAME)/$(SRCDIR)
	mkdir $(DIST_NAME)/$(TESTDIR)
	cp Makefile Makefile.win Makefile.osx README.md LICENSE PATENTS $(DIST_NAME)
	cp $(SRCDIR)/*.c $(DIST_NAME)/$(SRCDIR)
	cp $(SRCDIR)/*.h $(DIST_NAME)/$(SRCDIR)
	cp $(TESTDIR)/*.c $(DIST_NAME)/$(TESTDIR)
	cp $(TESTDIR)/*.h $(DIST_NAME)/$(TESTDIR)
	tar cf $(DIST_NAME).tar.xz $(DIST_NAME) --lzma
	rm -rf $(DIST_NAME)

test: lib $(TEST_OBJS_PATHS)
	$(CC) $(CFLAGS) -o test $(TEST_OBJS_PATHS) -L. -lntru -lm
	LD_LIBRARY_PATH=. ./test

bench: lib $(SRCDIR)/bench.o
	$(CC) $(CFLAGS) -o bench $(SRCDIR)/bench.o -L. -lntru

$(SRCDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c -fPIC $< -o $@

tests/%.o: tests/%.c
	$(CC) $(CFLAGS) -fPIC -I$(SRCDIR) -c $< -o $@

.PHONY: clean
clean:
	@# also clean files generated on other OSes
	rm -f $(SRCDIR)/*.o $(TESTDIR)/*.o libntru.so libntru.dylib libntru.dll test test.exe bench bench.exe

.PHONY: distclean
distclean: clean
	rm -rf $(DIST_NAME)
	rm -f $(DIST_NAME).tar.xz $(DIST_NAME).zip
