{-# LANGUAGE OverloadedStrings #-}

module Main where

import Application (app)
import Database.Disque
import Network.Wai.Handler.Warp (run)
import qualified Database.MySQL.Base as Mysql
import Database.Subscriber

main :: IO ()
main = do
  putStrLn "[Start Uthenga 0.1 by HackForce]"
  disqueConnection <- setupDisque
  dbConnection <- setupDB
  createTable dbConnection
  taskApp <- app (Just disqueConnection) (Just dbConnection)
  run 3000 taskApp

setupDisque :: IO Connection
setupDisque = connect disqueConnectInfo

setupDB :: IO Mysql.MySQLConn
setupDB = Mysql.connect Mysql.defaultConnectInfo { Mysql.ciDatabase = "uthenga" }
