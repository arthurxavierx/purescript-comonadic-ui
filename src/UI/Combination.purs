module UI.Combination
  ( module S
  , Combination
  , combine
  , lift
  , liftUI
  ) where

import Prelude

import Control.Comonad (class Comonad)
import Control.Monad.Transition.Trans (TransitionT(..), runTransitionT)
import Data.Smash (class ComonadSmash, class Smashed, Smash, smash)
import Data.Smash (lower) as S
import Data.Symbol (class IsSymbol, SProxy)
import Type.Proxy (Proxy2)
import Type.Row (class Cons, class RowToList) as Row
import UI as UI

type Combination = Smash

combine
  :: forall rl proxies r as a
   . Row.RowToList r rl
  => Smashed rl r proxies as
  => (Record as -> a)
  -> Record r
  -> Smash proxies a
combine render = map render <<< smash

lift
  :: forall l w r rl rest m
   . IsSymbol l
  => Functor w
  => Row.Cons l (Proxy2 w) rest r
  => Row.RowToList rest rl
  => ComonadSmash rl rest
  => SProxy l
  -> TransitionT w m ~> TransitionT (Smash r) m
lift l t = TransitionT \s -> runTransitionT t (S.lower l s)

liftUI
  :: forall l w r rl rest m f
   . IsSymbol l
  => Row.Cons l (Proxy2 w) rest r
  => Comonad w
  => Functor m
  => Row.RowToList rest rl
  => ComonadSmash rl rest
  => SProxy l
  -> UI.UI m w f ~> UI.UI m (Smash r) f
liftUI = UI.liftUI <<< S.lower
