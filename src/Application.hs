{-# LANGUAGE OverloadedStrings #-}

module Application where

import           Data.Aeson                           (encode,decode)
import           Data.String.Conversions              (cs)
import           Database.Disque
import qualified Database.MySQL.Base as Mysql
import           Handlers.Task
import           Network.Wai                          (Application)
import           Network.Wai.Middleware.RequestLogger (logStdout)
import           Types.Subscriber
import           Types.Task
import           Web.Scotty
import           Web.Scotty.Internal.Types (ActionT)
import           Network.HTTP.Types.Status
import           Data.Text.Lazy (Text)


app :: Maybe Connection -> Maybe Mysql.MySQLConn -> IO Application
app disqueConnection mysqlConnection =
  scottyApp $ do
    let task = Task 1 "1" "1" 0
    let subscriber = Subscriber 1 "" "" ""
    middleware logStdout -- log all requests; for production use logStdout
    get "/subscribers" . json $ subscriber
    post "/subscribers" addSubscriber
    get "/tasks" . json $ task
    post "/tasks/:queue/:value/:expire" (shouldAddTask disqueConnection)

shouldAddTask :: Maybe Connection -> ActionM ()
shouldAddTask (Just connection) = addTask connection
shouldAddTask Nothing           = text "disque current offline!"

addSubscriber :: ActionM ()
addSubscriber = do
          subscriber <- parseSubscriber
          json $ subscriber
          status created201


-- Parse the request body into the Subscriber
parseSubscriber :: ActionT Text IO (Maybe Subscriber)
parseSubscriber = do
  b <- body
  return (decode b :: Maybe Subscriber)