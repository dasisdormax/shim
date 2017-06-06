" Vim Syntax File
" vim: ts=4 noet sts=0 fdm=marker
" Language:		shell (sh) bash (sh)
" Maintainer:	Maximilian Wende <dasisdormax@secure.mailbox.org>
" Version:		0.1.0




" Preparation {{{1
" ================

" quit if a syntax definition is already loaded
" ---------------------------------------------
"if exists("b:current_syntax")
"  finish
"endif


" sh syntax is case sensitive
" ---------------------------
syn case match


" }}}1

" Top-Level Regions {{{1
" ======================
syn cluster	shimTop										contains=shimComment,shimExpression
syn region	shimComment		start="#"		end="$"		contains=@shimInComment		extend	keepend
syn region	shimExpression	start="[^ \t#]"	end="$"		contains=@shimInExpression	keepend


"  }}}1

" Comment contents (Todo, Shebang) {{{1
" =========================================
syn cluster	shimInComment		contains=shimTodo,shimShebang,shimVimline

syn region	shimShebang			contained	matchgroup=shimComment	start="\%^#!"	end="$"
syn match	shimVimline			contained	"\svim:\s.*$"
syn region	shimTodo			contained	start=">\|NOTE\|TODO\|FIXME\|BUG\|(C)"	end="$"	contains=shimTodoKeyword
syn keyword	shimTodoKeyword		contained	NOTE	TODO	FIXME	BUG

  
" Expressions {{{1 
" ====================
syn cluster	shimInExpression	contains=@shimControl,@shimBlock,shimCommand,shimComment
syn cluster shimBlock			contains=shimTest,shimOldTest,shimMathTest,shimFor,shimSwitch,shimCase,shimEsac
syn cluster shimControl			contains=shimFunction,shimSubshellOpen,shimBlock,shimInvertResult,shimConditional,shimRepeat


" |-> basic command names, variable assignments {{{1
" ====================================================
syn cluster	shimCommandPart		contains=shimSeparator,shimCaseSeparator,@shimRedirect,shimSubshellError,shimSubshellClose,@shimString

" ShimCommand: 	Any command, function or builtin that is executed by bash
" followed by any number of arguments
syn region	shimCommand			contained	start="\S"		end="\s\@="	contains=shimAssignment,@shimCommandPart	nextgroup=@shimMixedArgument	skipwhite

" ShimAssignment: A variable assignment
syn region	shimAssignment		contained	start="\i\+\%(+\?=\|\[\)"	end="\s\+"	contains=shimAssignmentArrayAccess,shimAssignmentValue
syn region	shimAssignmentArrayAccess	contained	matchgroup=shimVarArrayOp	start="\["	end="\]"
syn region	shimAssignmentValue	contained	matchgroup=shimAssignmentOperator	start="+\?="	end="\s\@="	contains=@shimString


" |-> arguments and command line flags {{{1
" ===========================================
syn cluster shimMixedArgument	contains=shimFlag,shimFlagEnd,shimArgument,shimComment
syn cluster shimBackArgument	contains=shimArgumentEnd,shimComment

" ShimFlag:		A command line flag to the current command (starts with -)
syn region  shimFlag			contained	start="-"	end="\s\@="	contains=@shimCommandPart,shimFlagValue	nextgroup=@shimMixedArgument	skipwhite

" ShimFlagValue: A value for a long argument, split by an equals sign
syn region	shimFlagValue		contained	matchgroup=shimFlagEquals	start="="	end="\s\@="	contains=@shimCommandPart

" ShimLastFlag:	"--", ends the command line parsing further on
syn match	shimFlagEnd			contained	"--\s\@="	nextgroup=@shimBackArgument	skipwhite

" ShimArgument: An argument to a command
syn region	shimArgument		contained	start="[^ \t#-]"	end="\s\@="	contains=@shimCommandPart	nextgroup=@shimMixedArgument	skipwhite

syn region	shimArgumentEnd		contained	start="[^ \t#]"		end="\s\@="	contains=@shimCommandPart	nextgroup=@shimBackArgument	skipwhite

 
" |-> expression separators {{{1
" ================================
" ShimSeparator: An expression delimiter:
" semicolon, pipe, go to background, logic operators
syn match	shimSeparator	contained	"\([|&]\{1,2\}\|;[;&|]\@!\)\s*"	nextgroup=@shimTop


" |-> redirects {{{1
" ======================
syn cluster	shimRedirect	contains=shimRedirSourceStream,shimRedirInOut
syn cluster	shimRedirTarget	contains=shimRedirTargetStream,shimRedirTargetProcess,@shimRedirect,shimSeparator,@shimString

" ShimRedirOutFile: Redirect a stream to a file: echo hello>file
syn region	shimRedirInOut	contained	matchgroup=shimRedirOp	start="[<>]&\?\s*"	end="\s\@="	contains=@shimRedirTarget

" ShimRedirSourceStream: A redirection source (stream number in front of > and <)
syn match	shimRedirSourceStream	contained	"[ \t\n|;&]\@<=[0-9]\+[<>]\@="

" ShimRedirTargetStream: A target stream for a redirect: >&1
syn match	shimRedirTargetStream	contained	"\%([<>]&\s*\)\@<=\%(-\|[0-9]\+\)"

" ShimRedirTargetProcess: cat <(ls)
" A target process (command list) for process substitution
syn region	shimRedirTargetProcess	contained	matchgroup=shimRedirOp	start="("	end=")"	extend	keepend		contains=@shimTop


" |-- strings, special characters {{{1 
" ======================================
syn cluster	shimString			contains=shimSqString,shimDqString,@shimEscape,@shimPattern,@shimExpansion,shimBraceExp
syn cluster	shimPattern			contains=shimGlob,shimCharOption,shimHome
syn cluster	shimExpansion		contains=@shimExpansionInStr
syn cluster shimExpansionInStr	contains=@shimVarExp,@shimCmdSub,@shimMathExpr


" | |-> quotes and escapes {{{1
" ===============================
syn cluster shimEscape		contains=shimEscape,shimEscapeNewl
syn cluster shimInDqString	contains=shimEscapeVar,shimEscapeNewl,@shimExpansionInStr

" ShimEscape: An escaped character
syn match	shimEscape		contained	extend	"\\."
syn match	shimEscapeNewl	contained	extend	"\\\n"
syn match	shimEscapeVar	contained	extend	"\\[\\$`]"

" ShimSqString: A string in single quotes
" Variables and Backslashes are taken literally
syn region	shimSqString	contained	extend	matchgroup=shimQuote	start=+'+	end=+'+

" ShimDqString: A string in double quotes
" Can contain escaped characters and variable expansions
syn region	shimDqString	contained	extend	matchgroup=shimQuote	start=+"+	end=+"+	contains=@shimInDqString


" | |-> curly brace expansion {{{1 
" ================================
syn region	shimBraceExp	contained	matchgroup=shimBraceExpOp	start="{"	end="\s\@=\|}"	contains=@shimString,shimBraceExpOp	oneline
syn match	shimBraceExpOp	contained	"\.\.\|,"


" | |-> patterns and path expansions {{{1
" ======================================
syn match	shimGlob		contained	"\*\|?"
syn match	shimHome		contained	"\~[_a-z]*[0-9]\@!"
syn match	shimCharOption	contained	"\[.\+\]"	contains=@shimEscape


" | |-> quick variable expansions {{{1
" ====================================
syn cluster	shimVarExp			contains=shimVarSimple,shimVarSpecial,shimVar

" ShimVarSimple: Print a variable in place
syn match	shimVarSimple		contained	"\$[a-zA-Z0-9_]\+"

" ShimVarSpecial: Print a special variable
syn match	shimVarSpecial		contained	"\$[-$#!@*?]"
 

" | |-> full variable expansions {{{1
" ===================================
syn cluster shimVarModifier		contains=shimVarModCase,shimVarModRemove,shimVarModSearchReplace,shimVarModSubstr,shimVarModOption,shimVarArrayAccess
syn cluster	shimVarName			contains=shimVarNameSimple,shimVarNameSpecial

" ShimVar: Print a variable, possibly modified
syn region	shimVar				contained	matchgroup=shimVarBraces	start="\${"	end="}"	contains=shimVarModAccess	extend	keepend

" ShimVarName: A variable name inside an expansion
syn match	shimVarNameSimple	contained	"[a-zA-Z0-9_]\+"		nextgroup=@shimVarModifier
syn match	shimVarNameSpecial	contained	"[-$#!@*?]"				nextgroup=@shimVarModifier

" ShimVarModAccess: Access Modifiers: ! for indirection, # for length access
syn match	shimVarModAccess	contained	"\%(\${\)\@<=\%(\%(!\|##\@!\)[!}]\@!\)\?"	nextgroup=@shimVarName

" ShimVarModCase: Case modification operator (^^ ,, ~~)
syn match	shimVarModCase		contained	"\([\^,~]\)\1\?"

" ShimVarModRemove: Remove substring operator (%% ##)
syn region	shimVarModRemove		contained	matchgroup=shimVarModOp	start="\([%#]\)\1\?"rs=e	end="}"	contains=@shimString

" ShimVarModSearchReplace: Search and replace in a string (// /)
syn region	shimVarModSearchReplace	contained	matchgroup=shimVarModOp	start="//\?"rs=e		end="/"	contains=@shimString	nextgroup=shimVarModSrReplacement
syn match	shimVarModSrReplacement	contained	"\_.*"	contains=@shimString

" ShimVarModSubstr: Print a substring
syn region	shimVarModSubstr		contained	matchgroup=shimVarModOp	start=":[-+?]\@!"	end=":\@="	contains=@shimInMathExpr	nextgroup=shimVarModSubstr

" ShimVarModOption: Optional default, alternative, error values
syn region	shimVarModOption		contained	matchgroup=shimVarModOp	start=":\?[-+?]"rs=e	end="}"	contains=@shimString

" ShimVarArrayAccess: Array access operator
syn region	shimVarArrayAccess		contained	matchgroup=shimVarArrayOp	start="\["	end="\]"	nextgroup=@shimVarModifier

  
" | |-> mathematic expressions {{{1
" =================================
syn cluster	shimMathExpr			contains=shimMathExprDblBraces,shimMathExprBrackets
syn cluster shimInMathExpr			contains=shimMathNum,shimMathBraces,shimMathVar,shimMathOp,@shimExpansion

" ShimMathExprDblBraces: A mathematic expression $(( ... ))
syn region	shimMathExprDblBraces	contained	matchgroup=shimMathExpr	start="\$(("	end="))"	contains=@shimInMathExpr	extend	keepend

" ShimMathExprBrackets: $[ ... ], this is considered deprecated, however
syn region	shimMathExprBrackets	contained	matchgroup=shimMathExpr	start="\$\["	end="\]"	contains=@shimInMathExpr	extend	keepend

" ShimMathTest: A mathematic test (( ... ))
syn region	shimMathTest			contained	matchgroup=shimMathExpr	start="(("	end="))"	contains=@shimInMathExpr	extend	keepend

" ShimMathNum: An integer number
syn match	shimMathNum				contained	"[0-9]\+"

" ShimMathBraces: Braces inside a math expression
syn region	shimMathBraces			contained	matchgroup=shimMathBraces	start="("	end=")"	contains=@shimInMathExpr	extend	keepend

" ShimMathVar: A variable name
syn match	shimMathVar				contained	"[_a-zA-Z][_a-zA-Z0-9]*"	nextgroup=shimMathArrayAccess

" ShimMathArrayAccess: Accessing an array element
syn region	shimMathArrayAccess		contained	matchgroup=shimVarArrayOp	start="\["	end="\]"

" ShimMathOp:  A mathematic operator
syn match	shimMathOp				contained	"+\|-\|*\|/\|%\|="


" | |-> command substitutions {{{1
" ================================
syn cluster	shimCmdSub			contains=shimCmdSubBacktick,shimCmdSubBraces

" ShimCmdSubBacktick: command substitution in backticks
syn region	shimCmdSubBacktick	contained	matchgroup=shimCmdSub	start="`"		end="`"	contains=@shimTop	extend	keepend

" ShimCmdSubBraces:	command substitution in $( ... )
syn region	shimCmdSubBraces	contained	matchgroup=shimCmdSub	start="\$((\@!"	end=")"	contains=@shimTop	extend	keepend


" |-> functions and blocks {{{1 
" =============================

" ShimFunction: function declaration: funname () [block]
" match pattern: 'funname ()' with variable whitespace inbetween
syn match	shimFunction		contained	"[^ \t()<>\\;]\+\s*(\s*)"	contains=shimFunctionName
" ShimFunctionName: highlight the function name
syn match	shimFunctionName	contained	"[^ \t()<>\\;]\+\s*"

" ShimBlock: Curly braces, which combine multiple expressions into a block
syn match	shimBlock			contained	"[\n\t ;|&]\@<=[{}][\n\t ;|&]"

" ShimConditional: A keyword that triggers conditional execution. Must be at
" the front of an expression and can (mostly) be followed by one.
syn keyword	shimConditional		contained	if	then	else	fi	

" ShimRepeat: A keyword that causes commands to be executed repeatedly
syn keyword	shimRepeat			contained	while	do	done

" ShimInvertResult: The result-inverting ! operator
syn match	shimInvertResult	contained	"!\s\+"


" ShimSubshellOpen: Open a subshell: can only be at the front of a command
syn match	shimSubshellOpen	contained	"((\@!"	nextgroup=@shimTop
" ShimSubshellClose: Close a subshell: can be anywhere in a command
syn match	shimSubshellClose	contained	")\s*"	nextgroup=@shimTop


" |-> variable iteration (for, switch) {{{1
" =========================================

" ShimFor: A for loop
syn match	shimFor				contained	"for\%(\s\+\|\%(((\)\@=\)"	nextgroup=shimForCStyle,shimIterator

" ShimSwitch: A switch statement
syn match	shimSwitch			contained	"switch\s\+"	nextgroup=shimIterator

" ShimForCStyle: for (( init; break; step ))
syn region	shimForCStyle		contained	matchgroup=shimForCStyleBraces	start="(("	end="))"	contains=@shimInMathExpr	extend	keepend

" ShimIterator: (for|switch)    var    in    1 2 3
syn match	shimIterator		contained	"[a-zA-Z_][a-zA-Z_0-9]*\s*"	nextgroup=shimIteratorList

" ShimIteratorList: A list of strings to be iterated over - if omitted: $@
syn region	shimIteratorList	contained	matchgroup=shimIteratorIn	start="in"	end="[\n;|&]"	contains=@shimString


" |-> tests {{{1
" ==============
syn cluster	shimInTest			contains=@shimString,shimTestOp,shimTestControl
syn region	shimTest			contained	matchgroup=shimTestBrackets	start="\[\[[\t\n (]"	end="[\t\n )]\]\]"	contains=@shimInTest	extend	keepend
" Note: The old test does not go across line breaks, so no extend attribute
syn region	shimOldTest			contained	matchgroup=shimTestBrackets	start="\[\s"			end="\%([();&|]\@=\|\]\)"	contains=@shimInTest	keepend

syn match	shimTestOp			contained	"[() \t\n]\@<=\%(-[a-zA-Z]\{1,2\}\|[<>!=]=\?\|=\~\)[() \t\n]\@="
syn match	shimTestControl		contained	"(\|)\|&&\|||\|![( \t\n]\@="

 
" |-> case blocks {{{1
" ====================
syn cluster	shimCasePattern		contains=@shimString,shimCaseOption,shimCaseOpenPattern,shimComment
syn match	shimCase			contained	"case\s\+"		nextgroup=shimCaseString
syn region	shimCaseString		contained	start="."	end="\_s\%(in\_s\+\)\@="	contains=@shimString	nextgroup=shimCaseIn	extend	keepend

syn region	shimCaseIn			contained	matchgroup=shimCaseControl	start="in"	end="[;&)]\|\<esac\>"	contains=@shimCasePattern	extend keepend
syn region	shimCaseSeparator	contained	matchgroup=shimCaseControl	start=";;&\?\|;&"	end="[;&)]\s*\|\<esac\>"	contains=@shimCasePattern	extend	keepend	nextgroup=@shimTop

syn match	shimCaseOption		contained	"|"
syn match	shimCaseOpenPattern	contained	"("


" Errors {{{1
" ===========

" ShimSubshellError: unescaped opening braces (bad subshell or function declaration)
syn match	shimSubshellError	contained	"("


" 1}}}

" Set syntax and highlighting {{{1 
" ================================

" Comments
hi def link shimComment				Comment
hi def link shimShebang				PreProc
hi def link shimVimline				PreProc
hi def link shimTodo				SpecialComment
hi def link shimTodoKeyword			Todo
hi def link shimTodoSkip			Comment

" Basic Expressions
hi def link shimExpression			Normal
hi def link shimSeparator			Statement
hi def link shimCommand				Function
hi def link shimAssignment			Type
hi def link shimAssignmentArrayAccess	Special
hi def link shimAssignmentOperator	Operator
hi def link shimAssignmentValue		Normal

" Arguments and Flags
hi def link shimFlag				String
hi def link shimFlagValue			Normal
hi def link shimFlagEquals			Operator
hi def link shimFlagEnd				Special

" Strings
hi def link shimEscape				SpecialChar
hi def link shimEscapeVar			SpecialChar
hi def link shimEscapeNewl			Statement
hi def link shimQuote				Special
hi def link shimSqString			String
hi def link shimDqString			String

hi def link shimGlob				Identifier
hi def link shimHome				Identifier
hi def link shimCharOption			Identifier
hi def link shimBraceExp			String
hi def link shimBraceExpOp			Special

" Redirections
hi def link shimRedirOp				Statement
hi def link shimRedirSourceStream	Type
hi def link shimRedirTargetStream	Type

" Variables
hi def link shimVarSimple			Type
hi def link shimVarSpecial			Type
hi def link shimVarBraces			Type
hi def link shimVar					Error
hi def link shimVarNameSimple		Type
hi def link shimVarNameSpecial		Type
hi def link shimVarModOp			Operator
hi def link	shimVarArrayOp			shimVarModOp
hi def link shimVarModAccess		shimVarModOp
hi def link shimVarModCase			shimVarModOp
hi def link shimVarModRemove		Normal
hi def link shimVarModSearchReplace	Normal
hi def link shimVarModSrReplacement	Normal
hi def link shimVarModSubstr		Normal
hi def link shimVarModOption		Normal
hi def link shimVarArrayAccess		Special

" Command substitution
hi def link shimCmdSub				Keyword

" Math expressions
hi def link shimMathOp				Operator
hi def link shimMathBraces			Identifier
hi def link shimMathExpr			Statement
hi def link shimMathVar				Type
hi def link shimMathNum				Number
hi def link	shimMathArrayAccess		Special

" Functions and Blocks
hi def link shimFunction			Type
hi def link shimFunctionName		Function
hi def link shimConditional			Conditional
hi def link shimRepeat				Repeat
hi def link shimBlock				shimSeparator
hi def link shimSubshellOpen		shimSeparator
hi def link shimSubshellClose		shimSeparator
hi def link shimInvertResult		Statement

" Iterators
hi def link	shimFor					Statement
hi def link shimSwitch				Statement
hi def link shimForCStyleBraces		Statement
hi def link shimIterator			Type
hi def link	shimIteratorIn			Statement
hi def link	shimIteratorList		Normal

" Case

hi def link shimCase				Statement
hi def link shimCaseString			Normal
hi def link shimCaseControl			Statement
hi def link shimCaseOption			Statement
hi def link shimCaseOpenPattern		Statement

" Tests
hi def link shimTestBrackets		Statement
hi def link shimTest				String
hi def link shimTestOp				Identifier
hi def link shimTestControl			Identifier

" Errors
hi def link shimSubshellError		Error
hi def link shimDblTestError		Error

" TODO: sync at function definitions instead of reading the whole file?
syn sync fromstart

let b:current_syntax = "bash"
