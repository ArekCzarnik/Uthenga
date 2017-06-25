
import qualified Database.Disque as Disque
import qualified Database.MySQL.Base as Mysql
import Subscriptions.SubscriptionSpec
import Test.Hspec

main :: IO ()
main = do
  disqueConnection <- setupDisque
  dbConnection <- setupDB
  hspec (mainspec disqueConnection dbConnection)

mainspec :: Disque.Connection -> Mysql.MySQLConn -> Spec
mainspec connection db = do
  describe "All Subscription Sepcs" (spec connection db)

setupDisque :: MonadDisque m => m Disque.Connection
setupDisque = connect Disque.disqueConnectInfo

setupDB :: IO Mysql.MySQLConn
setupDB = Mysql.connect Mysql.defaultConnectInfo

-- https://lexi-lambda.github.io/blog/2016/10/03/using-types-to-unit-test-in-haskell/

instance MonadDisque IO where
    connect = Disque.connect

class Monad monad => MonadDisque monad where
    connect :: Disque.ConnectInfo -> monad Disque.Connection