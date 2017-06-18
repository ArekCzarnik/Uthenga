{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Database.Disque
import Data.ByteString (ByteString)
import Control.Monad.IO.Class
import qualified Data.ByteString as B

main :: IO ()
main = do
    conn <- setup 
    runDisque conn $ do
       result <- addjob "test_queue" "test data" 0
       liftIO $ print (disqueResult result)


setup = do
  conn <- connect $ disqueConnectInfo { connectHost = "127.0.0.1" }
  return conn

disqueResult :: Either Reply ByteString -> ByteString
disqueResult result = do
              case result of
                Left  val ->  "error"
                Right val ->  val

