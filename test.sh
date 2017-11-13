#!/bin/bash
# vim: ts=4 noet
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

# inner comments
for a in a b# c # d e f
do
    echo $a
done
[[ # = # ]]
a = b ]]
case a # b c d
in
    a) echo a;;
    b) echo b;;
esac
var=( a # comment
b####no_comment
c #### also a comment )
d_still_in_array
)

################
#  EXPRESSIONS #
################

exit 0 # We do not really want to execute the rest of this script

echo "Hello World";# return
echo ; echo; echo;

VER=$(uname -r)
echo ${VER//4/four}

myfun ()
{
	sleep 2& fg; fun \x\txx
	echo test\x\
		true
} && myfun

onelinefun () { echo true; false; return 5; }
function name { command echo test ;}

rm -i -- --myfile dir/*
mycommand --target mytarget

# Redirection
mycommand --target-file=$target|lolcat >>/dev/null 2>&1
cat <(# )
echo true) test.sh

cat foo.txt bar.txt > new.txt
cat>new.txt foo.txt bar.txt
echo;> new.txt cat foo.txt bar.txt

##################
# HERE DOCUMENTS #
##################

cat <<< Hello

cat <<EOH
This is a here
				document
EOH

cat <<-"TAG"
				Any tab character at the front of the line is
	ignored.
		TAG

cat <<-EOF | lolcat;>/home/user/hello echo world;
	this is my "text"
	| what? $var_here $(this is my command)
	EOF

<<"hered0cend" cat | lolcat || echo "Error detected!";
	this is my "text"
	| what? $var_here $(this is my command)
	hered0cend
hered0cend

# Nesting heredocs. Note that the correct order would be to
# close TEXT1 first, then TEXT2. We cannot fix that
# Use the same delimiter for both heredocs as workaround
cat <<TEXT1; <<TEXT2 cat; echo true;
	this is a heredoc
TEXT2
	and more text
TEXT1


############################
#    STRINGS, EXPANSIONS   #
############################

# Assignments

str=\"some\"
str="Some string \" with inner quotes \""; MY_ENVIRONMENT_VARIABLE=default make --debug;

# Array
array=( This is
	some Text )
array=( )
# Index:  0   1   2   3
echo "Uppercase: The fourth element is ${array[3]^^}" # Should be TEXT
echo "Lowercase array: ${array[@],,}"

( string='my$va\$lue'; echo "String: \`$string'"; echo Length: ${#string} )

# Variable expansion
echo ${!}
echo ${!###*/}			# try this in your bash shell: should return 'bash'
echo ${#}${######}		# #1: variable name, #2 and #3: substring removal, #4+: substring to remove

dirty="Some nice string DIRTY PART DIRTY PART"
echo ${dirty/[ac]}
echo ${dirty//DIRTY}	# Some nice string  PART  PART
echo ${dirty%DIRTY*}	# Some nice string DIRTY PART
echo ${dirty%%DIRTY*}	# Some nice string
echo ${dirty: -20}		# Some nice string D
echo ${dirty/"some } string"}

# Subshells
echo `echo '`'`
# BUG: the second backtick, if not escaped, ALWAYS ends inner comments/strings
#    > but we cannot replicate this correctly in Vim highlighting

echo $(ls#;#
ls # stuff)
)# # Note that the # belongs to the string started by the $( ... )

# Brace expansions
exec 2>/dev/null
echo {a,"b c"}			# Should be interpreted as brace expansion
echo {a,b\ ,c}			# Same here
echo {a,b ,c}			# Should be interpreted as literal
echo {a,b,"}"			# literal as well BUG: both is not possible
echo 0.{0..9}{€,$}

# Pathnames
ls ~/D[eo]*/*.pdf		# Should show all pdf files in Desktop, Documents, Downloads
cd ~root				# Go to the home directory of user 'root'

# Mathematic expressions
num=3
echo $(((((num)) ) ))
(( num*=2, var=5 ))

arr[0]=2
echo $((arr[0]+2))

###############
#    TESTS    #
###############
if ! [[ thisfile -nt thatfile ]]; then
    [[ !(-z $var&&${PATH} =~ /bin) ]] && { mkdir target; ! cp -rn -- -n -- .file target/; }
fi
[[ somestring123 =~ [[:alpha:]] ]]

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
    (skipthis|skipthat) var_2=;;
    b*) echo a contains b ;;
esac

###############
#  BUILTINS   #
###############
declare -u var=value;
declare -a array=( 1 2 3 4 )
read -p "Enter your target! " TARGET; >functions.declare declare -f -p;
