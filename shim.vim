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

" EXPRESSIONS {{{1
" ================
syn cluster	shimExpression		contains=@shimControl,@shimBlock,shimAssignment,shimCommand,shimComment
syn cluster shimBlock			contains=shimTest,shimOldTest,shimMathTest,shimFor,shimSwitch,shimCase,shimEsac
syn cluster shimControl			contains=shimFunction,shimSubshell,shimRedirect,shimBlock,shimInvertResult,shimConditional,shimRepeat,shimSeparator


" |-> basic command names, variable assignments {{{1
" ==================================================
syn cluster	shimCommandPart		contains=shimSeparator,shimRedirect,shimSubshell,shimComment,@shimString
syn cluster	shimAssignmentValue	contains=shimAssignmentValueArray,shimAssignmentValueString

" ShimCommand: [TOP] Any regular command, function or builtin
"   shimCommand -> Normal
syn region	shimCommand			start="\S"		end="[;|&()]\@=\|$"	contains=@shimCommandPart,shimArgumentList	keepend

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
syn region	shimAssignment	start="\i\+\%(+\?=\|\[\)\@="	matchgroup=shimAssignmentOp	end="[()&;| \n\t]\|+\?="	nextgroup=@shimAssignmentValue	contains=shimAssignmentArrayIndex

" ShimAssignmentArrayIndex: Array element assignment var[5]=elementval
"   brackets -> shimVarArrayBrackets     -> Operator (yellow)
"   index    -> shimAssignmentArrayIndex -> Special (purple)
syn region	shimAssignmentArrayIndex	contained	matchgroup=shimVarArrayBrackets	start="\i\@<=\["	end="\]"	extend	keepend

" ShimAssignmentValueString: A string value for an assignment
" The value itself is not highlighted (contained string elements may be though)
syn region	shimAssignmentValueString	contained	start="=\@<=[^()&|; \t\n]"	end="[();&| \t\n]\@="	contains=@shimString

" ShimAssignmentValueArray: An array value for an assignment arr=(word1 word2 "value 3")
"   braces -> shimVarArrayOp -> Operator (yellow)
" The elements are not highlighted (contained string elements may be though)
syn region	shimAssignmentValueArray	contained	matchgroup=shimVarArrayBrackets	start="=\@<=("	end="[);&|]"	contains=@shimString	extend


" |-> arguments and command line flags {{{1
" =========================================

" ShimArgumentList: The argument list after the command name itself
syn region	shimArgumentList	contained	start="\s"	end="$"		contains=@shimCommandPart,shimFlag,shimArgumentListEnd

" ShimFlag:		A command line flag to the current command (starts with -)
"   shimFlag       -> Identifier (blue)
syn region  shimFlag			contained	matchgroup=shimFlagStart	start="\s\zs-\+"		end="\s\@="	contains=@shimCommandPart,shimFlagValue

" ShimArgumentListEnd: Arguments that are never highlighted as flags
syn region	shimArgumentListEnd	contained	matchgroup=shimFlagStart	start="\s\zs--\ze\s"	end="$"	contains=@shimCommandPart

" ShimFlagValue: A value for a long argument, split by an equals sign
"   shimFlagValue  -> Normal
"   shimFlagEquals -> Operator (yellow)
syn region	shimFlagValue		contained	matchgroup=shimFlagEquals	start="="	end="\s\@="	contains=@shimCommandPart

 
" |-> expression separators {{{1
" ==============================
" ShimSeparator: Any expression separator:
" semicolon, pipe, go to background, logic operators
"   shimSeparator -> Statement
syn match	shimSeparator	"[|&;]\+\s*"	nextgroup=@shimExpression


" |-> redirects {{{1
" ==================
syn cluster	shimRedirLHS	contains=shimRedirLeftStream
syn cluster	shimRedirRHS	contains=shimRedirRightStream,shimRedirFilename,@shimHeredoc

" ShimRedirect: Redirect operator, followed by the redirection target
"   redirection character -> shimRedirect -> Operator (yellow)
syn match	shimRedirect	"<\@<![0-9]*\%(<\|>\+\)\s*"	contains=@shimRedirLHS	nextgroup=@shimRedirRHS	skipwhite

" ShimRedirLeftStream: A redirection source (stream number in front of > and <)
"   shimRedirLeftStream   -> Type (green)
syn match	shimRedirLeftStream		contained	"[^<>]\+[<>]\@="

" ShimRedirRightStream: A target stream for a redirect: >&1
"   shimRedirRightStream  -> Type (green)
syn match	shimRedirRightStream	contained	"<\@<=&\s*\%(-\|[0-9]\+\)"

" ShimRedirFilename: The filename as target for the redirection
syn region	shimRedirFilename		contained	start="[^&<>]"	end="\s\@="	contains=@shimCommandPart


" |-> here documents {{{1
" =======================
syn cluster shimHeredoc			contains=shimHereString,shimHereDocument,shimHereDocumentNE,shimHereDocumentTab,shimHereDocumentTabNE

" ShimHereString: A here string as input <<<"Input String"
"   initiating <<< -> shimHereStringInitiator -> Statement (yellow)
"   string         -> shimHereString          -> Normal
syn region	shimHereString		contained	matchgroup=shimHereStringInitiator	start="<\@<=<<"	end="\s\@="	contains=@shimCommandPart

" ShimHereDocument: A here document started by <<TAG
"   initiating <<TAG -> shimHereDocTerminator -> Keyword (yellow)
"   ending TAG       -> shimHereDocTerminator -> Keyword (yellow)
"   commands / args until newline -> ...
"
" When putting a dash (-) in front of the tag, leading tabs are ignored in
" the heredoc and in front of the terminator. Double-quote the tag to disable
" expansions in the heredoc.
syn region	shimHereDocument		contained	matchgroup=shimHereDocTerminator	start="<\@<=<\z([^" \t|&;()<>]\+\)"		end="^\z1$"		extend	keepend	contains=@shimCommandPart,shimHereDocText
syn region	shimHereDocumentNE		contained	matchgroup=shimHereDocTerminator	start="<\@<=<\"\z([^"]\+\)\""			end="^\z1$"		extend	keepend	contains=@shimCommandPart,shimHereDocTextNE
syn region	shimHereDocumentTab		contained	matchgroup=shimHereDocTerminator	start="<\@<=<-\z([^" \t|&;()<>]\+\)"	end="^\t*\z1$"	extend	keepend	contains=@shimCommandPart,shimHereDocText
syn region	shimHereDocumentTabNE	contained	matchgroup=shimHereDocTerminator	start="<\@<=<-\"\z([^"]\+\)\""			end="^\t*\z1$"	extend	keepend	contains=@shimCommandPart,shimHereDocTextNE

" ShimHereDocText: The text of a normal here document
"   shimHereDocText   -> String (red)
syn region	shimHereDocText		contained	start="^"	end="\%^$"	contains=@shimExpansionInStr

" ShimHereDocTextNE: The text of a quoted here document, in which
" no expansions are executed
"   shimHereDocTextNE -> String (red)
syn region	shimHereDocTextNE	contained	start="^"	end="\%^$"


" |-- strings, special characters {{{1 
" ====================================
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
syn region	shimSqString	contained	extend	matchgroup=shimQuote	start=+'+	end=+'+

" ShimDqString: A string in double quotes
" Can contain escaped characters and variable expansions
"   shimDqString -> String (red)
"   shimQuote    -> Special (purple)
syn region	shimDqString	contained	extend	matchgroup=shimQuote	start=+"+	end=+"+	contains=@shimInDqString


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
syn match	shimVarSimple		contained	"\$[a-zA-Z0-9_]\+"	contains=shimVarSign

" ShimVarSpecial: Quick special variable expansion
"   shimVarSpecial -> Type (green)
syn match	shimVarSpecial		contained	"\$[-$#!@*?]"		contains=shimVarSign

" ShimVarSign: The $-sign in front of the variable name
"   shimVarSign    -> Type (green)
syn match	shimVarSign			contained	"\$"
 

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

" ShimVarModSubstr: An substring ${text:n} from position n to the end
"   colon operator -> shimVarModOp     -> Operator (yellow)
"   given position -> shimVarModSubstr -> Normal
"
" The given position is interpreted as mathematical expression (more below)
" When a negative number (-n) is given, the last n characters are printed
syn region	shimVarModSubstr		contained	matchgroup=shimVarModOp	start=":[-+?]\@!"	end=":\@="	contains=@shimInMathExpr	nextgroup=shimVarModSubstr

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
syn region	shimVarArrayIndex		contained	matchgroup=shimVarArrayBrackets	start="\["	end="\]"	nextgroup=@shimVarModifier

  
" | |-> mathematic expressions {{{1
" =================================
syn cluster	shimMathExpr			contains=shimMathExprDblBraces,shimMathExprBrackets
syn cluster shimInMathExpr			contains=shimMathNum,shimMathBraces,shimMathVar,shimMathOp,@shimExpansion

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

" ShimMathBraces: Braces inside a math expression
"   shimMathBraces -> Identifier (cyan)
syn region	shimMathBraces			contained	start="("	end=")"	contains=@shimInMathExpr	extend	keepend

" ShimMathVar: A variable name (without leading $)
"   shimMathVar -> Type (green)
"
" can be followed by an array access operator
syn match	shimMathVar				contained	"[_a-zA-Z][_a-zA-Z0-9]*"	nextgroup=shimMathArrayIndex

" ShimMathArrayIndex: Accessing an array element by index
"   brackets -> shimVarArrayBrackets -> Operator (yellow)
"   index    -> shimMathArrayIndex   -> Special (purple)
syn region	shimMathArrayIndex		contained	matchgroup=shimVarArrayBrackets	start="\["	end="\]"

" ShimMathOp:  A mathematic operator
"   shimMathOp -> Operator (yellow)
syn match	shimMathOp				contained	"+\|-\|*\|/\|%\|="


" | |-> command substitutions {{{1
" ================================
syn cluster	shimCmdSub			contains=shimCmdSubBacktick,shimCmdSubBraces

" ShimCmdSubBacktick: command substitution in backticks
"   backticks -> shimCmdSub -> Statement (yellow)
syn region	shimCmdSubBacktick	contained	matchgroup=shimCmdSub	start="`"		end="`"	contains=@shimExpression	extend	keepend

" ShimCmdSubBraces:	command substitution in $( ... )
"   braces    -> shimCmdSub -> Statement (yellow)
syn region	shimCmdSubBraces	contained	matchgroup=shimCmdSub	start="\$((\@!"	end=")"	contains=@shimExpression	extend	keepend


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
syn match	shimFunctionName	contained	"[^ \t()<>\\;]\+\s*"

" ShimConditional: A keyword that triggers conditional execution. Must be at
" the front of an expression and can (mostly) be followed by one.
"   shimConditional   -> Conditional (yellow)
syn keyword	shimConditional		if	then	else	fi

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
syn region	shimIteratorList	contained	matchgroup=shimIteratorIn	start="in"	end="[\n;|&]"	contains=@shimString


" |-> tests {{{1
" ==============
syn cluster	shimInTest		contains=@shimString,shimTestOperator,shimTestControl

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
"   shimTestOperator -> Special (purple)
syn match	shimTestOperator	contained	"[() \t\n]\@<=\%(-[a-zA-Z]\{1,2\}\|[<>!=]=\?\|=\~\)[() \t\n]\@=\|||\|&&"

" ShimTestControl: Control operators in a test environment
"   shimTestControl  -> Operator (yellow)
syn match	shimTestControl		contained	"(\|)\|![( \t\n]\@="

 
" |-> case blocks {{{1
" ====================
syn cluster	shimCasePattern		contains=@shimString,shimCaseOption,shimCaseLabelStart,shimComment

" ShimCase: A case statement: case var in ... esac
"   'case' keyword     -> shimCase -> Conditional (yellow)
"
" followed by a string to check and the 'in' keyword
syn keyword	shimCase			case		nextgroup=shimCaseString	skipwhite

" ShimCaseString: The string to check with the case statement
"   string to check    -> shimCaseString -> Normal
syn region	shimCaseString		contained	start="."	matchgroup=shimCaseIn	end="\_s\@<=in\_s\@="	contains=@shimString

" ShimEsac: The esac keyword, terminating a case block
syn keyword	shimEsac			esac


" }}}1

" COMMENTS {{{1
" =============
syn cluster	shimInComment	contains=shimTodo,shimShebang,shimVimline

" ShimComment: A comment that goes until the end of the current line.
"   shimComment -> Comment (Blue)
syn region	shimComment		start="#"		end="$"		contains=@shimInComment		extend	keepend

" ShimShebang: The program to execute this file with
"   shimShebang -> PreProc (purple)
syn region	shimShebang		contained	matchgroup=shimComment	start="\%^#!"	end="$"

" ShimVimline: A vim preprocessor line
"   shimVimline -> PreProc (purple)
syn match	shimVimline		contained	"\svim:\s.*$"

" ShimTodo: An area inside a comment that requires special attention
"   shimTodo -> SpecialComment (purple)
syn region	shimTodo		contained	start=">\|NOTE\|TODO\|FIXME\|BUG\|(C)"	end="$"	contains=shimTodoKeyword

" ShimTodoKeyword: Highlighted special keyword inside a comment
"   shimTodoKeyword -> Todo (yellow bg)
syn keyword	shimTodoKeyword	contained	NOTE	TODO	FIXME	BUG


" }}}1


" Set syntax and highlighting {{{1 
" ================================

" Comments
hi def link shimComment				Comment
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
hi def link shimAssignmentOp		Operator

" Arguments and Flags
hi def link shimFlag				Special
hi def link shimFlagStart			Special
hi def link shimFlagValue			Normal
hi def link shimFlagEquals			Operator

" Strings
hi def link shimEscape				SpecialChar
hi def link shimEscapeVar			SpecialChar
hi def link shimEscapeNewl			Statement
hi def link shimQuote				Special
hi def link shimSqString			String
hi def link shimDqString			String

hi def link shimGlob				Type
hi def link shimHome				Type
hi def link shimCharOptionBrackets	Type
hi def link shimBraceExpBraces		Type
hi def link shimHomeUsername		Special
hi def link shimCharOption			Special
hi def link shimBraceExp			Special
hi def link shimBraceExpOp			Operator

" Redirections
hi def link shimRedirect			Operator
hi def link shimRedirLeftStream		Type
hi def link shimRedirRightStream	Type
hi def link shimRedirFilename		Special

" Here documents
hi def link shimHereStringInitiator	Statement
hi def link shimHereDocTerminator	Keyword
hi def link shimHereDocText			String
hi def link shimHereDocTextNE		String

" Variables
hi def link shimVarSign				Statement
hi def link shimVarSimple			Type
hi def link shimVarSpecial			Type
hi def link shimVarBraces			shimVarSign
hi def link shimVar					Error
hi def link shimVarNameSimple		shimVarSimple
hi def link shimVarNameSpecial		shimVarSpecial
hi def link shimVarArrayBrackets	Identifier
hi def link shimVarArrayIndex		Normal
hi def link shimVarModOp			Operator
hi def link shimVarAccessType		shimVarModOp
hi def link shimVarModCase			Identifier
hi def link shimVarModRemove		Normal
hi def link shimVarModSearchReplace	Normal
hi def link shimVarModSrReplacement	Normal
hi def link shimVarModSubstr		Normal
hi def link shimVarModOption		Normal

" Command substitution
hi def link shimCmdSub				Statement

" Math expressions
hi def link shimMathOp				Operator
hi def link shimMathBraces			Identifier
hi def link shimMathExpr			Statement
hi def link shimMathVar				Type
hi def link shimMathNum				Number
hi def link shimMathArrayIndex		shimVarArrayIndex

" Functions and Blocks
hi def link shimFunction			Type
hi def link shimFunctionName		Function
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
hi def link shimTestOperator		Special
hi def link shimTestControl			Operator

" TODO: sync at function definitions instead of reading the whole file?
syn sync fromstart

let b:current_syntax = "bash"
