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
        : comment                  { $$ = ['comment']; }
        | typedef ids ';'          { var a = $2.splice(-1)[0]; $$ = ['typedef', $2.join(' '), a]; }
        | id implements id ';'     { $$ = ['implements', $1, $3]; }
        | dict id body             { $$ = ['dict', $2, $3]; }
        | dict id ':' id body      { $$ = ['dict', $2, $5, $4]; }
        | interface id body        { $$ = ['interface', $2, $3]; }
        | interface id ':' id body { $$ = ['interface', $2, $5, $4]; }
        | Attribute                { $$ = ['attribute']; }
        ;

ids : id { $$ = [ $1 ] }
    | ids id { $$ = $1; $$.push($2); }
    ;

body
        : '{' '}' ';'          -> null
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
             var p = $3.map(function(x) { return x[0] + ': ' + x[1];  }).join(', ')
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
