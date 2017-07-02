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
import Control.Concurrent.Chan (Chan,newChan,readChan)
import Control.Concurrent (forkIO)

app :: Connection -> Pool Mysql.MySQLConn -> IO Application
app disqueConnection dbPool = do
  messages <- newChan
  _ <- forkIO (messageReader messages)
  _ <- forkIO (pullTask disqueConnection)
  scottyApp $ do
    middleware logStdout -- log all requests; for production use logStdout
    get "/subscribers" $ showSubscribers dbPool
    get "/subscribers/:id" $ showSubscriber dbPool
    delete "/subscribers/:id" $ deleteSubscribers dbPool
    post "/subscribers" (addSubscriber dbPool)
    get "/tasks/:queue" (getTask disqueConnection)
    post "/tasks/:queue/:value/:expire" (shouldAddTask disqueConnection)


messageReader :: Chan String -> IO ()
messageReader channel = do
    msg <- readChan channel
    putStrLn (" read: " ++ msg)

