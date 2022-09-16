{ lib, ... }:

with builtins;
with lib;
rec {
  # Generate a set that represents a single key, value pair, often used to
  # transform sets
  # def nameValuePair(name, value):
  #   return {"name": name, "value": value}
  nameValuePair = lib.nameValuePair or
    (name: value: { inherit name value; });

  # Turn a set into list of key, value pairs
  # def attrsToList(attrs):
  #   return [{"name": key, "value": value} for key, value in attrs.items()]
  attrsToList = attrs:
    mapAttrsToList nameValuePair attrs;

  # Transform a set (both key and value), filtering out any new entries using
  # the predicate
  # def transform(key, value):
  #   return {"name": newkey, "value": newvalue}
  #
  #def predicate(key, value):
  #  return shouldKeep(key, value)
  #
  # def mapFilterAttrs(predicate, transform, attrs)
  #   listOfNameValuePairs = [transform(key, value) for key, value in attrs.items()]
  #   return {
  #     pair["name"]: pair["value"]
  #       for pair in listOfNameValuePairs if predicate(pair["name"], pair["value"])
  #   }
  mapFilterAttrs = pred: f: attrs: filterAttrs pred (mapAttrs' f attrs);

  # Generate an attribute set by mapping a function over a list of values.
  # def f(value):
  #   return {"name": name, "value": newvalue}
  #
  # def genAttrs'(values, f):
  #   listOfNameValuePairs = [f(value) for value in values]
  #   return {pair["name"]: pair["value"] for pair in listOfNameValuePairs}
  genAttrs' = values: f: listToAttrs (map f values);

  # Return true if any key, value pair in the set returns true when calling the
  # predicate on it
  # anyAttrs :: (name -> value -> bool) attrs
  # def pred(key, value):
  #   return shouldKeep(key, value)
  #
  # def anyAttrs(pred, attrs):
  #   for nameValuePair in attrsToList(attrs):
  #     if pred(nameValuePair["name"], nameValuePair["value"]):
  #       return True
  #   return False
  anyAttrs = pred: attrs:
    any (attr: pred attr.name attr.value) (attrsToList attrs);

  # Count the number of key, value pairs for which the predicate returns true
  # countAttrs :: (name -> value -> bool) attrs
  # def pred(key, value):
  #   return shouldCount(key, value)
  #
  # def countAttrs(attrs):
  #   return sum([1 if pred(pair["name"], pair["value"]) else 0 for pair in attrsToList(attrs)])
  countAttrs = pred: attrs:
    count (attr: pred attr.name attr.value) (attrsToList attrs);
}
