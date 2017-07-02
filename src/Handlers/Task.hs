{-# LANGUAGE OverloadedStrings #-}

module Handlers.Task where

import Web.Scotty
import Database.Disque
import Control.Monad.IO.Class
import qualified Data.ByteString as B
import qualified Data.Text.Lazy as TL
import Data.String.Conversions (cs)

shouldAddTask :: Connection -> ActionM ()
shouldAddTask = addTask

addTask :: Connection -> ActionM ()
addTask conn = do
  queue <- param "queue" :: ActionM TL.Text
  value <- param "value" :: ActionM TL.Text
  expire <- param "expire" :: ActionM Int
  createdJob <- liftIO (runDisque conn $ addjob (cs queue) (cs value) expire)
  case createdJob of
    Left val -> text (cs $ deconsReplay val)
    Right val -> text (cs val)

pullTask :: Connection -> IO ()
pullTask conn = do
  job <- liftIO (runDisque conn $ getjobs ["sms"] 1)
  handleTask job
  pullTask conn
  return ()

handleTask :: Either Reply [Job] -> IO ()
handleTask (Right val) = do
  print val
  return ()
handleTask (Left val) = do
  print val
  return ()


deconsReplay :: Reply -> B.ByteString
deconsReplay replay =
      case replay of
            SingleLine code -> code
            _ -> ""

