open Core;

[@deriving (yojson, ord)]
type action =
  | Add
  | Remove;

[@deriving (yojson, ord)]
type t = {
  action,
  address: Address.Implicit.t,
};

module Set =
  Set.Make({
    type nonrec t = t;
    let compare = compare;
  });
