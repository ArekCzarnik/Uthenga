{-# LANGUAGE OverloadedStrings #-}

module Handlers.Task where

import Web.Scotty
import Database.Disque
import Control.Monad.IO.Class
import qualified Data.ByteString as B
import qualified Data.Text.Lazy as TL
import Data.String.Conversions (cs)
import Network.HTTP.Types.Status

shouldAddTask :: Maybe Connection -> ActionM ()
shouldAddTask (Just connection) = addTask connection
shouldAddTask Nothing = do
  text "disque current offline!"
  status status500

addTask :: Connection -> ActionM ()
addTask conn = do
  queue <- param "queue" :: ActionM TL.Text
  value <- param "value" :: ActionM TL.Text
  expire <- param "expire" :: ActionM Int
  createdJob <- liftIO (runDisque conn $ addjob (cs queue) (cs value) expire)
  case createdJob of
    Left val -> text (cs $ deconsReplay val)
    Right val -> text (cs val)

deconsReplay :: Reply -> B.ByteString
deconsReplay replay =
      case replay of
            Error code -> code
            _ -> ""

