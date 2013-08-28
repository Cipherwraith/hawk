module System.Console.Hawk.Options where

import Data.ByteString (ByteString)

import qualified Data.ByteString.Char8 as C8
import qualified Data.List as L
import qualified System.FilePath as FP

import System.Console.GetOpt


data Modes = EvalMode | ApplyMode | MapMode
    deriving (Eq,Enum,Read,Show)

data Options = Options { optMode :: Modes 
                       , optLinesDelim :: ByteString
                       , optWordsDelim :: ByteString
                       , optRecompile :: Bool
                       , optHelp :: Bool
                       , optIgnoreErrors :: Bool
                       , optModuleFile :: Maybe FP.FilePath}
    deriving Show

defaultOptions :: Options
defaultOptions = Options { optMode = EvalMode
                         , optLinesDelim = C8.singleton '\n'
                         , optWordsDelim = C8.singleton ' '
                         , optRecompile = False
                         , optHelp = False
                         , optIgnoreErrors = False
                         , optModuleFile = Nothing }

delimiter :: ByteString -> ByteString
delimiter = C8.concat . (\ls -> L.head ls:L.map subFirst (L.tail ls))
                     . C8.splitWith (== '\\')
    where subFirst s = case C8.head s of
                        'n' -> C8.cons '\n' $ C8.tail s
                        't' -> C8.cons '\t' $ C8.tail s
                        _ -> s

options :: [OptDescr (Options -> Options)]
options = 
 -- delimiters
 [ Option ['D'] ["lines-delimiter"] (OptArg delimiterAction "<delim>") delimiterHelp
 , Option ['d'] ["words-delimiter"] (OptArg wordsDelimAction "<delim>") wordsDelimHelp

 -- modes
 , Option ['a'] ["apply"] (NoArg $ setMode ApplyMode) applyHelp
 , Option ['m'] ["map"] (NoArg $ setMode MapMode) mapHelp

 -- other options
 , Option ['r'] ["recompile"] (NoArg setRecompile) recompileHelp
 , Option ['h'] ["help"] (NoArg $ \o -> o{ optHelp = True }) helpHelp
 , Option ['k'] ["keep-going"] (NoArg keepGoingAction) keepGoingHelp 
 ]
    where delimiterAction ms o = let d = case ms of
                                            Nothing -> C8.pack ""
                                            Just "" -> C8.pack ""
                                            Just s -> delimiter $ C8.pack s
                                 in o{ optLinesDelim = d } 
          delimiterHelp = "lines delimiter, default '\\n'"
          wordsDelimAction ms o = let d = case ms of
                                            Nothing -> C8.pack ""
                                            Just "" -> C8.pack ""
                                            Just s -> delimiter $ C8.pack s
                                  in o{ optWordsDelim = d}
          wordsDelimHelp = "words delimiter, default ' '"
          setRecompile o = o{ optRecompile = True}
          recompileHelp = "recompile ~/.hawk/prelude.hs\neven if it did not change"
          
          applyHelp = "apply <expr> to the stream"
          mapHelp = "map <expr> to the stream"

          helpHelp = "print this help message and exit"
          keepGoingAction o = o{ optIgnoreErrors = True}
          keepGoingHelp = "keep going when one line fails"
          setMode m o = o{ optMode = m }

compileOpts :: [String] -> Either [String] (Options,[String])
compileOpts argv =
   case getOpt Permute options argv of
      (os,nos,[]) -> Right (L.foldl (.) id (L.reverse os) defaultOptions, nos)
      (_,_,errs) -> Left errs
