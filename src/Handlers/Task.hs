{-# LANGUAGE OverloadedStrings #-}

module Handlers.Task where

import Web.Scotty
import Database.Disque
import Control.Monad.IO.Class
import qualified Data.Text.Lazy as TL
import Data.String.Conversions (cs)
import Control.Concurrent.Chan (Chan,writeChan,readChan)
import Network.HTTP.Client
import Network.HTTP.Types.Status (statusCode)
import Types.Configuration

addTask :: Connection -> ActionM ()
addTask conn = do
  queue_ <- param "queue" :: ActionM TL.Text
  value <- param "value" :: ActionM TL.Text
  expire <- param "expire" :: ActionM Int
  createdJob <- liftIO (runDisque conn $ addjob (cs queue_) (cs value) expire)
  case createdJob of
    Left val -> text (cs $ show val)
    Right val -> text (cs val)                           

pullTask :: Chan Job -> Connection -> IO ()
pullTask taskChannel conn = do
  job <- liftIO (runDisque conn $ getjobs ["sms"] 1)
  handleTask taskChannel job
  pullTask taskChannel conn
  return ()

handleTask :: Chan Job -> Either Reply [Job] -> IO ()
handleTask taskChannel (Right joblist) = do
  let currentJob = head joblist
  writeChan taskChannel currentJob
  return ()
handleTask _ (Left val) = do
  print (show val)
  return ()

jobSender :: Configuration -> Manager -> Connection -> Chan Job -> IO ()
jobSender conf httpManager conn channel = do
  job <- readChan channel
  putStrLn ("task:" ++ show job)
  _ <- liftIO (runDisque conn $ fastack [jobid job])
    -- Create the request
  initialRequest <- parseRequest (url conf)
  let auth = applyBasicAuth (cs $ accountid conf) (cs $ authtoken conf) initialRequest
      body = urlEncodedBody [("To", "+4915111441671"), ("From", cs $ from conf), ("Body", cs $ bodymessage conf)] auth
      request_ = body {method = "POST"}
  response <- httpLbs request_ httpManager
  putStrLn $ "The status code was: " ++ show (statusCode $ responseStatus response)
  print $ responseBody response
  jobSender conf httpManager conn channel

