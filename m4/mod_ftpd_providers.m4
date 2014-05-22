dnl This file is Copyright 2003,2004 Edward Rudd
dnl Usage, modification, and distribution of this file in other projects is
dnl allowed and encouraged so long as this copyright notice is retained.
dnl You are encouraged to send any patches to the me at 
dnl urkle <at> outoforder <dot> cc, but this is not a requirement

dnl
dnl MOD_FTPD_OUTPUT(file)
dnl adds "file" to the list of files generated by AC_OUPUT
AC_DEFUN(MOD_FTP_OUTPUT, [
    MOD_FTPD_OUTPUT_FILES="$MOD_FTPD_OUTPUT_FILES $1"
])dnl

dnl
dnl MOD_FTPD_PROVIDER(name, helptext[, default[, config]]]])
dnl default is one of:
dnl   yes    -- enabled by default. user must explicitly disable.
dnl   no     -- disabled under default, most, all. user must explicitly enable.
dnl   most   -- disabled by default. enabled explicitly or with most or all.
dnl   ""     -- disabled under default, most. enabled explicitly or with all.
dnl
dnl basically: yes/no is a hard setting. "most" means follow the "most"
dnl            setting. otherwise, fall under the "all" setting.
dnl            explicit yes/no always overrides.
dnl
AC_DEFUN(MOD_FTPD_PROVIDER,[
    AC_MSG_CHECKING(whether to enable mod_ftpd_$1)
    define([optname],[--]ifelse($3,yes,disable,enable)[-]translit($1,_,-))dnl
    AC_ARG_ENABLE(translit($1,_,-),AC_HELP_STRING(optname(),$2),,enable_$1=ifelse($3,,maybe-all,$3))
    undefine([optname])dnl
    _apmod_extra_msg=""

    if test "$provider_selection" = "most" -a "$enable_$1" = "most"; then
    _apmod_error_fatal=no
    else
    _apmod_error_fatal=yes
    fi

    if test "$enable_$1" = "yes"; then
        _apmod_extra_msg=" ($provider_selection)"
    elif test "$enable_$1" = "most"; then
    if test "$provider_selection" = "most" -o "$provider_selection" = "all"; then
        enable_$1=yes
        _apmod_extra_msg=" ($provider_selection)"
    elif test "$enable_$1" != "yes"; then
        enable_$1=no
    fi
    elif test "$enable_$1" = "maybe-all"; then
    if test "$provider_selection" = "all"; then
        enable_$1=yes
        _apmod_extra_msg=" (all)"
    else
        enable_$1=no
    fi
    fi
    if test "$enable_$1" != "no"; then
    ifelse([$4],,:,[AC_MSG_RESULT([checking dependencies])
            $4
            AC_MSG_CHECKING(whether to enable mod_$1)
            if test "$enable_$1" = "no"; then
                if test "$_apmod_error_fatal" = "no"; then
                _apmod_extra_msg=" (disabled)"
                else
                AC_MSG_ERROR([mod_ftpd_$1 has been requested by can not be build due to prerequisite failure])
                fi
            fi])
    fi
    AC_MSG_RESULT($enable_$1$_apmod_extra_msg)
    if test "$enable_$1" != "no"; then
    PROVIDER_LIST="$PROVIDER_LIST $provider_dir/$1"
    fi
])dnl

dnl
dnl MOD_FTPD_INCLUDE_PROVIDERS(directory)
dnl searches directory for mod_ftpd provider config.m4 files
dnl
AC_DEFUN(MOD_FTPD_INCLUDE_PROVIDERS,[
    AC_ARG_ENABLE(providers,
    AC_HELP_STRING([--enable-providers=PROVIDER-LIST],[Providers to enable]),[
    for i in $enableval; do
        if test "$i" = "all" -o "$i" = "most"; then
        provider_selection=$i
        else
        eval "enable_$i=yes"
        fi
    done
        ],
    provider_selection=most
    )

    provider_dir=$1
    esyscmd(./config-stubs $provider_dir)

    AC_CONFIG_SUBDIRS($PROVIDER_LIST)
])dnl
