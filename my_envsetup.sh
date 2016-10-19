function myhmm() {
cat <<EOF
- cgrep:   Greps on all local C/C++ files.
- ggrep:   Greps on all local Gradle files.
- jgrep:   Greps on all local Java files.
- resgrep: Greps on all local res/*.xml files.
- sgrep:   Greps on all local source files.
EOF
}

###########################################

function jgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -name .svn -prune -o -name out -prune -o -type f -name "*\.java" -print0 | xargs -0 grep --color -n "$@" 
}

function cgrep()                                                                                                                                                                     
{
    find . -name .repo -prune -o -name .git -prune -o -name .svn -prune -o -name out -prune -o -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' \) -print0 | xargs -0 grep --color -n "$@"
}

function sepgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -name .svn -prune -o -path ./out -prune -o -name sepolicy -type d -print0 | xargs -0 grep --color -n -r --exclude-dir=\.git "$@" 
}

function mgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -name .svn -prune -o -path ./out -prune -o -regextype posix-egrep -iregex '(.*\/Makefile|.*\/Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -type f -print0 | xargs -0 grep --color -n "$@"
}

function treegrep()
{
    find . -name .repo -prune -o -name .git -prune -o -name .svn -prune -o -regextype posix-egrep -iregex '.*\.(c|h|cpp|S|java|xml)' -type f -print0 | xargs -0 grep --color -n -i "$@"
}

function sgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -name .svn -prune -o  -type f -iregex '.*\.\(c\|h\|cc\|cpp\|S\|java\|xml\|sh\|mk\|aidl\)' -print0 | xargs -0 grep --color -n "$@"
}

###############################################

alias godirauditlog="cd ~/Work/logs"
function godirsepolicy(){
    cd $ANDROID_BUILD_TOP/external/sepolicy
}


function adbport(){
    if [ -z $1 ]; then
        echo ANDROID_ADB_SERVER_PORT=$ANDROID_ADB_SERVER_PORT
    else
        echo export ANDROID_ADB_SERVER_PORT=$1
        export export ANDROID_ADB_SERVER_PORT=$1
    fi  

} 
       
