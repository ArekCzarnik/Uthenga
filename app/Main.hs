{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Database.Disque
import Control.Monad.IO.Class
import Data.Text.Encoding
import qualified Data.ByteString as B
import qualified Data.Text.Lazy.Encoding as TL
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Encoding as T

main :: IO ()
main = do
  conn <- setup
  scotty 3000 $ get "/:queue/:text/:expire" (postJob conn)

postJob :: Connection -> ActionM ()
postJob conn = do
  createdJob <- liftIO (runDisque conn $ addjob "test_queue" "test data" 0)
  case createdJob of
    Left val -> text (decode $ deconsReplay val)
    Right val -> text (decode val)

setup :: IO Connection
setup = connect $ disqueConnectInfo {connectHost = "127.0.0.1"}

decode :: B.ByteString -> TL.Text
decode = TL.fromStrict . T.decodeUtf8

deconsReplay :: Reply -> B.ByteString
deconsReplay replay =
      case replay of
            Error code -> code
            _ -> ""