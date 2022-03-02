type ident = Ident.t

type prim =
  | P_neg
  | P_add
  | P_sub
  | P_mul
  | P_div
  | P_rem
  | P_and
  | P_or
  | P_xor
  | P_lsl
  | P_lsr
  | P_asr

type expr =
  (* calculus *)
  | E_var   of ident
  | E_lam   of ident * expr
  | E_app   of {
      funct : expr;
      arg : expr;
    }
  (* prims *)
  | E_const of int64
  | E_prim  of prim
  (* branching *)
  | E_if    of {
      (* condition <> 0 ? then_ : else_ *)
      condition : expr;
      then_ : expr;
      else_ : expr;
    }
  (* memory *)
  | E_pair  of {
      left : expr;
      right : expr;
    }
  | E_fst   of expr
  | E_snd   of expr

type value =
  | V_int64     of int64
  | V_pair      of {
      left : value;
      right : value;
    }
  | V_closure   of {
      env : env;
      param : Ident.t;
      body : expr;
    }
  | V_primitive of {
      args : value list;
      prim : prim;
    }
and env = value Map_with_cardinality.Make(Ident).t

type script = {
  param : Ident.t;
  code : expr;
}