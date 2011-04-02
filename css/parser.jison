
%lex

unicode    "\"[0-9a-f]{1,4}
latin1     [¡-ÿ]
escape     {unicode}|"\"[ -~¡-ÿ]
char       {escape}|{latin1}|[ !#$%&(-~]
nmstrt     [a-z]|{latin1}|{escape}
nmchar     [a-z0-9_-]|{latin1}|{escape}
ident      ({nmstrt}+({nmchar}*))
ws         [ \t]+
string     \"({char}|"'")*\"|"'"({char}|\")*"'"

%%

<<EOF>>    { return 'EOF'; }
\s*">"\s*  { return 'CHILD'; }
\s*"+"\s*  { return 'SIBLING';}
\s*","\s*  { return 'COMMA'; }
{ws}       { return 'WS'; }
{ident}+   { return 'IDENT'; }
"."        { return 'DOT'; }
"#"        { return 'HASH'; }
":"        { return 'COLON'; }
"["        { return 'LBRAC'; }
"="        { return 'EQUAL'; }
"]"        { return 'RBRAC'; }
{string}   { return 'STRING'; }

/lex

%start expressions

%left EOF
%left COMMA
%left SIBLING CHILD WS
%right DOT HASH

%%

expressions
  : selector EOF { return $selector }
  ;

selector
	: parts { $$ = $1; }
	| selector WS selector { $$ = [$1, 'DESCEND', $3]; }
	| selector COMMA selector { $$ = [$1, 'COMMA', $3]; }
	| selector CHILD selector { $$ = [$1, 'CHILD', $3]; }
	| selector SIBLING selector { $$ = [$1, 'SIBLING', $3]; }
	;

parts
	: parts part { $$ = $1.concat([$2]); }
	| part { $$ = [$1]; }
	;

part
	: tag | class | id | psuedo | attrib
	;

tag
	: IDENT { $$ = $1; }
	;

class
	: DOT IDENT { $$ = '.'+$2; }
	;

id
	: HASH IDENT { $$ = '#'+$2; }
	;

psuedo
	: COLON IDENT { $$ = ':'+$2; }
	;

attrib
	: LBRAC IDENT EQUAL STRING RBRAC { var o = Object(); o.attr = $2; o.value = $4; $$ = o; }
	| LBRAC IDENT EQUAL IDENT RBRAC { var o = Object(); o.attr = $2; o.value = $4; $$ = o; }
	;

