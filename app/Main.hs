{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Database.Disque
import Network.Wai.Middleware.RequestLogger (logStdout)
import Control.Monad.IO.Class
import qualified Data.ByteString as B
import qualified Data.Text.Lazy as TL
import Data.String.Conversions (cs)
import Types.Task
import Types.Subscriber
import Data.Aeson (encode)


main :: IO ()
main = do
  let task = Task 1 "" "" 0
  let subscriber = Subscriber 1 "" "" ""
  conn <- setup
  scotty 3000 $ do
    middleware logStdout -- log all requests; for production use logStdout
    get "/subscribers" (text $ cs $ encode subscriber)
    get "/tasks" (text $ cs $ encode task)
    post "/tasks/:queue/:value/:expire" (postJob conn)


postJob :: Connection -> ActionM ()
postJob conn = do
  queue <- param "queue" :: ActionM TL.Text
  value <- param "value" :: ActionM TL.Text
  expire <- param "expire" :: ActionM TL.Text
  createdJob <- liftIO (runDisque conn $ addjob (cs queue) (cs value) 0)
  case createdJob of
    Left val -> text (cs $ deconsReplay val)
    Right val -> text (cs val)

setup :: IO Connection
setup = connect disqueConnectInfo

deconsReplay :: Reply -> B.ByteString
deconsReplay replay =
      case replay of
            Error code -> code
            _ -> ""