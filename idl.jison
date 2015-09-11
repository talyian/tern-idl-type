%lex
%%
\s+                     { }
"//".*                  { }
"/*".*"*/"              { }
typedef                 { return 'typedef' }

dictionary              { return 'dict' }
interface               { return 'interface' }
implements              { return 'implements' }
const                   { return 'const' }
readonly                { return 'const' }
attribute               { return 'const' }
or                      { return 'or' }
"[".*"]"                { return 'Attribute' }
\w+                     { return 'id' }
.                       { return yytext; }
/lex

%start file

%%

file: expressions <<EOF>> { return $1; };

expressions
        : expressions statement { $$ = $1; $$.push($2); }
        | statement             { $$ = [ $1 ]; }
        ;

statement
        : comment                  { $$ = {'comment':yytext}; }
        | typedef ids ';'          { $$ = yy.parser.Def($2.splice(-1)[0], yy.parser.map_simple_type($2.join(' '))); }
        | id implements id ';'     { $$ = yy.parser.Def($1, {"!type": "fn()", "prototype": $3}); }
        | dict id body             { $$ = yy.parser.Def($2, yy.parser.Body($3)); }
        | dict id ':' id body      { $$ = yy.parser.Def($2, yy.parser.Body($5)); }
        | interface id body        { $$ = yy.parser.Def($2, yy.parser.Body($3)); }
        | interface id ':' id body { $$ = yy.parser.Def($2, yy.parser.Body($5)); }
        | Attribute statement      { $$ = $2; $$.attribs = $1; }
        ;

ids : id { $$ = [ $1 ] }
    | ids id { $$ = $1; $$.push($2); }
    ;

body
        : '{' '}' ';'          -> []
        | '{' members '}' ';'  -> $2
        ;

members : def_line              -> [$1]
        | members def_line      -> $1.concat([$2])
        ;

def_line
        : typedef '(' typedef_list ')' id ';' -> {name:$5, type: $1, value:$3}
        | type id '=' id ';'     -> {'type': $1, 'name': $2, value: $4, 'attrib': []}
        | type id ';'            -> {'type': $1, 'name': $2, 'attrib': []}
        | type id parameters ';' {
             var p = $3.map(function(x) { return x[1] + ': ' + x[0];  }).join(', ')
             $$ = {'type': 'fn('+ p +') -> '+ $1, 'name': $2}
          }
        | Attribute def_line     -> $2
        | const def_line         -> (($2.attrib || []).push($1)) && $2
        ;

type
        : id
        | type '?'
        | type '<' type '>'
        ;

typedef_list
        : id -> [$1]
        | typedef_list 'or' id -> $1.concat([$3])
        ;

parameters
        : '(' ')' -> []
        | '(' paramlist ')' -> $2
        ;

paramlist
        : paramlist ',' type id -> $1.concat([[$3, $4]])
        | type id               -> [[$1, $2]]
        ;
