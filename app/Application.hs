{-# LANGUAGE OverloadedStrings #-}

module Application where

import Data.Aeson (encode)
import Data.String.Conversions (cs)
import Database.Disque
import qualified Database.RethinkDB as RethinkDB
import Handlers.Task
import Network.Wai (Application)
import Network.Wai.Middleware.RequestLogger (logStdout)
import Types.Subscriber
import Types.Task
import Web.Scotty

app :: Connection -> RethinkDB.RethinkDBHandle -> IO Application
app disqueConnection rethinkConnection = scottyApp $ do
          let task = Task 1 "1" "1" 0
          let subscriber = Subscriber 1 "" "" ""
          middleware logStdout -- log all requests; for production use logStdout
          get "/subscribers" (text $ cs $ encode subscriber)
          get "/tasks" $ do
              json task
          post "/tasks/:queue/:value/:expire" (addTask disqueConnection)