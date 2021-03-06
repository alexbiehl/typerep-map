{-# LANGUAGE PolyKinds #-}

{- |
Copyright:  (c) 2017-2020 Kowainik
SPDX-License-Identifier: MPL-2.0
Maintainer: Kowainik <xrom.xkov@gmail.com>

TypeRepMap implementation based on @containers@ 'Map'.
-}

module Data.TypeRep.CMap
       ( TypeRepMap (..)
       , empty
       , insert
       , keys
       , lookup
       , size
       ) where

import Prelude hiding (lookup)

import Control.DeepSeq
import Data.Kind (Type)
import Data.Proxy (Proxy (..))
import Data.Typeable (TypeRep, Typeable, typeRep)
import GHC.Base (Any)
import Unsafe.Coerce (unsafeCoerce)

import qualified Data.Map.Lazy as LMap


-- | Map-like data structure with types served as the keys.
newtype TypeRepMap (f :: k -> Type) = TypeRepMap
    { unMap :: LMap.Map TypeRep Any
    }

instance NFData (TypeRepMap f) where
  rnf x = rnf (keys x) `seq` ()

-- | Empty structure.
empty :: TypeRepMap f
empty = TypeRepMap mempty

-- | Inserts the value with its type as a key.
insert :: forall a f . Typeable a => f a -> TypeRepMap f -> TypeRepMap f
insert val = TypeRepMap . LMap.insert (typeRep (Proxy :: Proxy a)) (unsafeCoerce val) . unMap

-- | Looks up the value at the type.
-- >>> let x = lookup $ insert (11 :: Int) empty
-- >>> x :: Maybe Int
-- Just 11
-- >>> x :: Maybe ()
-- Nothing
lookup :: forall a f . Typeable a => TypeRepMap f -> Maybe (f a)
lookup = fmap unsafeCoerce . LMap.lookup (typeRep (Proxy :: Proxy a)) . unMap

size :: TypeRepMap f -> Int
size = LMap.size . unMap

keys :: TypeRepMap f -> [TypeRep]
keys = LMap.keys . unMap
