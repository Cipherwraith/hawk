--   Copyright 2013 Mario Pastorelli (pastorelli.mario@gmail.com) Samuel Gélineau (gelisam@gmail.com)
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.

{-# LANGUAGE FlexibleContexts #-}
import Data.Vector (Vector,(!))
import qualified Data.Vector as V
import Data.ByteString.Lazy.Char8 (ByteString)
import qualified Data.ByteString.Char8 as C8
import qualified Data.ByteString.Lazy.Char8 as LC8
import Data.ByteString.Lazy.Search (split)
import Text.Regex.Posix
import Prelude

match :: (RegexMaker Text.Regex.Posix.Regex
                     Text.Regex.Posix.CompOption
                     Text.Regex.Posix.ExecOption
                     source,
          RegexContext Text.Regex.Posix.Regex source1 target)
      => source1
      -> source
      -> target
match = (=~)

splitOn :: String -> ByteString -> Vector ByteString
splitOn mark bs = V.fromList $ split (C8.pack mark) bs

vwords :: ByteString -> Vector ByteString
vwords = V.fromList . LC8.words

(#) :: Vector a -> Int -> a
ls # i | i < 0 && i > -lenls = ls # (lenls + i)
       | i < lenls = ls ! i
       | otherwise = error $ "Index " ++ show i ++ " too large"
    where lenls = V.length ls

(##) :: Vector a -> Int -> a
(##) ls x = ls # (-x) 

at :: Int -> Vector a -> a
at = flip (#)

at_ :: Int -> Vector a -> a
at_ x = at (-x)

asBool :: ByteString -> Bool
asBool = (read :: String -> Bool) . LC8.unpack
asb :: ByteString -> Bool
asb = asBool

asDouble :: ByteString -> Double
asDouble = (read :: String -> Double) . LC8.unpack
asd :: ByteString -> Double
asd = asDouble

asFloat :: ByteString -> Float
asFloat = (read :: String -> Float) . LC8.unpack
asf :: ByteString -> Float
asf = asFloat

asInt :: ByteString -> Integer
asInt = (read :: String -> Integer) . LC8.unpack
asi :: ByteString -> Integer
asi = asInt
