{-# LANGUAGE OverloadedStrings #-}

module Main where

import Application (app)
import Database.Disque
import Network.Wai.Handler.Warp (run)
import qualified Database.MySQL.Base as Mysql
import Database.Subscriber
import Data.Pool(createPool)

main :: IO ()
main = do
  putStrLn "[Start Uthenga 0.1 by HackForce]"
  disqueConnection <- setupDisque
  dbConnection <- setupDB
  dbPool <- createPool setupDB Mysql.close 1 40 10
  createTable dbConnection
  uthengaApp <- app disqueConnection dbPool
  run 3000 uthengaApp

setupDisque :: IO Connection
setupDisque = connect disqueConnectInfo

setupDB :: IO Mysql.MySQLConn
setupDB = Mysql.connect Mysql.defaultConnectInfo { Mysql.ciDatabase = "uthenga" }
