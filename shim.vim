" Vim Syntax File
" vim: ts=4 noet sts=0 fdm=marker
" Language:		shell (sh) bash (sh)
" Maintainer:	Maximilian Wende <dasisdormax@secure.mailbox.org>
" Version:		0.1.0




" Preparation {{{1
" ================

" quit if a syntax definition is already loaded
" ---------------------------------------------
if exists("b:current_syntax")
  finish
endif


" sh syntax is case sensitive
" ---------------------------
syn case match


" }}}1

" EXPRESSIONS {{{1
" ================
syn cluster	shimExpression		contains=@shimControl,@shimBlock,@shimBuiltin,shimAssignment,shimCommand,shimComment
syn cluster shimBlock			contains=shimTest,shimOldTest,shimMathTest,shimFor,shimSwitch,shimCase,shimEsac
syn cluster shimControl			contains=shimFunction,shimSubshell,shimRedirStart,shimBlock,shimInvertResult,shimConditional,shimRepeat,shimSeparator


" |-> basic commands {{{1
" =======================
syn cluster	shimCommandPart		contains=shimSeparator,shimRedirStart,shimSubshell,@shimStringList

" ShimCommand: [TOP] Any regular command, function or builtin
"   shimCommand         -> Function (cyan)
syn region	shimCommand			start="\S"		end="[;|&()]\@=\|$"	contains=@shimCommandPart,shimArgumentList	keepend


" |-> arguments and command line flags {{{1
" =========================================

" ShimArgumentList: The argument list after the command name itself
"   shimArgumentList    -> Normal
syn region	shimArgumentList	contained	start="\s"	end="$"		contains=@shimCommandPart,shimFlag,shimArgumentListEnd

" ShimFlag:		A command line flag to the current command (starts with -)
"   shimFlag            -> Special (purple)
syn region  shimFlag			contained	matchgroup=shimFlagStart	start="\s\zs-\+"		end="\s\@="	contains=@shimCommandPart,shimFlagValue

" ShimArgumentListEnd: Arguments that are never highlighted as flags
"   leading --          -> shimFlag -> Special (purple)
"   shimArgumentListEnd -> Normal
syn region	shimArgumentListEnd	contained	matchgroup=shimFlagStart	start="\s\zs--\ze\s"	end="$"	contains=@shimCommandPart

" ShimFlagValue: A value for a long argument, split by an equals sign
"   value       -> shimFlagValue  -> Normal
"   equals sign -> shimFlagEquals -> Operator (yellow)
syn region	shimFlagValue		contained	matchgroup=shimFlagEquals	start="="	end="\s\@="	contains=@shimCommandPart

 
" |-> expression separators {{{1
" ==============================
" ShimSeparator: Any expression separator:
" semicolon, pipe, go to background, logic operators
"   shimSeparator -> Statement
syn match	shimSeparator	"[|&;]\+\s*"	nextgroup=@shimExpression


" |-> functions and blocks {{{1
" =============================

" ShimFunction: function declaration: funname () [block]
"   braces  -> shimFunction     -> Type (green)
"
" matches the pattern: 'funname ()' with variable whitespace inbetween
" the function name is highlighted specifically as shimFunctionName
syn match	shimFunction		"[^ \t()<>\\;]\+\s*(\s*)"	contains=shimFunctionName

" ShimFunctionName: highlight the function name
"   funname -> shimFunctionName -> Function (cyan)
syn match	shimFunctionName	contained	"[^ \t()<>\\;]\+"

" ShimConditional: A keyword that triggers conditional execution. Must be at
" the front of an expression and can (mostly) be followed by one.
"   shimConditional   -> Conditional (yellow)
syn keyword	shimConditional		if	then	elif	else	fi

" ShimRepeat: A keyword that causes commands to be executed repeatedly
"   shimRepeat        -> Repeat (yellow)
syn keyword	shimRepeat			while	do	done

" ShimInvertResult: The result-inverting ! operator
"   shimInvertResult  -> Operator (yellow)
syn match	shimInvertResult	"!\s\+"

" ShimBlock: Curly braces, which combine multiple expressions into a block
"   shimBlock         -> shimSeparator -> Statement (yellow)
syn match	shimBlock			"[{}][\n\t ;|&()]\@="

" ShimSubshell: Open or close a subshell:
"   shimSubshell      -> shimSeparator -> Statement (yellow)
syn match	shimSubshell		"((\@!\|)"


" |-> variable assignments {{{1
" =============================
syn cluster	shimAssignmentValue	contains=shimAssignmentValueArray,shimAssignmentValueString

" ShimAssignment: [TOP] A variable assignment in the form VAR_NAME=value.
"   variable name -> shimAssignment   -> Type (Green)
"   equals sign   -> shimAssignmentOp -> Operator (yellow)
"   value  -> shimAssignmentValueString || shimAssignmentValueArray -> ...
"
" Note that they can be followed by another assignment or a command (in that
" case, the assigned variable would only be appended to the environment of
" that command).
"
" To achieve that behaviour, this is a quasi top-level structure. A value may
" or may not follow after the equals sign
syn region	shimAssignment	start="\i\+\ze\%(+\?=\|\[\)"	matchgroup=shimAssignmentOp	end="\s\@=\|+\?="	nextgroup=@shimAssignmentValue	contains=shimAssignmentArrayIndex

" ShimAssignmentArrayIndex: Array element assignment var[5]=elementval
"   brackets -> shimVarArrayBrackets     -> Operator (yellow)
"   index    -> shimAssignmentArrayIndex -> Special (purple)
syn region	shimAssignmentArrayIndex	contained	matchgroup=shimVarArrayBrackets	start="\["	end="\]"	extend	keepend contains=@shimExpansion

" ShimAssignmentValueString: A string value for an assignment
" The value itself is not highlighted (contained string elements may be though)
syn region	shimAssignmentValueString	contained	start="[^()&|; \t\n]"	end="[()&|; \t\n]\@="	contains=@shimCommandPart

" ShimAssignmentValueArray: An array value for an assignment arr=(word1 word2 "value 3")
"   braces -> shimVarArrayOp -> Operator (yellow)
" The elements are not highlighted (contained string elements may be though)
syn region	shimAssignmentValueArray	contained	matchgroup=shimVarArrayBrackets	start="("	end=")\|[|&;]\@="	contains=@shimStringList	extend

" |-> redirects {{{1
" ==================
syn cluster shimRedirect		contains=shimRedirDefault,@shimHereDoc

" ShimRedirStart: Start of a redirect, optionally containing a stream number
syn match	shimRedirStart		"[0-9]*\ze[<>]"	nextgroup=@shimRedirect

" ShimRedirDefault: A redirect from or to a file or stream
syn region	shimRedirDefault	start="\%(<<\@!\|>\{1,2\}\)"	end="&\?\s*"	nextgroup=shimRedirTarget	extend
"
" ShimRedirTarget: The redirection target
"   shimRedirTarget  -> Constant (red)
syn region	shimRedirTarget		contained	start=""	end="\s\@="	contains=@shimCommandPart



" |-> here documents {{{1
" =======================
syn cluster shimHereDoc			contains=shimHereString,shimHereDocStart,shimHereDocStartTab

" ShimHereString: A here string as input <<<"Input String"
"   initiating <<< -> shimHereStringInitiator -> Statement (yellow)
"   string         -> shimHereString          -> Normal
syn region	shimHereString		contained	matchgroup=shimHereStringInitiator	start="<<<\s*"	end="\_s\@="	contains=@shimCommandPart

" ShimHereDocStart: The leading "<<" that starts a heredoc
syn match	shimHereDocStart	contained	"<<\s*<\@!"	nextgroup=shimHereDocSq,shimHereDocDq
syn match	shimHereDocStartTab	contained	"<<-\s*"	nextgroup=shimHereDocSqTab,shimHereDocDqTab

" ShimHereDoc: A here document started by <<TAG
"   initiating <<TAG -> shimHereDocTerminator -> Keyword (yellow)
"   ending TAG       -> shimHereDocTerminator -> Keyword (yellow)
"   commands / args until newline -> ...
"
" When putting a dash (-) in front of the tag, leading tabs are ignored in
" the heredoc and in front of the terminator. Double-quote the tag to disable
" expansions in the heredoc.
syn region	shimHereDocSq		contained	matchgroup=shimHereDocSqTerminator	start='"\z([^"]\+\)"'			end="^\z1$"		extend	keepend	contains=@shimCommandPart,shimHereDocSqText
syn region	shimHereDocDq		contained	matchgroup=shimHereDocDqTerminator	start='\z([^" \t|&;()<>]\+\)'	end="^\z1$"		extend	keepend	contains=@shimCommandPart,shimHereDocDqText
syn region	shimHereDocSqTab	contained	matchgroup=shimHereDocSqTerminator	start='"\z([^"]\+\)"'			end="^\t*\z1$"	extend	keepend	contains=@shimCommandPart,shimHereDocSqText
syn region	shimHereDocDqTab	contained	matchgroup=shimHereDocDqTerminator	start='\z([^" \t|&;()<>]\+\)'	end="^\t*\z1$"	extend	keepend	contains=@shimCommandPart,shimHereDocDqText

" ShimHereDocSqText: The text of a here document, in which expansions are
" ignored just as in single-quoted strings
"   shimHereDocSqText   -> shimSqString
syn region	shimHereDocSqText	contained	start="^"	end="\%^$"

" ShimHereDocDqText: The text of a here document, expansions are handled like
" in a double-quoted string.
"   shimHereDocDqText   -> shimDqString
syn region	shimHereDocDqText	contained	start="^"	end="\%^$"	contains=@shimExpansionInStr


" |-- strings, special characters {{{1 
" ====================================
syn cluster	shimStringList		contains=@shimString,shimInnerComment
syn cluster	shimString			contains=shimSqString,shimDqString,@shimEscape,@shimPattern,@shimExpansion,shimBraceExp
syn cluster	shimPattern			contains=shimGlob,shimCharOption,shimHome
syn cluster	shimExpansion		contains=@shimExpansionInStr
syn cluster shimExpansionInStr	contains=@shimVarExp,@shimCmdSub,@shimMathExpr


" | |-> quotes and escapes {{{1
" =============================
syn cluster shimEscape		contains=shimEscape,shimEscapeNewl
syn cluster shimInDqString	contains=shimEscapeVar,shimEscapeNewl,@shimExpansionInStr

" ShimEscape: An escaped character, outside of a double-quoted string
"   shimEscape -> SpecialChar (purple)
syn match	shimEscape		contained	extend	"\\."

" ShimEscapeVar: An escaped \ $ ` inside a double-quoted string
"   shimEscapeVar -> SpecialChar (purple)
syn match	shimEscapeVar	contained	extend	"\\[\\$`]"

" ShimEscapeNewl: An escaped newline character, continuing the
" command on the next line
"   shimEscapeNewl -> Statement (yellow)
syn match	shimEscapeNewl	contained	extend	"\\\n"

" ShimSqString: A string in single quotes, everything is taken literally
"   shimSqString -> String (red)
"   shimQuote    -> Special (purple)
syn region	shimSqString	contained	extend	matchgroup=shimQuote	start=+'+	end=+'+	transparent	contains=NONE

" ShimDqString: A string in double quotes
" Can contain escaped characters and variable expansions
"   shimDqString -> String (red)
"   shimQuote    -> Special (purple)
syn region	shimDqString	contained	extend	matchgroup=shimQuote	start=+"+	end=+"+	transparent	contains=@shimInDqString


" | |-> curly brace expansion {{{1 
" ================================

" ShimBraceExp: a curly brace expansion, such as echo {01..15}
"   braces -> shimBraceExpOp -> Special (purple)
"   values -> shimBraceExp   -> Constant (red)
syn region	shimBraceExp	contained	matchgroup=shimBraceExpBraces	start="{"	end="\s\@=\|}"	contains=@shimString,shimBraceExpOp	oneline

" ShimBraceExpOp: An operator inside a curly brace expansion .. or ,
"   shimBraceExpOp -> Special (purple)
syn match	shimBraceExpOp	contained	"\.\.\|,"


" | |-> patterns and path expansions {{{1
" =======================================

" ShimGlob: The Globbing * and ?
"   shimGlob         -> Type (green)
syn match	shimGlob			contained	"\*\|?"

" ShimHome: Tilde (~) as home directory shortcut, optionally with username
"   shimHome         -> Type (green)
syn match	shimHome			contained	"\~\w*[0-9]\@!"	contains=shimHomeUsername

" ShimHomeUsername: An optional username, whose home directory is expanded
"   shimHomeUsername -> Special (purple)
syn match	shimHomeUsername	contained	"\w\+"

" ShimCharOption: Multi-character option during path expansion
"   shimCharOption   -> Type (green)
syn region	shimCharOption		contained	matchgroup=shimCharOptionBrackets	start="\[" end="\]"	oneline	contains=@shimEscape


" | |-> quick variable expansions {{{1
" ====================================
syn cluster	shimVarExp			contains=shimVarSimple,shimVarSpecial,shimVar

" ShimVarSimple: Quick variable expansion
"   shimVarSimple  -> Type (green)
syn match	shimVarSimple		contained	"\$[a-zA-Z0-9_]\+"	contains=shimVarDollar

" ShimVarSpecial: Quick special variable expansion
"   shimVarSpecial -> Type (green)
syn match	shimVarSpecial		contained	"\$[-$#!@*?]"		contains=shimVarDollar

" ShimVarDollar: The $-sign in front of the variable name
"   shimVarDollar    -> Type (green)
syn match	shimVarDollar		contained	"\$"
 

" | |-> full variable expansions {{{1
" ===================================
syn cluster shimVarModifier		contains=shimVarModCase,shimVarModRemove,shimVarModSearchReplace,shimVarModSubstr,shimVarModOption,shimVarArrayIndex
syn cluster	shimVarName			contains=shimVarNameSimple,shimVarNameSpecial

" ShimVar: full variable expansion ${var...}
"   Content  -> shimVar       -> Error (red bg)
"   ${ and } -> shimVarBraces -> Type  (green)
"
" Can contain special modifiers for array access, case modification, etc.
"
" Uses the Error highlighting type to mark bad modifiers. A correct expansion
" starts with the shimVarAccessType modifier (see there for more info)
syn region	shimVar				contained	matchgroup=shimVarBraces	start="\${"	end="}"	contains=shimVarAccessType	extend	keepend

" ShimVarAccessType: Variable access type (normal, indirection, length)
"   shimVarAccessType -> Operator (yellow)
"
" When writing the variable name directly, this is a zero-width match.
" Otherwise ! stands for indirection and # for length access
"
" Followed by the variable name: shimVarName{Simple,Special}
syn match	shimVarAccessType	contained	"\%(\${\)\@<=\%(\%(!\|##\@!\)[!}]\@!\)\?"	nextgroup=@shimVarName

" ShimVarNameSimple: A variable name inside an expansion
" ShimVarNameSpecial: A special variable name inside an expansion
"   shimVarNameSimple  -> Type (green)
"   shimVarNameSpecial -> Type (green)
"
" Both can be followed by modifiers
syn match	shimVarNameSimple	contained	"[a-zA-Z0-9_]\+"		nextgroup=@shimVarModifier
syn match	shimVarNameSpecial	contained	"[-$#!@*?]"				nextgroup=@shimVarModifier

" ShimVarModCase: Case modification operators ^ ~ ,
"   shimVarModCase -> shimVarModOp -> Operator (yellow)
"
" Operators: ^ Uppercase     ~ Switch case     , Lowercase
"
" When using the operator once, only the first letter is changed.
" To change the whole string, use the operator twice.
syn match	shimVarModCase			contained	"\([\^,~]\)\1\?"

" ShimVarModRemove: Remove substring operators % #
"   operators      -> shimVarModOp     -> Operator (yellow)
"   search pattern -> shimVarModRemove -> Normal
"
" Operators: # Remove from front    % Remove from back
"
" When using the operator once, the shortest match is removed (when using
" glob-stars). To remove the longest match, use the operator twice.
syn region	shimVarModRemove		contained	matchgroup=shimVarModOp	start="\([%#]\)\1\?"rs=e	end="}"	contains=@shimString

" ShimVarModSearchReplace: Search and replace operator ${var/search/replace}
"   delimiting slashes -> shimVarModOp            -> Operator (yellow)
"   search string      -> shimVarModSearchReplace -> Normal
"
" By default, only the first match is replaced. To replace all matches, use
" a second slash between variable and search string. Note that the search /
" replace operator always uses the longest match.
"
" When the delimiter of search and replacement is missing, the replacement is
" assumed to be an empty string.
syn region	shimVarModSearchReplace	contained	matchgroup=shimVarModOp	start="//\?"rs=e		end="/"	contains=@shimString	nextgroup=shimVarModSrReplacement

" ShimVarModSrReplacement: The replacement string
"   replacement        -> shimVarModSrReplacement -> Normal
"
" Note that this matches everything until the closing curly braces
syn match	shimVarModSrReplacement	contained	"\_.*"	contains=@shimString

" ShimVarModSubstr: A substring ${text:n} from position n to the end
"   colon operator -> shimVarModOp     -> Operator (yellow)
"   given position -> shimVarModSubstr -> Normal
"
" The given position is interpreted as mathematical expression (more below)
" When a negative number (-n) is given, the last n characters are printed
syn region	shimVarModSubstr		contained	matchgroup=shimVarModOp	start=":[-+?]\@!"	end=":"	contains=@shimInMathExpr	nextgroup=shimVarModSubstrLength	keepend

" ShimVarModSubstrLength: A length specifier for a substring ${text:start:len}
"   length -> shimVarModSubstrLength -> Normal
syn region	shimVarModSubstrLength	contained	start="."	end="}"	contains=@shimInMathExpr

" ShimVarModOption: Optional default, alternative, error values
"   operators    -> shimVarModOp     -> Operator (yellow)
"   option value -> shimVarModOption -> Normal
"
" Operators:
"   - Default:     Use the option value when $var is unset, otherwise $var
"   = Assign:      Assign $var = option when $var is unset
"   + Alternative: Use the option value when $var is set, otherwise ''
"   ? Error:       Exit with option as error text when $var is unset
"
" With a preceding colon (:), empty strings are also considered unset
syn region	shimVarModOption		contained	matchgroup=shimVarModOp	start=":\?[-+?=]"	end="}"	contains=@shimString

" ShimVarArrayIndex: array element access by index
"   Brackets -> shimVarArrayBrackets -> Operator (yellow)
"   Index    -> shimVarArrayIndex    -> Normal
syn region	shimVarArrayIndex		contained	matchgroup=shimVarArrayBrackets	start="\["	end="\]"	contains=@shimExpansion	nextgroup=@shimVarModifier


" | |-> mathematic expressions {{{1
" =================================
syn cluster	shimMathExpr			contains=shimMathExprDblBraces,shimMathExprBrackets
syn cluster shimInMathExpr			contains=shimMathNum,shimMathVar,shimMathBraces,shimMathSeparator,shimMathOp,@shimExpansion

" ShimMathExprDblBraces: A mathematic expression $(( ... ))
"   braces   -> shimMathExpr -> Statement (yellow)
syn region	shimMathExprDblBraces	contained	matchgroup=shimMathExpr	start="\$(("	end="))"	contains=@shimInMathExpr	extend	keepend

" ShimMathExprBrackets: $[ ... ], this is considered deprecated, however
"   brackets -> shimMathExpr -> Statement (yellow)
syn region	shimMathExprBrackets	contained	matchgroup=shimMathExpr	start="\$\["	end="\]"	contains=@shimInMathExpr	extend	keepend

" ShimMathTest: A mathematic test (( ... ))
"   braces   -> shimMathExpr -> Statement (yellow)
syn region	shimMathTest			matchgroup=shimMathExpr	start="(("	end="))"	contains=@shimInMathExpr	extend	keepend

" ShimMathNum: An integer number
"   shimMathNum -> Number (red)
syn match	shimMathNum				contained	"[0-9]\+"

" ShimMathSeparator: separating commas in a math expression
"   shimMathSeparator -> Operator (yellow)
syn match	shimMathSeparator		contained	"[,;&|]"

" ShimMathBraces: Braces indicating a mathematical sub-expression
"   shimMathBraces -> Special (purple)
syn region	shimMathBraces			contained	start="("	end=")"	contains=@shimInMathExpr	extend	keepend

" ShimMathVar: A variable name (without leading $)
"   shimMathVar -> Type (green)
"
" can be followed by an array access operator
syn match	shimMathVar				contained	"[_a-zA-Z][_a-zA-Z0-9]*"	nextgroup=shimMathArrayIndex

" ShimMathArrayIndex: Accessing an array element by index
"   brackets -> shimVarArrayBrackets -> Operator (yellow)
"   index    -> shimMathArrayIndex   -> Special (purple)
syn region	shimMathArrayIndex		contained	matchgroup=shimVarArrayBrackets	start="\["	end="\]"	contains=@shimExpansion

" ShimMathOp:  A mathematic operator
"   shimMathOp -> Identifier
syn match	shimMathOp				contained	"[-+*/%#=><]"


" | |-> command substitutions {{{1
" ================================
syn cluster	shimCmdSub			contains=shimCmdSubBacktick,shimCmdSubBraces

" ShimCmdSubBacktick: command substitution in backticks
"   backticks -> shimCmdSub -> Statement (yellow)
syn region	shimCmdSubBacktick	contained	matchgroup=shimCmdSub	start="`"		end="`"	contains=@shimExpression	extend	keepend

" ShimCmdSubBraces:	command substitution in $( ... )
"   braces    -> shimCmdSub -> Statement (yellow)
syn region	shimCmdSubBraces	contained	matchgroup=shimCmdSub	start="\$((\@!"	end=")"	contains=@shimExpression	extend	keepend


" |-> variable iteration (for, switch) {{{1
" =========================================

" ShimFor: A for loop, followed by either an iterator or a c-style loop
"   shimFor    -> Repeat (yellow)
syn match	shimFor				"for\%(\s\+\|\%(((\)\@=\)"	nextgroup=shimForCStyle,shimIterator

" ShimSwitch: A switch statement
"   shimSwitch -> Statement (yellow)
syn match	shimSwitch			"switch\s\+"	nextgroup=shimIterator

" ShimForCStyle: for (( init; break; step ))
"   braces     -> shimForCStyleBraces -> Statement (yellow)
"
" the content is treated as mathematical statements
syn region	shimForCStyle		contained	matchgroup=shimForCStyleBraces	start="(("	end="))"	contains=@shimInMathExpr	extend	keepend

" ShimIterator: The iteration variable name (without $)
"   varname -> shimIterator -> Type (green)
syn match	shimIterator		contained	"[a-zA-Z_][a-zA-Z_0-9]*\s*"	nextgroup=shimIteratorList

" ShimIteratorList: The list of strings to be iterated over, started with 'in'
"   'in' keyword -> shimIteratorIn   -> Keyword (yellow)
"   string list  -> shimIteratorList -> Normal
"
" The list can be omitted, which will cause $@ to be used as the list
syn region	shimIteratorList	contained	matchgroup=shimIteratorIn	start="in"	end="[;|&]\|$"	contains=@shimStringList


" |-> tests {{{1
" ==============
syn cluster	shimInTest		contains=@shimStringList,shimTestOperator,shimTestControl

" ShimTest: A test started with the double bracket operator
"   brackets -> shimTestBrackets -> Operator (yellow)
"   content  -> shimTest         -> Normal
syn region	shimTest		matchgroup=shimTestBrackets	start="\[\[[\t\n (]\@="	end="[\t\n )]\@<=\]\]"	contains=@shimInTest	extend	keepend

" ShimOldTest: A test started with a single bracket
"   brackets -> shimTestBrackets -> Operator (yellow)
"   content  -> shimOldTest      -> Normal
"
" Note that the old test does not go across command boundaries (pipes,
" logic operators, semicolon, newline), so no extend attribute
syn region	shimOldTest		matchgroup=shimTestBrackets	start="\[\s"			end="\%([\n();&|]\@=\|\]\)"	contains=@shimInTest	keepend

" ShimTestOperator: Operators in a test environment
"   shimTestOperator -> Identifier (cyan)
syn match	shimTestOperator	contained	"[() \t\n]\@<=\%(-[a-zA-Z]\{1,2\}\|[<>!=][~=]\?\)[() \t\n]\@=\|||\|&&"

" ShimTestControl: Control operators in a test environment
"   shimTestControl  -> Operator (yellow)
syn match	shimTestControl		contained	"[()]"

 
" |-> case blocks {{{1
" ====================

" ShimCase: A case statement: case var in ... esac
"   'case' keyword     -> shimCase -> Conditional (yellow)
"
" followed by a string to check and the 'in' keyword
syn keyword	shimCase			case		nextgroup=shimCaseString	skipwhite

" ShimCaseString: The string to check with the case statement
"   string to check    -> shimCaseString -> Normal
syn region	shimCaseString		contained	start="."	matchgroup=shimCaseIn	end="\<in\>"	contains=@shimStringList

" ShimEsac: The esac keyword, terminating a case block
syn keyword	shimEsac			esac


" }}}1

" BUILTINS {{{1
" =============
syn cluster	shimBuiltin				contains=shimBuiltinVar,shimBuiltinExec,shimBuiltinBreak,@shimBuiltinLongVariants
syn cluster	shimBuiltinLongVariants	contains=shimBuiltinFunction,shimBuiltinTest,shimBuiltinLet
syn cluster	shimBuiltinVarArgs		contains=shimFlag,shimBuiltinVarVarname,@shimCommandPart

" |-> variable declaration {{{1
" =============================

" ShimBuiltinVar: A builtin related to variables
"   shimBuiltinVar -> Statement (yellow)
"
" The arguments consist of flags and variable names with optional assignments
syn keyword	shimBuiltinVar	declare	local	export	unset	readonly	read	shopt	nextgroup=shimBuiltinVarArgList	skipwhite

" ShimBuiltinVarArgList: The argument list of a variable-related builtin
"   shimBuiltinVarArgList -> Normal
syn region	shimBuiltinVarArgList	contained	start="."	end="[;|&]\@=\|$"	contains=@shimBuiltinVarArgs	keepend

" ShimBuiltinVarVarname: The variable name, optionally with an assignment
"   variable name -> shimBuiltinVarVarname -> Type (green)
"   equals sign   -> shimAssignmentOp      -> Operator (yellow)
"
" The assigned value uses the existing shimAssignmentValue* classes
syn region	shimBuiltinVarVarname	contained	start="\i"	matchgroup=shimAssignmentOp	end="\s\@=\|="	contains=@shimCommandPart	nextgroup=@shimAssignmentValue


" |-> exec commands {{{1
" ======================

" ShimBuiltinExec: Any exec builtin followed by a regular command
"   shimBuiltinExec -> Statement (yellow)
syn keyword	shimBuiltinExec	exec	eval	command	builtin


" |-> break commands {{{1
" =======================

" ShimBuiltinBreak: break and control commands
"   shimBuiltinBreak    -> Statement (yellow)
syn keyword	shimBuiltinBreak	break	continue	return	exit	shift	nextgroup=shimBuiltinBreakArg	skipwhite

" ShimBuiltinBreakArg: Argument (number) to a break command
"   shimBuiltinBreakArg -> Number (red)
syn match	shimBuiltinBreakArg	contained	"\d\+"


" |-> long command versions {{{1
" ==============================

" ShimBuiltinFunction: The function keyword, in 'function funname { ... }'
"   shimBuiltinFunction -> Keyword (yellow)
syn keyword	shimBuiltinFunction	function	nextgroup=shimBuiltinFunctionName,shimFunction	skipwhite

" ShimBuiltinFunctionName: The function name
"   shimBuiltinFunctionName -> shimFunctionName -> Underlined (purple)
syn match	shimBuiltinFunctionName	contained	"[^ \t()<>\\;]\+\%(\s*(\)\@!"

" ShimBuiltinTest: The test builtin
"   keyword -> shimBuiltinTestKeyword -> Statement (yellow)
"   content -> shimBuiltinTest        -> Normal
syn region	shimBuiltinTest		matchgroup=shimBuiltinTestKeyword	start="test\ze\_s"	end="[();|&]\@=\|$"	contains=@shimInTest,@shimCommandPart	keepend

" ShimBuiltinLet: The let builtin
"   keyword -> shimBuiltinLetKeyword  -> Statement (yellow)
"   content -> shimBuiltinLet         -> Normal
"
" Note that each single argument is evaluated as separate expression
syn region	shimBuiltinLet		matchgroup=shimBuiltinLetKeyword	start="let\ze\_s"	end="[();|&]\@=\|$"	contains=shimBuiltinLetExpr,@shimCommandPart

" ShimBuiltinLetExpr: A single mathematical expression in a let statement
"   quotes     -> shimQuote -> Special (purple)
"   expression -> Normal
syn region	shimBuiltinLetExpr	contained	matchgroup=shimQuote	start=+\z(['"]\)+	end=+\z1+	contains=@shimInDqString,@shimInMathExpr	extend	keepend


" }}}1

" COMMENTS {{{1
" =============
syn cluster	shimInComment		contains=shimTodo,shimShebang,shimVimline

" ShimComment: A comment that goes until the end of the current line.
"   shimComment -> Comment (Blue)
syn region	shimComment						start="#"		end="$"	contains=@shimInComment	extend	keepend

" ShimInnerComment: An inner comment (# only at the beginning of a word)
syn region	shimInnerComment	contained	start="\s\zs#"	end="$"	contains=@shimInComment	extend	keepend

" ShimShebang: The program to execute this file with
"   shimShebang -> PreProc (purple)
syn region	shimShebang			contained	matchgroup=shimComment	start="\%^#!"	end="$"

" ShimVimline: A vim preprocessor line
"   shimVimline -> PreProc (purple)
syn match	shimVimline			contained	"\svim:\s.*$"

" ShimTodo: An area inside a comment that requires special attention
" Use > to highlight continuation lines
"   shimTodo -> SpecialComment (purple)
syn region	shimTodo			contained	start="#\s*\zs>\|NOTE\|TODO\|FIXME\|BUG\|(C)"	end="$"	contains=shimTodoKeyword

" ShimTodoKeyword: Highlighted special keyword inside a comment
"   shimTodoKeyword -> Todo (yellow bg)
syn keyword	shimTodoKeyword		contained	NOTE	TODO	FIXME	BUG


" }}}1


" Set syntax and highlighting {{{1 
" ================================

" Comments
hi def link shimComment				Comment
hi def link shimInnerComment		Comment
hi def link shimShebang				PreProc
hi def link shimVimline				PreProc
hi def link shimTodo				SpecialComment
hi def link shimTodoKeyword			Todo

" Basic Expressions
hi def link shimSeparator			Statement
hi def link shimCommand				Function
hi def link shimArgumentList		Normal
hi def link shimArgumentListEnd		Normal
hi def link shimAssignment			Type
hi def link shimAssignmentArrayIndex	shimVarArrayIndex
hi def link shimAssignmentOp		SpecialChar

" Arguments and Flags
hi def link shimFlag				Special
hi def link shimFlagStart			Special
hi def link shimFlagValue			Normal
hi def link shimFlagEquals			Operator

" Strings
hi def link shimEscape				SpecialChar
hi def link shimEscapeVar			SpecialChar
hi def link shimEscapeNewl			SpecialChar
hi def link shimSqString			Normal
hi def link shimDqString			Normal
hi def link shimQuote				SpecialChar

hi def link shimGlob				Type
hi def link shimHome				String
hi def link shimCharOptionBrackets	Type
hi def link shimBraceExpBraces		Type
hi def link shimHomeUsername		String
hi def link shimCharOption			String
hi def link shimBraceExp			String
hi def link shimBraceExpOp			Operator

" Redirections
hi def link shimRedirStart			Type
hi def link shimRedirDefault		Operator
hi def link shimRedirTarget			Constant

" Here documents
hi def link shimHereStringInitiator	shimRedirDefault
hi def link shimHereDocStart		shimRedirDefault
hi def link shimHereDocStartTab		shimRedirDefault
hi def link shimHereDocSqTerminator	shimQuote
hi def link shimHereDocDqTerminator	shimQuote
hi def link shimHereDocDqText		shimDqString
hi def link shimHereDocSqText		shimSqString

" Variable Expansions
hi def link shimVarDollar			Identifier
hi def link shimVarSimple			Identifier
hi def link shimVarSpecial			Identifier
hi def link shimVarBraces			Constant
hi def link shimVar					Error
hi def link shimVarNameSimple		shimVarSimple
hi def link shimVarNameSpecial		shimVarSpecial
hi def link shimVarArrayBrackets	SpecialChar
hi def link shimVarArrayIndex		Normal
hi def link shimVarModOp			Operator
hi def link shimVarAccessType		Type
hi def link shimVarModCase			Operator
hi def link shimVarModRemove		Normal
hi def link shimVarModSearchReplace	Normal
hi def link shimVarModSrReplacement	Normal
hi def link shimVarModSubstr		Normal
hi def link shimVarModOption		Normal

" Command substitution
hi def link shimCmdSub				Statement

" Math expressions
hi def link shimMathExprDblBraces	Normal
hi def link shimMathExprBrackets	Normal
hi def link shimMathExpr			Constant
hi def link shimMathSeparator		Constant
hi def link shimMathVar				shimVarNameSimple
hi def link shimMathOp				Operator
hi def link shimMathBraces			Statement
hi def link shimMathNum				Normal
hi def link shimMathArrayIndex		shimVarArrayIndex

" Functions and Blocks
hi def link shimFunction			Type
hi def link shimFunctionName		Underlined
hi def link shimConditional			Conditional
hi def link shimRepeat				Repeat
hi def link shimBlock				shimSeparator
hi def link shimSubshell			shimSeparator
hi def link shimInvertResult		Operator

" Iterators
hi def link shimFor					Repeat
hi def link shimSwitch				Statement
hi def link shimForCStyleBraces		Statement
hi def link shimIterator			Type
hi def link shimIteratorIn			Keyword
hi def link shimIteratorList		Normal

" Case

hi def link shimCase				Conditional
hi def link shimEsac				Conditional
hi def link shimCaseString			Normal
hi def link shimCaseIn				Keyword

" Tests
hi def link shimTestBrackets		Statement
hi def link shimTest				Normal
hi def link shimOldTest				Normal
hi def link shimTestOperator		Function
hi def link shimTestControl			Operator

" Builtins
hi def link shimBuiltinVar			Statement
hi def link shimBuiltinVarArgList	Normal
hi def link shimBuiltinVarVarname	Type
hi def link shimBuiltinExec			Statement
hi def link shimBuiltinBreak		Statement
hi def link shimBuiltinBreakArg		Number
hi def link shimBuiltinFunction		Keyword
hi def link shimBuiltinFunctionName	shimFunctionName
hi def link shimBuiltinTestKeyword	Statement
hi def link shimBuiltinTest			Normal
hi def link shimBuiltinLetKeyword	Statement
hi def link shimBuiltinLet			Normal

" TODO: sync at function definitions instead of reading the whole file?
syn sync fromstart

let b:current_syntax = "bash"
