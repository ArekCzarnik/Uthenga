{-# LANGUAGE OverloadedStrings #-}

module Handlers.Subscriber where

import Control.Monad.IO.Class
import Data.Aeson (decode)
import Data.Text.Lazy (Text)
import qualified Database.MySQL.Base as Mysql
import Database.Subscriber
import Network.HTTP.Types.Status
import Types.Subscriber
import Web.Scotty
import Web.Scotty.Internal.Types (ActionT)
import Data.Pool (Pool, tryWithResource)

showSubscribers :: Pool Mysql.MySQLConn -> ActionM ()
showSubscribers dbPool = do
  subscribers <- liftIO (tryWithResource dbPool listSubscriber)
  json subscribers

addSubscriber :: Pool Mysql.MySQLConn -> ActionM ()
addSubscriber dbPool = do
  subscriber <- parseSubscriber
  liftIO $ tryWithResource dbPool $ insertSubscriber subscriber
  json subscriber
  status created201

-- Parse the request body into the Subscriber
parseSubscriber :: ActionT Text IO (Maybe Subscriber)
parseSubscriber = do
  b <- body
  return (decode b :: Maybe Subscriber)