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

showSubscribers :: Maybe Mysql.MySQLConn -> ActionM ()
showSubscribers (Just connection) = do
  subscribers <- liftIO $ listSubscriber connection
  json subscribers
showSubscribers Nothing = do
  text "mysql current offline!"
  status status500

addSubscriber :: Maybe Mysql.MySQLConn -> ActionM ()
addSubscriber (Just connection) = do
  subscriber <- parseSubscriber
  insertSubscriber connection subscriber
  json subscriber
  status created201
addSubscriber Nothing = do
  text "mysql current offline!"
  status status500

-- Parse the request body into the Subscriber
parseSubscriber :: ActionT Text IO (Maybe Subscriber)
parseSubscriber = do
  b <- body
  return (decode b :: Maybe Subscriber)