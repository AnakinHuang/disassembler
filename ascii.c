/* This program gives information about an ascii code.
** Its arguments are taken as octal, hex, or decimal numbers
** and it prints information about the character.
** With an argument of -, all values are printed.
** With no argument, ascii expects characters from the keyboard.
** To exit, push the same key three times in a row.
*/

#include <stdlib.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <ctype.h>

char *value[] = {
    "nul   ^@", "soh   ^A", "stx   ^B", "etx   ^C", "eot   ^D", "enq   ^E", "ack   ^F", "bel   ^G",
    "bs    ^H", "ht    ^I", "nl    ^J", "vt    ^K", "np    ^L", "cr    ^M", "so    ^N", "si    ^O",
    "dle   ^P", "dc1   ^Q", "dc2   ^R", "dc3   ^S", "dc4   ^T", "nak   ^U", "syn   ^V", "etb   ^W",
    "can   ^X", "em    ^Y", "sub   ^Z", "esc   ^[",
                "fs    ^\\  ^shL", "gs    ^]  ^shM",
                "rs    ^^  ^shN",  "us    ^_  ^shO",
    "sp", "!", "\"", "#", "$", "%", "&", "'",
    "(", ")", "*", "+", ",", "-", ".", "/",
    "0", "1", "2", "3", "4", "5", "6", "7",
    "8", "9", ":", ";", "<", "=", ">", "?",
    "@", "A", "B", "C", "D", "E", "F", "G",
    "H", "I", "J", "K", "L", "M", "N", "O",
    "P", "Q", "R", "S", "T", "U", "V", "W",
    "X", "Y", "Z", "[", "\\", "]", "^", "_",
    "`", "a", "b", "c", "d", "e", "f", "g",
    "h", "i", "j", "k", "l", "m", "n", "o",
    "p", "q", "r", "s", "t", "u", "v", "w",
    "x", "y", "z", "{", "|", "}", "~", "del   ^?"
};

static void show_char(int c) {
    printf(" %#4x  %#4o  %3d    %s\n", c, c, c, value[c]);
}

int main(int argc, char **argv) {
    struct termios orig, new;
    int base, current, last, lastlast;
    current = last = lastlast = -1;
    if (argc > 1) {
        if (*argv[1] == '-') {
            for (current = 0; current <= 127; current++)
            show_char(current);
        } else {
            for (int i = 1; i < argc; i++) {
                char *cp = argv[i];
                current = 0;
                switch (*cp) {
                case '0':
                    base = 8;
                    cp++;
                    if (*cp != 'x')
                        break;
                    /* else fall through */
                case 'x':
                    base = 16;
                    cp++;
                    break;
                default:
                    base = 10;
                }
                for (;; ++cp) {
                    int d;
                    if (!isxdigit (*cp))
                        break;
                    if (isdigit (*cp))
                        d = *cp - '0';
                    else if (isupper (*cp))
                        d = *cp - 'A' + 10;
                    else
                        d = *cp - 'a' + 10;
                    if (d > base)
                        break;
                    current = base * current + d;
                }
                if (*cp != '\0') {
                    printf("%s???\n", cp);
                    exit(1);
                }
                if (current <= 127) {
                    show_char(current);
                }
                else printf("value %s out of range\n", argv[i]);
            }
        }
    } else {
        (void) tcgetattr(2, &orig);
        new = orig;
        (void) cfmakeraw(&new);

        (void) tcsetattr(2, TCSANOW, &new);
        while (((current = (0177 & getchar())) != last) || (current != lastlast)) {
            lastlast = last;
            last = current;
            show_char(current);
            putchar('\r');      // device is raw
        }
        (void) tcsetattr(2, TCSANOW, &orig);
    }
}
