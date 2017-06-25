import Database.Disque
import qualified Database.RethinkDB as RethinkDB
import Subscriptions.SubscriptionSpec
import Test.Hspec

main :: IO ()
main = do
  disqueConnection <- setupDisque
  rethinkConnection <- setupRethinkDB
  hspec (mainspec disqueConnection rethinkConnection)

mainspec :: Connection -> RethinkDB.RethinkDBHandle -> Spec
mainspec connection handle = do
  describe "All Subscription Sepcs" (spec connection handle)

setupDisque :: IO Connection
setupDisque = connect disqueConnectInfo

setupRethinkDB :: IO RethinkDB.RethinkDBHandle
setupRethinkDB = RethinkDB.connect "localhost" 28015 Nothing


instance MonadRethinkDB IO where
    rbconnect = connect

class Monad monad => MonadRethinkDB monad where
    rbconnect :: String -> Integer -> Maybe String -> monad Connection
