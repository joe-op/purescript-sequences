module Data.Sequence
  ( Seq()

  -- construction
  , empty
  , singleton
  , (<|)
  , (|>)
  , append
  , toSeq

  -- queries
  , length
  , null

  -- deconstruction
  , unconsL
  , head
  , tail
  , init
  , last

  , splitAt

  -- indexing
  , index

  -- other
  , fromSeq
  ) where

import Data.Lazy
import Data.Monoid
import Data.Tuple
import Data.Maybe
import Data.Foldable
import Data.Unfoldable
import Data.Traversable
import Control.Alt
import Control.Plus (Plus)
import Control.Alternative
import Control.MonadPlus

import qualified Data.FingerTree as FT

newtype Size = Size Number

getSize :: Size -> Number
getSize (Size n) = n

instance semigroupSize :: Semigroup Size where
  (<>) m n = Size (getSize m + getSize n)

instance monoidSize :: Monoid Size where
  mempty = Size 0

instance showSize :: Show Size where
  show x = "Size (" <> show (getSize x) <> ")"

newtype Elem a = Elem a

getElem :: forall a. Elem a -> a
getElem (Elem a) = a

instance measuredElem :: FT.Measured (Elem a) Size where
  measure _ = Size 1

instance showElem :: (Show a) => Show (Elem a) where
  show x = "Elem (" <> show (getElem x) <> ")"

instance eqElem :: (Eq a) => Eq (Elem a) where
  (==) (Elem x) (Elem y) = x == y
  (/=) x y = not (x == y)

instance ordElem :: (Ord a) => Ord (Elem a) where
  compare (Elem x) (Elem y) = compare x y

instance foldableElem :: Foldable Elem where
  foldr f z (Elem x) = f x z
  foldl f z (Elem x) = f z x
  foldMap f (Elem x) = f x

instance functorElem :: Functor Elem where
  (<$>) f (Elem x) = Elem (f x)

instance traversableElem :: Traversable Elem where
  traverse f (Elem x) = Elem <$> f x
  sequence (Elem fx)  = Elem <$> fx

type SeqInner a = FT.FingerTree Size (Elem a)
newtype Seq a = Seq (SeqInner a)

getSeq :: forall a. Seq a -> SeqInner a
getSeq (Seq a) = a

instance eqSeq :: (Eq a) => Eq (Seq a) where
  -- TODO: Optimise, probably with lazy list
  (==) xs ys = if length xs == length ys
                 then fromSeq xs == (fromSeq ys :: [a])
                 else false
  (/=) xs ys = not (xs == ys)

instance showSeq :: (Show a) => Show (Seq a) where
  show xs = "toSeq [" <> strJoin "," (fromSeq (show <$> xs)) <> "]"

foreign import strJoin """
  function strJoin(glue) {
    return function(array) {
      return array.join(glue)
    }
  }
  """ :: String -> [String] -> String

instance ordSeq :: (Ord a) => Ord (Seq a) where
  compare (Seq xs) (Seq ys) = FT.compareFingerTree xs ys

instance semigroupSeq :: Semigroup (Seq a) where
  (<>) = append

instance monoidSeq :: Monoid (Seq a) where
  mempty = empty

instance foldableSeq :: Foldable Seq where
  foldr f z (Seq xs) = foldr (f <<< getElem) z xs
  foldl f z (Seq xs) = foldl (\b a -> f b (getElem a)) z xs
  foldMap f (Seq xs) = foldMap (f <<< getElem) xs

instance traversableSeq :: Traversable Seq where
  traverse f (Seq xs) = Seq <$> traverse (traverse f) xs
  sequence = traverse id

instance unfoldableSeq :: Unfoldable Seq where
  unfoldr f xs = case f xs of
                  Just (Tuple x ys) -> x <| unfoldr f ys
                  Nothing           -> empty

instance functorSeq :: Functor Seq where
  (<$>) f (Seq xs) = Seq (g <$> xs)
    where
    g (Elem x) = Elem (f x)

instance applySeq :: Apply Seq where
  -- TODO: Optimise (see Hackage)
  (<*>) = ap

instance applicativeSeq :: Applicative Seq where
  pure = singleton

instance bindSeq :: Bind Seq where
  (>>=) xs f = foldl add empty xs
    where add ys x = append ys (f x)

instance monadSeq :: Monad Seq

instance altSeq :: Alt Seq where
  (<|>) = append

instance plusSeq :: Plus Seq where
  empty = empty

instance alternativeSeq :: Alternative Seq

instance monadPlusSeq :: MonadPlus Seq

length :: forall a. Seq a -> Number
length (Seq xs) = getSize (FT.measure xs)

null :: forall a. Seq a -> Boolean
null (Seq FT.Empty) = true
null _              = false

fromSeq :: forall f a. (Functor f, Unfoldable f) => Seq a -> f a
fromSeq (Seq xs) = getElem <$> FT.fromFingerTree xs

(***) :: forall a b aa bb. (a -> aa) -> (b -> bb) -> Tuple a b -> Tuple aa bb
(***) fa fb (Tuple a b) = Tuple (fa a) (fb b)

fmap :: forall f a b. (Functor f) => (a -> b) -> f a -> f b
fmap = (<$>)

unconsL :: forall a. Seq a -> Maybe (Tuple a (Seq a))
unconsL (Seq xs) =
  case FT.viewL xs of
      FT.NilL       -> Nothing
      FT.ConsL y ys -> Just (Tuple (getElem y)
                                   (Seq (force ys)))

splitAt' :: forall a. Number -> Seq a -> Tuple (Lazy (Seq a)) (Lazy (Seq a))
splitAt' i (Seq xs) = seqify tuple
  where
  tuple = FT.split (\n -> i < getSize n) xs
  seqify = fmap Seq *** fmap Seq

splitAt :: forall a. Number -> Seq a -> Tuple (Seq a) (Seq a)
splitAt i xs = forceBoth tuple
  where
  forceBoth = force *** force
  tuple = splitAt' i xs

index :: forall a. Seq a -> Number -> a
index (Seq xs) i =
  case FT.splitTree (\n -> i < getSize n) (Size 0) xs of
    FT.LazySplit _ x _ -> getElem x

empty :: forall a. Seq a
empty = Seq FT.Empty

(<|) :: forall a. a -> Seq a -> Seq a
(<|) x (Seq xs) = Seq (FT.(<|) (Elem x) xs)

(|>) :: forall a. Seq a -> a -> Seq a
(|>) (Seq xs) x = Seq (FT.(|>) xs (Elem x))

singleton :: forall a. a -> Seq a
singleton x = x <| empty

append :: forall a. Seq a -> Seq a -> Seq a
append (Seq a) (Seq b) = Seq (FT.append a b)

head :: forall a. Seq a -> Maybe a
head (Seq xs) = getElem <$> FT.head xs

tail :: forall a. Seq a -> Maybe (Seq a)
tail (Seq xs) = Seq <$> FT.tail xs

init :: forall a. Seq a -> Maybe (Seq a)
init (Seq xs) = Seq <$> FT.init xs

last :: forall a. Seq a -> Maybe a
last (Seq xs) = getElem <$> FT.last xs

-- TODO: This can be improved. See Hackage
toSeq :: forall f a. (Foldable f) => f a -> Seq a
toSeq = foldr (<|) empty
