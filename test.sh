#!/bin/bash
# vim: ft=shim
# This is a test file for the SHIM syntax highlighting
# (C) 2017 Maximilian Wende <dasisdormax@mailbox.org>
# >>> Licensed under the MIT License



################
#   COMMENTS   #
################

#                 /* no comment */
# > This text and
# > this line should be highlighted as TODO block
# This text should not
# TODO: some more things



################
#  EXPRESSIONS #
################

exit 0 # We do not really want to execute the rest of this script

echo "Hello World"; # return
echo ; echo; echo;

myfun ()
{
	sleep 2& fg; fun \x\txx
	echo test\x\
   		true
} && myfun

onelinefun () { echo true; false; }

rm -i -- --myfile dir/*
mycommand --target mytarget
mycommand --target=$target|lolcat >>/dev/null 2>&1
cat <(# )
echo true) test.sh


############################
#    STRINGS, EXPANSIONS   #
############################

# Assignments

str="Some string"; MY_ENVIRONMENT_VARIABLE=default make --debug;

# Array
array=( This is some Text )
# Index:  0   1   2   3
echo "Uppercase: The fourth element is ${array[3]^^}" # Should be TEXT
echo "Lowercase array: ${array[@],,}"

( string='my$va\$lue'; echo "String: \`$string'"; echo Length: ${#string} )

# Variable expansion
echo ${!}
echo ${!###*/}		# try this in your bash shell: should return 'bash'
echo ${#}${######}	# #1: variable name, #2 and #3: substring removal, #4+: substring to remove

dirty="Some nice string DIRTY PART DIRTY PART"
echo ${dirty/[ac]}
echo ${dirty//DIRTY}	# Some nice string  PART  PART
echo ${dirty%DIRTY*}	# Some nice string DIRTY PART
echo ${dirty%%DIRTY*}	# Some nice string
echo ${dirty: -20}	# Some nice string D

# Subshells
echo `echo '`'`
# BUG: the second backtick, if not escaped, ALWAYS ends inner comments/strings
#    > but we cannot replicate this correctly in Vim highlighting

echo $(ls
ls # stuff)
)

# Brace expansions
echo {a,"b c"}	# Should be interpreted as brace expansion
echo {a,b\ ,c}	# Same here
echo {a,b ,c}	# Should be interpreted as literal BUG: both is not possible
echo {a,b,"}"	# literal as well
echo 0.{0..9}{€,$}

# Pathnames
ls ~/D[eo]*/*.pdf	# Should show all pdf files in Desktop, Documents, Downloads
cd ~root		# Go to the home directory of user 'root'

# Mathematic expressions
num=3
echo $(((((num)) ) ))
(( num*=2; var=5 ))

arr[0]=2
echo $((arr[0]+2))

###############
#    TESTS    #
###############
if ! [[ thisfile -nt thatfile ]]; then
    [[ !(-z $var&&${PATH} =~ /bin) ]] && { mkdir target; ! cp -rn -- -n -- .file target/; }
fi

###############
#   BLOCKS    #
###############
for var in {1..3}; do
    forstuff
done

for (( var=2; var<20; var+=5 )); do
    printf "var is: %d" var
done

echo "Select an operation!"
PS3="Your selection: "
switch menu in start stop restart help; do
    echo "You have selected: $menu"
    break
done

a=b; echo $a;
a="bash"
case a in
    # this is a comment
    (xuxzgrz|sgrll"any file")echo This is some text;;&
    # this is a comment
    (skipthis|skipthat) ;;
    b*) echo a contains b ;;
esac
