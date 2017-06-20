{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Database.Disque
import Network.Wai.Middleware.RequestLogger (logStdout)
import Data.String.Conversions (cs)
import Types.Task
import Types.Subscriber
import Handlers.Task
import Data.Aeson (encode)

main :: IO ()
main = do
  let task = Task 1 "" "" 0
  let subscriber = Subscriber 1 "" "" ""
  conn <- setup
  scotty 3000 $ do
    middleware logStdout -- log all requests; for production use logStdout
    get "/subscribers" (text $ cs $ encode subscriber)
    get "/tasks" (text $ cs $ encode task)
    post "/tasks/:queue/:value/:expire" (addTask conn)

setup :: IO Connection
setup = connect disqueConnectInfo
