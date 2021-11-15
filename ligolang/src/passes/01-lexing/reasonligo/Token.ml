(* Token specification for CameLIGO *)

(* Vendor dependencies *)

module Region    = Simple_utils.Region
module Markup    = LexerLib.Markup
module Directive = LexerLib.Directive

(* Utility modules and types *)

module SMap = Map.Make (String)
module Wrap = Lexing_shared.Wrap

type 'a wrap = 'a Wrap.t
type 'a reg  = 'a Region.reg

let wrap = Wrap.wrap

(* TOKENS *)

type lexeme = Lexing_shared.Common.lexeme

module T =
  struct
    (* Tokens *)

    (* Definition of tokens generated by menhir --only-tokens *)
    (*   It contains [token] and ['a terminal] types. The first one we
         redefine manually here (by type [t]) but the second one we need to
         satisfy Menhir's Inspection API.  *)

    include Menhir_reasonligo_tokens.MenhirToken

    type t =
      (* Preprocessing directives *)

      Directive of Directive.t

      (* Literals *)

    | String   of lexeme wrap
    | Verbatim of lexeme wrap
    | Bytes    of (lexeme * Hex.t) wrap
    | Int      of (lexeme * Z.t) wrap
    | Nat      of (lexeme * Z.t) wrap
    | Mutez    of (lexeme * Z.t) wrap
    | Ident    of lexeme wrap
    | UIdent   of lexeme wrap
    | Lang     of lexeme reg reg
    | Attr     of string wrap

    (* Symbols *)

    | PLUS2    of lexeme wrap (* "++"  *)
    | MINUS    of lexeme wrap (* "-"   *)
    | PLUS     of lexeme wrap (* "+"   *)
    | SLASH    of lexeme wrap (* "/"   *)
    | TIMES    of lexeme wrap (* "*"   *)
    | LPAR     of lexeme wrap (* "("   *)
    | RPAR     of lexeme wrap (* ")"   *)
    | LBRACKET of lexeme wrap (* "["   *)
    | RBRACKET of lexeme wrap (* "]"   *)
    | LBRACE   of lexeme wrap (* "{"   *)
    | RBRACE   of lexeme wrap (* "}"   *)
    | COMMA    of lexeme wrap (* ","   *)
    | SEMI     of lexeme wrap (* ";"   *)
    | VBAR     of lexeme wrap (* "|"   *)
    | COLON    of lexeme wrap (* ":"   *)
    | DOT      of lexeme wrap (* "."   *)
    | ELLIPSIS of lexeme wrap (* "..." *)
    | ARROW    of lexeme wrap (* "=>"  *)
    | WILD     of lexeme wrap (* "_"   *)
    | EQ       of lexeme wrap (* "="   *)
    | EQ2      of lexeme wrap (* "=="  *)
    | NE       of lexeme wrap (* "!="  *)
    | LT       of lexeme wrap (* "<"   *)
    | GT       of lexeme wrap (* ">"   *)
    | LE       of lexeme wrap (* "<="  *)
    | GE       of lexeme wrap (* ">="  *)
    | BOOL_OR  of lexeme wrap (* "||"  *)
    | BOOL_AND of lexeme wrap (* "&&"  *)
    | NOT      of lexeme wrap (* "!"   *)
    | QUOTE    of lexeme wrap (* "'"   *)

    (* Keywords *)

    | Else   of lexeme wrap  (* else   *)
    | If     of lexeme wrap  (* if     *)
    | Let    of lexeme wrap  (* let    *)
    | Mod    of lexeme wrap  (* mod    *)
    | Land   of lexeme wrap  (* land   *)
    | Lor    of lexeme wrap  (* lor    *)
    | Lxor   of lexeme wrap  (* lxor   *)
    | Lsl    of lexeme wrap  (* lsl    *)
    | Lsr    of lexeme wrap  (* lsr    *)
    | Or     of lexeme wrap  (* or     *)
    | Rec    of lexeme wrap  (* rec    *)
    | Switch of lexeme wrap  (* switch *)
    | Type   of lexeme wrap  (* type   *)
    | Module of lexeme wrap  (* module *)

    (* Virtual tokens *)

    | ES6FUN of lexeme wrap

    (* End-Of-File *)

    | EOF of lexeme wrap

    (* Unlexing the tokens *)

    let gen_sym prefix =
      let count = ref 0 in
      fun () -> incr count;
             prefix ^ string_of_int !count

    let id_sym   = gen_sym "id"
    and ctor_sym = gen_sym "C"

    let concrete = function
        (* Identifiers, labels, numbers and strings *)

      "Ident"    -> id_sym ()
    | "UIdent"   -> ctor_sym ()
    | "Int"      -> "1"
    | "Nat"      -> "1n"
    | "Mutez"    -> "1mutez"
    | "String"   -> "\"a string\""
    | "Verbatim" -> "{|verbatim|}"
    | "Bytes"    -> "0xAA"
    | "Attr"     -> "[@attr]"
    | "Lang"     -> "[%Michelson"

    (* Symbols *)

    | "PLUS2" -> "++"

    (* Arithmetics *)

    | "MINUS"   -> "-"
    | "PLUS"    -> "+"
    | "SLASH"   -> "/"
    | "TIMES"   -> "*"

    (* Compounds *)

    | "LPAR"     -> "("
    | "RPAR"     -> ")"
    | "LBRACKET" -> "["
    | "RBRACKET" -> "]"
    | "LBRACE"   -> "{"
    | "RBRACE"   -> "}"

    (* Separators *)

    | "COMMA"    -> ","
    | "SEMI"     -> ";"
    | "VBAR"     -> "|"
    | "COLON"    -> ":"
    | "DOT"      -> "."
    | "ELLIPSIS" -> "..."
    | "ARROW"    -> "=>"

    (* Wildcard *)

    | "WILD" ->     "_"

    (* Comparisons *)

    | "EQ"   -> "="
    | "EQ2"  -> "=="
    | "NE"   -> "!="
    | "LT"   -> "<"
    | "GT"   -> ">"
    | "LE"   -> "<="
    | "GE"   -> ">="

    (* Logic *)

    | "BOOL_OR"  -> "||"
    | "BOOL_AND" -> "&&"
    | "NOT"      -> "!"

    (* Keywords *)

    | "Else"   -> "else"
    | "If"     -> "if"
    | "Let"    -> "let"
    | "Mod"    -> "mod"
    | "Land"   -> "land"
    | "Lor"    -> "lor"
    | "Lxor"   -> "lxor"
    | "Lsl"    -> "lsl"
    | "Lsr"    -> "lsr"
    | "Or"     -> "or"
    | "Rec"    -> "rec"
    | "Switch" -> "switch"
    | "Type"   -> "type"
    | "Module" -> "module"

    | "QUOTE"  -> "'"

    (* End-Of-File *)

    | "EOF" -> ""

    (* This case should not happen! *)

    | _  -> "\\Unknown" (* Backslash meant to trigger an error *)

    (* Projections *)

    let sprintf = Printf.sprintf

    type token = t

    let proj_token = function
        (* Preprocessing directives *)

      Directive d ->
        Directive.project d

      (* Literals *)

    | String t ->
        t#region, sprintf "String %S" t#payload
    | Verbatim t ->
        t#region, sprintf "Verbatim %S" t#payload
    | Bytes t ->
        let (s, b) = t#payload in
        t#region,
        sprintf "Bytes (%S, \"0x%s\")" s (Hex.show b)
    | Int t ->
        let (s, n) = t#payload in
        t#region, sprintf "Int (%S, %s)" s (Z.to_string n)
    | Nat t ->
        let (s, n) = t#payload in
        t#region, sprintf "Nat (%S, %s)" s (Z.to_string n)
    | Mutez t ->
        let (s, n) = t#payload in
        t#region, sprintf "Mutez (%S, %s)" s (Z.to_string n)
    | Ident t ->
        t#region, sprintf "Ident %S" t#payload
    | UIdent t ->
        t#region, sprintf "UIdent %S" t#payload
    | Lang {value = {value = payload; _}; region; _} ->
        region, sprintf "Lang %S" payload
    | Attr t ->
        t#region, sprintf "Attr %S" t#payload

    (* Symbols *)

    | PLUS2    t -> t#region, "PLUS2"
    | MINUS    t -> t#region, "MINUS"
    | PLUS     t -> t#region, "PLUS"
    | SLASH    t -> t#region, "SLASH"
    | TIMES    t -> t#region, "TIMES"
    | LPAR     t -> t#region, "LPAR"
    | RPAR     t -> t#region, "RPAR"
    | LBRACKET t -> t#region, "LBRACKET"
    | RBRACKET t -> t#region, "RBRACKET"
    | LBRACE   t -> t#region, "LBRACE"
    | RBRACE   t -> t#region, "RBRACE"
    | COMMA    t -> t#region, "COMMA"
    | SEMI     t -> t#region, "SEMI"
    | VBAR     t -> t#region, "VBAR"
    | COLON    t -> t#region, "COLON"
    | DOT      t -> t#region, "DOT"
    | ELLIPSIS t -> t#region, "ELLIPSIS"
    | WILD     t -> t#region, "WILD"
    | EQ       t -> t#region, "EQ"
    | EQ2      t -> t#region, "EQ2"
    | NE       t -> t#region, "NE"
    | LT       t -> t#region, "LT"
    | GT       t -> t#region, "GT"
    | LE       t -> t#region, "LE"
    | GE       t -> t#region, "GE"
    | ARROW    t -> t#region, "ARROW"
    | NOT      t -> t#region, "NOT"
    | BOOL_OR  t -> t#region, "BOOL_OR"
    | BOOL_AND t -> t#region, "BOOL_AND"
    | Else     t -> t#region, "Else"
    | If       t -> t#region, "If"
    | Let      t -> t#region, "Let"
    | Rec      t -> t#region, "Rec"
    | Switch   t -> t#region, "Switch"
    | Mod      t -> t#region, "Mod"
    | Land     t -> t#region, "Land"
    | Lor      t -> t#region, "Lor"
    | Lxor     t -> t#region, "Lxor"
    | Lsl      t -> t#region, "Lsl"
    | Lsr      t -> t#region, "Lsr"
    | Or       t -> t#region, "Or"
    | Type     t -> t#region, "Type"
    | Module   t -> t#region, "Module"
    | QUOTE    t -> t#region, "QUOTE"

    (* Virtual tokens *)

    | ES6FUN t -> t#region, "ES6FUN"

    (* End-Of-File *)

    | EOF t -> t#region, "EOF"


    let to_lexeme = function
      (* Directives *)

      Directive d -> Directive.to_lexeme d

      (* Literals *)

    | String t   -> sprintf "%S" (String.escaped t#payload)
    | Verbatim t -> String.escaped t#payload
    | Bytes t    -> fst t#payload
    | Int t
    | Nat t
    | Mutez t    -> fst t#payload
    | Ident t    -> t#payload
    | UIdent t   -> t#payload
    | Attr t     -> sprintf "[@%s]" t#payload
    | Lang lang  -> Region.(lang.value.value)

    (* Symbols *)

    | PLUS2    _ -> "++"
    | MINUS    _ -> "-"
    | PLUS     _ -> "+"
    | SLASH    _ -> "/"
    | TIMES    _ -> "*"
    | LPAR     _ -> "("
    | RPAR     _ -> ")"
    | LBRACKET _ -> "["
    | RBRACKET _ -> "]"
    | LBRACE   _ -> "{"
    | RBRACE   _ -> "}"
    | COMMA    _ -> ","
    | SEMI     _ -> ";"
    | VBAR     _ -> "|"
    | COLON    _ -> ":"
    | DOT      _ -> "."
    | ELLIPSIS _ -> "..."
    | WILD     _ -> "_"
    | EQ       _ -> "="
    | EQ2      _ -> "=="
    | NE       _ -> "!="
    | LT       _ -> "<"
    | GT       _ -> ">"
    | LE       _ -> "<="
    | GE       _ -> ">="
    | ARROW    _ -> "=>"
    | BOOL_OR  _ -> "||"
    | BOOL_AND _ -> "&&"
    | NOT      _ -> "!"
    | QUOTE    _ -> "'"

    (* Keywords *)

    | Else    _ -> "else"
    | If      _ -> "if"
    | Let     _ -> "let"
    | Mod     _ -> "mod"
    | Land    _ -> "land"
    | Lor     _ -> "lor"
    | Lxor    _ -> "lxor"
    | Lsl     _ -> "lsl"
    | Lsr     _ -> "lsr"
    | Or      _ -> "or"
    | Rec     _ -> "rec"
    | Switch  _ -> "switch"
    | Type    _ -> "type"
    | Module  _ -> "module"

    (* Virtual tokens *)

    | ES6FUN _ -> ""

    (* End-Of-File *)

    | EOF _ -> ""


    (* CONVERSIONS *)

    let to_string ~offsets mode token =
      let region, val_str = proj_token token in
      let reg_str = region#compact ~offsets mode
      in sprintf "%s: %s" reg_str val_str

    let to_region token = proj_token token |> fst

    (* SMART CONSTRUCTORS *)

    (* Keywords *)

    let keywords = [
      (fun reg -> Else   (wrap "Else"   reg));
      (fun reg -> If     (wrap "If"     reg));
      (fun reg -> Let    (wrap "Let"    reg));
      (fun reg -> Rec    (wrap "Rec"    reg));
      (fun reg -> Switch (wrap "Switch" reg));
      (fun reg -> Mod    (wrap "Mod"    reg));
      (fun reg -> Land   (wrap "Land"   reg));
      (fun reg -> Lor    (wrap "Lor"    reg));
      (fun reg -> Lxor   (wrap "Lxor"   reg));
      (fun reg -> Lsl    (wrap "Lsl"    reg));
      (fun reg -> Lsr    (wrap "Lsr"    reg));
      (fun reg -> Or     (wrap "Or"     reg));
      (fun reg -> Type   (wrap "Type"   reg));
      (fun reg -> Module (wrap "Module" reg))
    ]

    let keywords =
      let add map (key, value) = SMap.add key value map in
      let apply map mk_kwd =
        add map (to_lexeme (mk_kwd Region.ghost), mk_kwd)
      in List.fold_left apply SMap.empty keywords

    type kwd_err = Invalid_keyword

    let mk_kwd ident region =
      match SMap.find_opt ident keywords with
        Some mk_kwd -> Ok (mk_kwd region)
      |        None -> Error Invalid_keyword

    (* Strings *)

    let mk_string lexeme region = String (wrap lexeme region)

    let mk_verbatim lexeme region = Verbatim (wrap lexeme region)

    (* Bytes *)

    let mk_bytes lexeme region =
      let norm = Str.(global_replace (regexp "_") "" lexeme) in
      let value = lexeme, `Hex norm
      in Bytes (wrap value region)

    (* Numerical values *)

    type int_err = Non_canonical_zero

    let mk_int lexeme region =
      let z =
        Str.(global_replace (regexp "_") "" lexeme) |> Z.of_string
      in if   Z.equal z Z.zero && lexeme <> "0"
         then Error Non_canonical_zero
         else Ok (Int (wrap (lexeme, z) region))

    type nat_err =
      Invalid_natural
    | Unsupported_nat_syntax
    | Non_canonical_zero_nat

    let mk_nat lexeme region =
      match String.index_opt lexeme 'n' with
        None -> Error Invalid_natural
      | Some _ ->
          let z =
            Str.(global_replace (regexp "_") "" lexeme) |>
              Str.(global_replace (regexp "n") "") |>
              Z.of_string in
          if   Z.equal z Z.zero && lexeme <> "0n"
          then Error Non_canonical_zero_nat
          else Ok (Nat (wrap (lexeme, z) region))

    type mutez_err =
        Unsupported_mutez_syntax
      | Non_canonical_zero_tez

    let mk_mutez lexeme region =
      let z = Str.(global_replace (regexp "_") "" lexeme) |>
                Str.(global_replace (regexp "mutez") "") |>
                Z.of_string in
      if   Z.equal z Z.zero && lexeme <> "0mutez"
      then Error Non_canonical_zero_tez
      else Ok (Mutez (wrap (lexeme, z) region))

    (* End-Of-File *)

    let mk_eof region = EOF (wrap "" region)

    (* Symbols *)

    type sym_err = Invalid_symbol of string

    let mk_sym lexeme region =
      match lexeme with
        (* Lexemes in common with all concrete syntaxes *)

        ";"   -> Ok (SEMI     (wrap lexeme region))
      | ","   -> Ok (COMMA    (wrap lexeme region))
      | "("   -> Ok (LPAR     (wrap lexeme region))
      | ")"   -> Ok (RPAR     (wrap lexeme region))
      | "["   -> Ok (LBRACKET (wrap lexeme region))
      | "]"   -> Ok (RBRACKET (wrap lexeme region))
      | "{"   -> Ok (LBRACE   (wrap lexeme region))
      | "}"   -> Ok (RBRACE   (wrap lexeme region))
      | "="   -> Ok (EQ       (wrap lexeme region))
      | ":"   -> Ok (COLON    (wrap lexeme region))
      | "|"   -> Ok (VBAR     (wrap lexeme region))
      | "."   -> Ok (DOT      (wrap lexeme region))
      | "_"   -> Ok (WILD     (wrap lexeme region))
      | "+"   -> Ok (PLUS     (wrap lexeme region))
      | "-"   -> Ok (MINUS    (wrap lexeme region))
      | "*"   -> Ok (TIMES    (wrap lexeme region))
      | "/"   -> Ok (SLASH    (wrap lexeme region))
      | "<"   -> Ok (LT       (wrap lexeme region))
      | "<="  -> Ok (LE       (wrap lexeme region))
      | ">"   -> Ok (GT       (wrap lexeme region))
      | ">="  -> Ok (GE       (wrap lexeme region))

      (* Symbols specific to ReasonLIGO *)

      | "!="   -> Ok (NE       (wrap lexeme region))
      | "||"   -> Ok (BOOL_OR  (wrap lexeme region))
      | "&&"   -> Ok (BOOL_AND (wrap lexeme region))
      | "..." ->  Ok (ELLIPSIS (wrap lexeme region))
      | "=>"  ->  Ok (ARROW    (wrap lexeme region))
      | "=="  ->  Ok (EQ2      (wrap lexeme region))
      | "!"   ->  Ok (NOT      (wrap lexeme region))
      | "++"  ->  Ok (PLUS2    (wrap lexeme region))

      | "'"   -> Ok (QUOTE    (wrap lexeme region))

      (* Invalid symbols *)

      | s ->  Error (Invalid_symbol s)

    (* Identifiers *)

    let mk_ident value region =
      match SMap.find_opt value keywords with
        Some mk_kwd -> mk_kwd region
      |        None -> Ident (wrap value region)

    (* Constructors/Modules *)

    let mk_uident value region = UIdent (wrap value region)

    (* Attributes *)

    let mk_attr lexeme region = Attr (wrap lexeme region)

    (* Code injection *)

    type lang_err = Unsupported_lang_syntax

    let mk_lang lang region = Ok (Lang Region.{value=lang; region})

    (* PREDICATES *)

    let is_eof = function EOF _ -> true | _ -> false

    let support_string_delimiter c = (c = '"')

    let verbatim_delimiters = ("{|", "|}")

  end

include T

module type S = module type of T