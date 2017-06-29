{-# LANGUAGE OverloadedStrings #-}

import qualified Database.Disque as Disque
import qualified Database.MySQL.Base as Mysql
import Subscriptions.SubscriptionSpec
import Test.Hspec
import Database.Subscriber
import Data.Pool(Pool,createPool,tryWithResource)


main :: IO ()
main = do
  disqueConnection <- setupDisque
  dbPool <- createPool setupDB Mysql.close 1 40 10
  _ <- tryWithResource dbPool createTable
  hspec (mainspec disqueConnection dbPool)

mainspec :: Disque.Connection -> Pool Mysql.MySQLConn -> Spec
mainspec connection dbPool = describe "All Subscription Sepcs" (spec connection dbPool)

setupDisque :: MonadDisque m => m Disque.Connection
setupDisque = connect Disque.disqueConnectInfo

setupDB :: IO Mysql.MySQLConn
setupDB = Mysql.connect Mysql.defaultConnectInfo { Mysql.ciDatabase = "uthenga" }

-- https://lexi-lambda.github.io/blog/2016/10/03/using-types-to-unit-test-in-haskell/

instance MonadDisque IO where
    connect = Disque.connect

class Monad monad => MonadDisque monad where
    connect :: Disque.ConnectInfo -> monad Disque.Connection