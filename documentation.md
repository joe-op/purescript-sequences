# Module Documentation

## Module Data.FingerTree

#### `Reduce`

``` purescript
class Reduce f where
  reducer :: forall a b. (a -> b -> b) -> f a -> b -> b
  reducel :: forall a b. (b -> a -> b) -> b -> f a -> b
```


#### `arrayReduce`

``` purescript
instance arrayReduce :: Reduce Prim.Array
```

#### `toList`

``` purescript
toList :: forall f a. (Reduce f) => f a -> [a]
```


#### `Measured`

``` purescript
class Measured a v where
  measure :: a -> v
```


#### `Node`

``` purescript
data Node v a
  = Node2 v a a
  | Node3 v a a a
```


#### `showNode`

``` purescript
instance showNode :: (Show a, Show v) => Show (Node v a)
```


#### `node2`

``` purescript
node2 :: forall a v. (Monoid v, Measured a v) => a -> a -> Node v a
```


#### `node3`

``` purescript
node3 :: forall a v. (Monoid v, Measured a v) => a -> a -> a -> Node v a
```


#### `reduceNode`

``` purescript
instance reduceNode :: Reduce (Node v)
```


#### `measuredNode`

``` purescript
instance measuredNode :: Measured (Node v a) v
```


#### `measuredArray`

``` purescript
instance measuredArray :: (Monoid v, Measured a v) => Measured [a] v
```


#### `measuredLazy`

``` purescript
instance measuredLazy :: (Monoid v, Measured a v) => Measured (Lazy a) v
```


#### `FingerTree`

``` purescript
data FingerTree v a
  = Empty 
  | Single a
  | Deep (Lazy v) (Digit a) (Lazy (FingerTree v (Node v a))) (Digit a)
```

#### `lazyEmpty`

``` purescript
lazyEmpty :: forall v a. Lazy (FingerTree v a)
```


#### `deep`

``` purescript
deep :: forall a v. (Monoid v, Measured a v) => Digit a -> Lazy (FingerTree v (Node v a)) -> Digit a -> FingerTree v a
```


#### `Digit`

``` purescript
type Digit a = [a]
```

#### `fingerTreeShow`

``` purescript
instance fingerTreeShow :: (Show v, Show a) => Show (FingerTree v a)
```


#### `fingerTreeReduce`

``` purescript
instance fingerTreeReduce :: Reduce (FingerTree v)
```


#### `fingerTreeMeasured`

``` purescript
instance fingerTreeMeasured :: (Monoid v, Measured a v) => Measured (FingerTree v a) v
```


#### `(<|)`

``` purescript
(<|) :: forall a v. (Monoid v, Measured a v) => a -> FingerTree v a -> FingerTree v a
```


#### `(|>)`

``` purescript
(|>) :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> a -> FingerTree v a
```


#### `(<<|)`

``` purescript
(<<|) :: forall f a v. (Monoid v, Measured a v, Reduce f) => f a -> FingerTree v a -> FingerTree v a
```


#### `(|>>)`

``` purescript
(|>>) :: forall f a v. (Monoid v, Measured a v, Reduce f) => FingerTree v a -> f a -> FingerTree v a
```


#### `toTree`

``` purescript
toTree :: forall f a v. (Monoid v, Measured a v, Reduce f) => f a -> FingerTree v a
```


#### `ViewL`

``` purescript
data ViewL s a
  = NilL 
  | ConsL a (Lazy (s a))
```


#### `headDigit`

``` purescript
headDigit :: forall a. Digit a -> a
```


#### `tailDigit`

``` purescript
tailDigit :: forall a. Digit a -> Digit a
```


#### `viewL`

``` purescript
viewL :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> ViewL (FingerTree v) a
```


#### `deepL`

``` purescript
deepL :: forall a v. (Monoid v, Measured a v) => [a] -> Lazy (FingerTree v (Node v a)) -> [a] -> FingerTree v a
```


#### `isEmpty`

``` purescript
isEmpty :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> Boolean
```


#### `headL`

``` purescript
headL :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> a
```

#### `tailL`

``` purescript
tailL :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> FingerTree v a
```

#### `lastDigit`

``` purescript
lastDigit :: forall a. Digit a -> a
```


#### `initDigit`

``` purescript
initDigit :: forall a. Digit a -> Digit a
```


#### `ViewR`

``` purescript
data ViewR s a
  = NilR 
  | SnocR (Lazy (s a)) a
```


#### `viewR`

``` purescript
viewR :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> ViewR (FingerTree v) a
```


#### `deepR`

``` purescript
deepR :: forall a v. (Monoid v, Measured a v) => [a] -> Lazy (FingerTree v (Node v a)) -> [a] -> FingerTree v a
```


#### `headR`

``` purescript
headR :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> a
```

#### `tailR`

``` purescript
tailR :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> FingerTree v a
```

#### `app3`

``` purescript
app3 :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> [a] -> FingerTree v a -> FingerTree v a
```


#### `nodes`

``` purescript
nodes :: forall a v. (Monoid v, Measured a v) => [a] -> [Node v a]
```


#### `(><)`

``` purescript
(><) :: forall a v. (Monoid v, Measured a v) => FingerTree v a -> FingerTree v a -> FingerTree v a
```


#### `Split`

``` purescript
data Split f a
  = Split (f a) a (f a)
```


#### `LazySplit`

``` purescript
data LazySplit f a
  = LazySplit (Lazy (f a)) a (Lazy (f a))
```


#### `splitDigit`

``` purescript
splitDigit :: forall a v. (Monoid v, Measured a v) => (v -> Boolean) -> v -> Digit a -> Split Prim.Array a
```

#### `splitTree`

``` purescript
splitTree :: forall a v. (Monoid v, Measured a v) => (v -> Boolean) -> v -> FingerTree v a -> LazySplit (FingerTree v) a
```

#### `split`

``` purescript
split :: forall a v. (Monoid v, Measured a v) => (v -> Boolean) -> FingerTree v a -> Tuple (Lazy (FingerTree v a)) (Lazy (FingerTree v a))
```