#! /bin/sh

# Example of call
# <valgrind-color> --leak-check=full --track-origins=yes <program>
# <valgrind-color> --leak-check=full --track-origins=yes --track-fds=yes <program>

# Some colors helper, from https://wiki.archlinux.org/index.php/Color_Bash_Prompt
txtblk='\033[0;30m' # Black - Regular
txtred='\033[0;31m' # Red
txtgrn='\033[0;32m' # Green
txtylw='\033[0;33m' # Yellow
txtblu='\033[0;34m' # Blue
txtpur='\033[0;35m' # Purple
txtcyn='\033[0;36m' # Cyan
txtwht='\033[0;37m' # White
bldblk='\033[1;30m' # Black - Bold
bldred='\033[1;31m' # Red
bldgrn='\033[1;32m' # Green
bldylw='\033[1;33m' # Yellow
bldblu='\033[1;34m' # Blue
bldpur='\033[1;35m' # Purple
bldcyn='\033[1;36m' # Cyan
bldwht='\033[1;37m' # White
unkblk='\033[4;30m' # Black - Underline
undred='\033[4;31m' # Red
undgrn='\033[4;32m' # Green
undylw='\033[4;33m' # Yellow
undblu='\033[4;34m' # Blue
undpur='\033[4;35m' # Purple
undcyn='\033[4;36m' # Cyan
undwht='\033[4;37m' # White
bakblk='\033[40m'   # Black - Background
bakred='\033[41m'   # Red
bakgrn='\033[42m'   # Green
bakylw='\033[43m'   # Yellow
bakblu='\033[44m'   # Blue
bakpur='\033[45m'   # Purple
bakcyn='\033[46m'   # Cyan
bakwht='\033[47m'   # White
txtrst='\033[0m'    # Text Reset

# Call valgrind
valgrind $@ 2>&1    | \
# Color error count
sed -r ''s/\(ERROR\ SUMMARY:\)\ \(0\)/\\1`printf "${txtgrn}"`\ \\2`printf "${txtrst}"`/g''              | \
sed -r ''s/\(ERROR\ SUMMARY:\)\ \([1-9][0-9]*\)/\\1`printf "${bldred}"`\ \\2`printf "${txtrst}"`/g''    | \
# Color titles
sed -r ''s/\([A-Z]+\ SUMMARY\)/`printf "${undylw}"`\\1`printf "${txtrst}"`/g''                  | \
sed -r ''s/\(FILE\ DESCRIPTORS\)/`printf "${undylw}"`\\1`printf "${txtrst}"`/g''                | \
# inherited from parent
sed -r ''s/\(\<inherited\ from\ parent\>\)/`printf "${txtgrn}"`\\1`printf "${txtrst}"`/g''      | \
# Openned files descriptor
sed -r ''s/\(Open\ file\ descriptor\ [1-9][0-9]*:\ .*\)/`printf "${bldred}"`\\1`printf "${txtrst}"`/g''      | \
# Color command
sed -r ''s/Command:\ \(.+\)/Command:\ `printf "${bldcyn}"`\\1`printf "${txtrst}"`/g''           | \
# Color informations
sed -r ''s/\(Rerun\ with.+\)/\ `printf "${undred}"`\\1`printf "${txtrst}"`/g''                  | \
# Color errors
sed -r ''s/\(Use\ of\ uninitialised\ value\ of\ size\)/`printf "${bldred}"`\\1`printf "${txtrst}"`/g''   | \
sed -r ''s/\(Uninitialised\ value.*\)/`printf "${bldred}"`\\1`printf "${txtrst}"`/g''           | \
sed -r ''s/\(Invalid\ read\ of\ size\)/`printf "${bldred}"`\\1`printf "${txtrst}"`/g''          | \
sed -r ''s/\(Invalid\ write.*\)/`printf "${bldred}"`\\1`printf "${txtrst}"`/g''          | \
sed -r ''s/\(Syscall\ param\.*\)/`printf "${bldred}"`\\1`printf "${txtrst}"`/g''          | \
sed -r ''s/\(Invalid\ free\.*\)/`printf "${bldred}"`\\1`printf "${txtrst}"`/g''          | \
sed -r ''s/\(Address\ 0x[0-9a-f]+\ is\ .*\)/`printf "\033[34m"`\\1`printf "${txtrst}"`/g''      | \
# Color functions name
sed -r ''s/\(at\ 0x[0-9a-fA-F]+:\ \)\([a-z0-9A-Z_]+\)/\\1`printf "${bldylw}"`\\2`printf "${txtrst}"`/g''  | \
sed -r ''s/\(by\ 0x[0-9a-fA-F]+:\ \)\([a-z0-9A-Z_]+\)/\\1`printf "${bldylw}"`\\2`printf "${txtrst}"`/g''  | \
# Color {x} bytes in {y} blocks
sed -r ''s/\(\ 0\)\(\ bytes?\ in\ \)\(0\)/`printf "${bldgrn}"`\\1`printf "${txtrst}"`\\2`printf "${bldgrn}"`\\3`printf "${txtrst}"`/g''         | \
sed -r ''s/\([0-9],+\)\(\ bytes?\ in\ \)\([0-9]+\)/`printf "${bldred}"`\\1`printf "${txtrst}"`\\2`printf "${bldblu}"`\\3`printf "${txtrst}"`/g'' | \

cat
