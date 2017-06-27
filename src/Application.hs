{-# LANGUAGE OverloadedStrings #-}

module Application where

import Control.Monad.IO.Class
import Data.Aeson (decode, encode)
import Data.String.Conversions (cs)
import Data.Text.Lazy (Text)
import Database.Disque
import qualified Database.MySQL.Base as Mysql
import Database.Subscriber
import Handlers.Task
import Network.HTTP.Types.Status
import Network.Wai (Application)
import Network.Wai.Middleware.RequestLogger (logStdout)
import Types.Subscriber
import Types.Task
import Web.Scotty
import Web.Scotty.Internal.Types (ActionT)

app :: Maybe Connection -> Maybe Mysql.MySQLConn -> IO Application
app disqueConnection mysqlConnection =
  scottyApp $ do
    let task = Task 1 "1" "1" 0
    middleware logStdout -- log all requests; for production use logStdout
    get "/subscribers" $ showSubscribers mysqlConnection
    post "/subscribers" (addSubscriber mysqlConnection)
    get "/tasks" . json $ task
    post "/tasks/:queue/:value/:expire" (shouldAddTask disqueConnection)

shouldAddTask :: Maybe Connection -> ActionM ()
shouldAddTask (Just connection) = addTask connection
shouldAddTask Nothing = do
  text "disque current offline!"
  status status500

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