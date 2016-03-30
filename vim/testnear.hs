import System.Directory
import System.FilePath
import System.Process
import Control.Monad
import Data.Maybe
import Control.Exception

dirParents :: FilePath -> [FilePath]
dirParents = takeWhile (/="/") . iterate takeDirectory

inDirConts :: String -> FilePath -> IO Bool
inDirConts x y = elem x <$> getDirectoryContents y

lowMatch :: String -> FilePath -> IO (Maybe FilePath)
lowMatch x y = listToMaybe <$> filterM (inDirConts x) (dirParents y)

cmdArgs :: IO (Maybe [FilePath])
cmdArgs = do
  mod_dir <- getCurrentDirectory >>= lowMatch "__init__.py"
  base_dir <- maybe (return Nothing) (lowMatch "manage.py") mod_dir
  return $ sequence [base_dir, fmap takeBaseName mod_dir]

runCmd :: Maybe [String] -> IO ()
runCmd (Just (x:y:[])) = callProcess "python" [x ++ "/manage.py", "test", y]
runCmd _ = return ()

main :: IO ()
main = catch runtest handler
  where
    flags = readProcess "tmux" ["display-message", "-p", "'#F'"] []
    runtest = do
      cmdArgs >>= runCmd
      (notElem 'Z' <$> flags) >>= flip when (callCommand "tmux resize-pane -Z -t {top}")
      callCommand "tmux display 'Tests Succesful'"
    handler :: SomeException -> IO ()
    handler _ = (elem 'Z' <$> flags) >>= flip when (callCommand "tmux resize-pane -Z")
