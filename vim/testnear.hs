import System.Directory
import System.FilePath
import System.Process
import Control.Monad
import Data.Maybe
import Control.Exception
import Control.Monad.Trans.Maybe
import Control.Monad.Trans.Class

dirParents :: FilePath -> [FilePath]
dirParents = takeWhile (/="/") . iterate takeDirectory

inDirConts :: String -> FilePath -> IO Bool
inDirConts x y = elem x <$> getDirectoryContents y

lowMatch :: String -> FilePath -> MaybeT IO FilePath
lowMatch x y = MaybeT $ listToMaybe <$> filterM (inDirConts x) (dirParents y)

testArgs :: MaybeT IO (FilePath, FilePath)
testArgs = do
  modDir <- lowMatch "__init__.py" =<< lift getCurrentDirectory
  baseDir <- lowMatch "manage.py" modDir
  return (takeBaseName modDir, baseDir)

runTest :: (FilePath,FilePath) -> IO ()
runTest (x,y) = callProcess "python" [y ++ "/manage.py", "test", x]

tmuxMessage :: String -> IO ()
tmuxMessage x = callCommand $ "tmux display '" ++ x ++ "'"

main :: IO ()
main = catch runtest handler
  where
    zoomed = elem 'Z' <$> readProcess "tmux" ["display-message", "-p", "'#F'"] []
    runtest = do
      args <- runMaybeT testArgs
      case args of
        Nothing -> tmuxMessage "Found no tests"
        Just x -> do
          runTest x
          not <$> zoomed >>= flip when (callCommand "tmux resize-pane -Z -t {top}")
          tmuxMessage "Tests Succesful"
    handler :: SomeException -> IO ()
    handler _ = zoomed >>= flip when (callCommand "tmux resize-pane -Z")
