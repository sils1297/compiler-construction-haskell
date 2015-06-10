-- automatically generated by BNF Converter
module Main where


import System.IO ( stdin, hGetContents )
import System.Environment ( getArgs, getProgName )
import System.Exit ( exitFailure, exitSuccess )

import LexCPP
import ParCPP
import SkelCPP
import PrintCPP
import AbsCPP
import TypeChecker




import ErrM

type ParseFun a = [Token] -> Err a

myLLexer = myLexer

type Verbosity = Int

putStrV :: Verbosity -> String -> IO ()
putStrV v s = if v > 1 then putStrLn s else return ()

runFile :: Verbosity -> ParseFun Program -> FilePath -> IO ()
runFile v p f = putStrLn f >> readFile f >>= run v p

run :: Verbosity -> ParseFun Program -> String -> IO ()
run v p s = let ts = myLLexer s in case p ts of
           Bad s    -> do putStrLn "\nParse              Failed...\n"
                          putStrV v "Tokens:"
                          putStrV v $ show ts
                          putStrLn s
                          exitFailure
           Ok  tree -> do putStrLn "\nParse Successful!"
                          showTree v tree
                          case typecheck tree of
                            Bad s -> do
                                       putStrLn "\nFuck, Type check failed...\n"
                                       putStrLn s
                                       exitFailure
                            Ok instructions -> do
                                         putStrLn "\nHell Yeah, your shit type checked\n"
                                         mapM_ putStrLn instructions
                                         exitSuccess


showTree :: (Show a, Print a) => Int -> a -> IO ()
showTree v tree
 = do
      putStrV v $ "\n[Abstract Syntax]\n\n" ++ show tree
      putStrV v $ "\n[Linearized tree]\n\n" ++ printTree tree

main :: IO ()
main = do args <- getArgs
          case args of
            [] -> hGetContents stdin >>= run 2 pProgram
            "-s":fs -> mapM_ (runFile 0 pProgram) fs
            fs -> mapM_ (runFile 2 pProgram) fs





