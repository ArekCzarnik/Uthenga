{-# LANGUAGE OverloadedStrings #-}

module Database.Subscriber where

import Control.Monad.IO.Class
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TL
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.Text as T
import Web.Scotty.Internal.Types (ActionT)
import Database.MySQL.Base
import Types.Subscriber
import System.IO.Streams
import System.IO.Streams.List
import Data.String.Conversions              (cs)


usersTableSQL :: Query
usersTableSQL =
    "CREATE TABLE IF NOT EXISTS subscriber (id BIGINT NOT NULL AUTO_INCREMENT, target VARCHAR(255) NOT NULL,code VARCHAR(255) NOT NULL, userid VARCHAR(255) NOT NULL,CONSTRAINT pk PRIMARY KEY (id));"

insertTokenSQL :: Query
insertTokenSQL =
    "INSERT INTO subscriber (target, code, userid) VALUES (?, ?, ?);"


insertSubscriber :: MySQLConn -> Maybe Subscriber -> ActionT TL.Text IO ()
insertSubscriber mysqlConnection Nothing = return ()
insertSubscriber mysqlConnection (Just (Subscriber id_ target_ code_ userid_)) = do
  _ <- liftIO $ execute mysqlConnection insertTokenSQL [MySQLText (cs target_), MySQLText (cs code_), MySQLText (cs userid_)]
  return ()


drain :: IO ([ColumnDef], InputStream [MySQLValue]) -> IO [[MySQLValue]]
drain action = do
    (_,ist) <- action
    System.IO.Streams.List.toList ist