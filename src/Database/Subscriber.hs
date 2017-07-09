{-# LANGUAGE OverloadedStrings #-}

module Database.Subscriber where

import Control.Monad.IO.Class
import Database.MySQL.Base
import Types.Subscriber
import System.IO.Streams
import System.IO.Streams.List
import Data.String.Conversions              (cs)

createTableSQL :: Query
createTableSQL =
    "CREATE TABLE IF NOT EXISTS subscriber (id BIGINT NOT NULL AUTO_INCREMENT, target VARCHAR(255) NOT NULL,code VARCHAR(255) NOT NULL, userid VARCHAR(255) NOT NULL,CONSTRAINT pk PRIMARY KEY (id));"

insertSQL :: Query
insertSQL =
    "INSERT INTO subscriber (target, code, userid) VALUES (?, ?, ?);"

selectSQL :: Query
selectSQL = "SELECT * FROM subscriber"

selectWithIDSQL :: Query
selectWithIDSQL = "SELECT * FROM subscriber WHERE id = ?"

deleteSQL :: Query
deleteSQL = "DELETE FROM subscriber WHERE id = ?"

createTable :: MySQLConn -> IO ()
createTable mysqlConnection = do
   _ <- liftIO $ execute_ mysqlConnection createTableSQL
   return ()

insertSubscriber :: Maybe Subscriber -> MySQLConn -> IO ()
insertSubscriber Nothing _ = return ()
insertSubscriber (Just (Subscriber _ target_ code_ userid_)) mysqlConnection = do
  _ <- liftIO $ execute mysqlConnection insertSQL [MySQLText (cs target_), MySQLText (cs code_), MySQLText (cs userid_)]
  return ()

deleteSubscriber :: Integer -> MySQLConn -> IO ()
deleteSubscriber idSubscriber mysqlConnection = do
   _ <- liftIO $ execute mysqlConnection deleteSQL [MySQLInt64 (fromIntegral idSubscriber)]
   return ()

fetchSubscriber :: Integer -> MySQLConn -> IO [Subscriber]
fetchSubscriber idSubscriber pool = do
  result <- drain $ query pool selectWithIDSQL [MySQLInt64 (fromIntegral idSubscriber)]
  return $ Prelude.map convertSubscriber result

listSubscriber :: MySQLConn -> IO [Subscriber]
listSubscriber pool = do
  result <- drain $ query_ pool selectSQL
  return $ Prelude.map convertSubscriber result

convertSubscriber :: [MySQLValue] -> Subscriber
convertSubscriber [MySQLInt64 id_, MySQLText target_, MySQLText code_, MySQLText userid_]
      = Subscriber (fromIntegral id_) (cs target_) (cs code_) (cs userid_)
convertSubscriber _ = undefined

drain :: IO ([ColumnDef], InputStream [MySQLValue]) -> IO [[MySQLValue]]
drain action = do
    (_,ist) <- action
    System.IO.Streams.List.toList ist