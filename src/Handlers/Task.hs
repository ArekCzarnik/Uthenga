{-# LANGUAGE OverloadedStrings #-}

module Handlers.Task where

import Web.Scotty
import Database.Disque
import Control.Monad.IO.Class
import qualified Data.ByteString as B
import qualified Data.Text.Lazy as TL
import Data.String.Conversions (cs)
import Control.Concurrent.Chan (Chan,writeChan,readChan)

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
  print "error found job"
  return ()

jobSender :: Connection -> Chan Job -> IO ()
jobSender conn channel = do
    job <- readChan channel
    putStrLn ("send:" ++ show job)
    ack <- liftIO (runDisque conn $ fastack [jobid job])
    jobSender conn channel

