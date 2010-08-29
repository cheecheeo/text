{-# LANGUAGE CPP, DeriveDataTypeable #-}

-- |
-- Module      : Data.Text.Internal
-- Copyright   : (c) 2008, 2009 Tom Harper,
--               (c) 2009, 2010 Bryan O'Sullivan,
--               (c) 2009 Duncan Coutts
--
-- License     : BSD-style
-- Maintainer  : bos@serpentine.com, rtomharper@googlemail.com,
--               duncan@haskell.org
-- Stability   : experimental
-- Portability : GHC
--
-- Semi-public internals.  Most users should not need to use this
-- module.

module Data.Text.Internal
    (
    -- * Types
      Text(..)
    -- * Construction
    , text
    , textP
    -- * Code that must be here for accessibility
    , empty
    -- * Debugging
    , showText
    ) where

#if defined(ASSERTS)
import Control.Exception (assert)
#endif
import qualified Data.Text.Array as A
import Data.Typeable (Typeable)

-- | A space efficient, packed, unboxed Unicode text type.
data Text = Text
    {-# UNPACK #-} !A.Array          -- payload
    {-# UNPACK #-} !Int              -- offset
    {-# UNPACK #-} !Int              -- length
    deriving (Typeable)

-- | Smart constructor.
text :: A.Array -> Int -> Int -> Text
text arr off len =
#if defined(ASSERTS)
  let c    = A.unsafeIndex arr off
      alen = A.length arr
  in assert (len >= 0) .
     assert (off >= 0) .
     assert (alen == 0 || len == 0 || off < alen) .
     assert (len == 0 || c < 0xDC00 || c > 0xDFFF) $
#endif
     Text arr off len
{-# INLINE text #-}

-- | /O(1)/ The empty 'Text'.
empty :: Text
empty = Text A.empty 0 0
{-# INLINE [1] empty #-}

-- | Construct a 'Text' without invisibly pinning its byte array in
-- memory if its length has dwindled to zero.
textP :: A.Array -> Int -> Int -> Text
textP arr off len | len == 0  = empty
                  | otherwise = text arr off len
{-# INLINE textP #-}

-- | A useful 'show'-like function for debugging purposes.
showText :: Text -> String
showText (Text arr off len) =
    "Text " ++ show (A.toList arr off len) ++ ' ' :
            show off ++ ' ' : show len
