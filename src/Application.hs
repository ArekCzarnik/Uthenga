{-# LANGUAGE OverloadedStrings #-}

module Application where

import Database.Disque
import qualified Database.MySQL.Base as Mysql
import Handlers.Task
import Handlers.Subscriber
import Network.Wai (Application)
import Network.Wai.Middleware.RequestLogger (logStdout)
import Web.Scotty
import Data.Pool(Pool)
import Control.Concurrent.Chan (newChan)
import Control.Concurrent (forkIO)

app :: Connection -> Pool Mysql.MySQLConn -> IO Application
app disqueConnection dbPool = do
  taskChannel <- newChan
  _ <- forkIO (pullTask taskChannel disqueConnection)
  _ <- forkIO (jobSender disqueConnection taskChannel)
  scottyApp $ do
    middleware logStdout -- log all requests; for production use logStdout
--  Subscriber part
    get "/subscribers" $ showSubscribers dbPool
    get "/subscribers/:id" $ showSubscriber dbPool
    delete "/subscribers/:id" $ deleteSubscribers dbPool
    post "/subscribers" (addSubscriber dbPool)
--  Task part
    post "/tasks/:queue/:value/:expire" (addTask disqueConnection)




