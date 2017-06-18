{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Database.Disque
import Control.Monad.IO.Class
import qualified Data.ByteString as B
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Encoding as T
import Data.String.Conversions (cs)


main :: IO ()
main = do
  conn <- setup
  scotty 3000 $ get "/:queue/:value/:expire" (postJob conn)

postJob :: Connection -> ActionM ()
postJob conn = do
  queue <- param ("queue" :: TL.Text) :: ActionM TL.Text
  value <- param ("value" :: TL.Text) :: ActionM TL.Text
  expire <- param ("text" :: TL.Text) :: ActionM TL.Text
  createdJob <- liftIO (runDisque conn $ addjob (cs queue) (cs value) 0)
  case createdJob of
    Left val -> text (cs $ deconsReplay val)
    Right val -> text (cs val)

setup :: IO Connection
setup = connect $ disqueConnectInfo

deconsReplay :: Reply -> B.ByteString
deconsReplay replay =
      case replay of
            Error code -> code
            _ -> ""