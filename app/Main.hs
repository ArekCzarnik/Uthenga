{-# LANGUAGE OverloadedStrings #-}

module Main where

import Application (app)
import Database.Disque
import Network.Wai.Handler.Warp (run)
import qualified Database.RethinkDB as RethinkDB

main :: IO ()
main = do
  putStrLn "[Start Uthenga 0.1 by HackForce]"
  disqueConnection <- setupDisque
  rethinkConnection <- setupRethinkDB
  taskApp <- app disqueConnection rethinkConnection
  run 3000 taskApp

setupDisque :: IO Connection
setupDisque = connect disqueConnectInfo

setupRethinkDB :: IO RethinkDB.RethinkDBHandle
setupRethinkDB = RethinkDB.connect "localhost" 28015 Nothing