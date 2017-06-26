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


createTableSQL :: Query
createTableSQL =
    "CREATE TABLE IF NOT EXISTS subscriber (id BIGINT NOT NULL AUTO_INCREMENT, target VARCHAR(255) NOT NULL,code VARCHAR(255) NOT NULL, userid VARCHAR(255) NOT NULL,CONSTRAINT pk PRIMARY KEY (id));"

insertSQL :: Query
insertSQL =
    "INSERT INTO subscriber (target, code, userid) VALUES (?, ?, ?);"

selectSQL :: Query
selectSQL = "SELECT * FROM subscriber"

insertSubscriber :: MySQLConn -> Maybe Subscriber -> ActionT TL.Text IO ()
insertSubscriber mysqlConnection Nothing = return ()
insertSubscriber mysqlConnection (Just (Subscriber id_ target_ code_ userid_)) = do
  _ <- liftIO $ execute mysqlConnection insertSQL [MySQLText (cs target_), MySQLText (cs code_), MySQLText (cs userid_)]
  return ()

-- listSubscriber :: MySQLConn -> IO [Subscriber]
-- listSubscriber pool = do
--      (defs, is) <- query_ pool selectSQL
--      return $ Prelude.map (\(id, title, bodyText) -> Subscriber id title bodyText) (System.IO.Streams.List.toList is)


drain :: IO ([ColumnDef], InputStream [MySQLValue]) -> IO [[MySQLValue]]
drain action = do
    (_,ist) <- action
    System.IO.Streams.List.toList ist