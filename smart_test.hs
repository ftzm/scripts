import System.Directory
import System.FilePath
import System.Process
import Control.Monad
import Data.Maybe
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

main :: IO ()
main = mapM_ runTest =<< runMaybeT testArgs
