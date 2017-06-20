{-# LANGUAGE OverloadedStrings #-}

module Main where

import Application (app)
import Database.Disque
import Network.Wai.Handler.Warp (run)

main :: IO ()
main = do
  putStrLn "[Start Uthenga 0.1 by HackForce]"
  disqueConnection <- setup
  taskApp <- app disqueConnection
  run 3000 taskApp

setup :: IO Connection
setup = connect disqueConnectInfo