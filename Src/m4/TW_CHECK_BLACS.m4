dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2, or (at your option)
dnl any later version.
dnl
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software
dnl Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
dnl 02111-1307, USA.
dnl
dnl As a special exception, the Free Software Foundation gives unlimited
dnl permission to copy, distribute and modify the configure scripts that
dnl are the output of Autoconf.  You need not follow the terms of the GNU
dnl General Public License when using or distributing such scripts, even
dnl though portions of the text of Autoconf appear in them.  The GNU
dnl General Public License (GPL) does govern all other use of the material
dnl that constitutes the Autoconf program.
dnl
dnl Certain portions of the Autoconf source text are designed to be copied
dnl (in certain cases, depending on the input) into the output of
dnl Autoconf.  We call these the "data" portions.  The rest of the Autoconf
dnl source text consists of comments plus executable code that decides which
dnl of the data portions to output in any given case.  We call these
dnl comments and executable code the "non-data" portions.  Autoconf never
dnl copies any of the non-data portions into its output.
dnl
dnl This special exception to the GPL applies to versions of Autoconf
dnl released by the Free Software Foundation.  When you make and
dnl distribute a modified version of Autoconf, you may extend this special
dnl exception to the GPL to apply to your modified version as well, *unless*
dnl your modified version has the potential to copy into its output some
dnl of the text that was the non-data portion of the version that you started
dnl with.  (In other words, unless your change moves or copies text from
dnl the non-data portions to the data portions.)  If your modification has
dnl such potential, you must delete any notice of this special exception
dnl to the GPL from your modified version.
dnl
dnl Copyright Toby White <tow21@cam.ac.uk>  2004-2006 

dnl Macro to check that correct flags have been chosen for 
dnl compilation with BLACS. Only works with Fortran at the moment.

AC_DEFUN([_TW_TRY_BLACS], [
ac_ext=f
AC_LINK_IFELSE(
   [AC_LANG_SOURCE([[
      PROGRAM BLACS                   
      INTEGER MYPNUM, NPROCS        
      CALL BLACS_PINFO(MYPNUM, NPROCS)
      END PROGRAM
   ]])],
[m4_default([$1],[:])],
[m4_default([$2],[:])]
)
])


AC_DEFUN([TW_CHECK_BLACS], [
#AC_REQUIRE(ACX_MPI)
tw_blacs_ok=no

# All tests must be run with the MPI fortran compiler.
save_FC=$FC
FC=$MPIFC

AC_ARG_WITH(blacs,
        [AC_HELP_STRING([--with-blacs=<lib>], [use BLACS library <lib>])])
if test x"$with_blacs" != x; then
   BLACS_LIBS="$with_blacs"
fi

save_LIBS=$LIBS
LIBS="$BLACS_LIBS $LIBS"
AC_MSG_CHECKING([if we can compile a BLACS program])
_TW_TRY_BLACS([tw_blacs_ok=yes],[])
AC_MSG_RESULT([$tw_blacs_ok])
LIBS=$save_LIBS

if test $tw_blacs_ok != yes; then
   AC_MSG_CHECKING([for BLACS in -lblacs])
   save_LIBS=$LIBS
   LIBS="-lblacs $LIBS"
   _TW_TRY_BLACS([tw_blacs_ok=yes;BLACS_LIBS=-lblacs],[])
   AC_MSG_RESULT([$tw_blacs_ok])
   LIBS=$save_LIBS
fi

if test $tw_blacs_ok != yes; then
   AC_MSG_CHECKING([for BLACS in -lblacsF77init -lblacs -lblacsF77init])
   save_LIBS=$LIBS
   LIBS="-lblacsF77init -lblacs -lblacsF77init $LIBS"
   _TW_TRY_BLACS([tw_blacs_ok=yes;BLACS_LIBS="-lblacsF77init -lblacs -lblacsF77init"],[])
   AC_MSG_RESULT([$tw_blacs_ok])
   LIBS=$save_LIBS
fi

# Try in Sun performance library
if test $tw_blacs_ok != yes; then
   AC_MSG_CHECKING([for BLACS in -ls3l])
   save_LIBS=$LIBS
   LIBS="-ls3l $LIBS"
   _TW_TRY_BLACS([tw_blacs_ok=yes;BLACS_LIBS="-ls3l"],[])
   AC_MSG_RESULT([$tw_blacs_ok])
   LIBS=$save_LIBS
fi

FC=$save_FC

AC_SUBST(BLACS_LIBS)

# Finally, execute ACTION-IF-FOUND/ACTION-IF-NOT-FOUND:
AS_IF([test $tw_blacs_ok = yes],
      [$1],
      [m4_default([$2],[AC_MSG_ERROR([Cannot compile correctly with BLACS])])]
      )
])dnl TW_CHECK_BLACS

