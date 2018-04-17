#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

abccoinD=${abccoinD:-$SRCDIR/abccoind}
abccoinCLI=${abccoinCLI:-$SRCDIR/abccoin-cli}
abccoinTX=${abccoinTX:-$SRCDIR/abccoin-tx}
abccoinQT=${abccoinQT:-$SRCDIR/qt/abccoin-qt}

[ ! -x $abccoinD ] && echo "$abccoinD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
ABCVER=($($abccoinCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$abccoinD --version | sed -n '1!p' >> footer.h2m

for cmd in $abccoinD $abccoinCLI $abccoinTX $abccoinQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${ABCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${ABCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m