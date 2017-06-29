{-# LANGUAGE OverloadedStrings #-}

module Application where

import Database.Disque
import qualified Database.MySQL.Base as Mysql
import Handlers.Task
import Handlers.Subscriber
import Network.Wai (Application)
import Network.Wai.Middleware.RequestLogger (logStdout)
import Types.Task
import Web.Scotty
import Data.Pool(Pool, createPool, withResource)

app :: Connection -> Pool Mysql.MySQLConn -> IO Application
app disqueConnection dbPool =
  scottyApp $ do
    let task = Task 1 "1" "1" 0
    middleware logStdout -- log all requests; for production use logStdout
    get "/subscribers" $ showSubscribers dbPool
    post "/subscribers" (addSubscriber dbPool)
    get "/tasks" . json $ task
    post "/tasks/:queue/:value/:expire" (shouldAddTask disqueConnection)



