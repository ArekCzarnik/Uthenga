{-# LANGUAGE OverloadedStrings #-}

module Application where

import Database.Disque
import qualified Database.MySQL.Base as Mysql
import Handlers.Task
import Handlers.Subscriber
import Network.Wai (Application)
import Network.Wai.Middleware.RequestLogger (logStdout)
import Web.Scotty
import Data.Pool(Pool)
import Control.Concurrent.Chan (newChan)
import Control.Concurrent (forkIO)
import Network.HTTP.Client
import Network.HTTP.Client.TLS
import qualified Data.Configurator as C
import qualified Data.Configurator.Types as C
import Types.Configuration

-- Parse file "application.conf" and get configuration info
makeConfig :: C.Config -> IO (Maybe Configuration)
makeConfig conf = do
  accountid <- C.lookup conf "twilio.accountid" :: IO (Maybe String)
  authtoken <- C.lookup conf "twilio.authtoken" :: IO (Maybe String)
  from <- C.lookup conf "twilio.from" :: IO (Maybe String)
  bodymessage <- C.lookup conf "twilio.bodymessage" :: IO (Maybe String)
  url <- C.lookup conf "twilio.url" :: IO (Maybe String)
  return $ Configuration <$> accountid
                    <*> authtoken
                    <*> from
                    <*> bodymessage
                    <*> url

app :: Connection -> Pool Mysql.MySQLConn -> IO Application
app disqueConnection dbPool = do
  loadedConf <- C.load [C.Required "application.conf"]
  configuration <- makeConfig loadedConf
  case configuration of
      Nothing -> undefined "No configuration found, terminating..."
      Just conf -> do   
         taskChannel <- newChan
         httpClientManager <- newManager tlsManagerSettings
         _ <- forkIO (pullTask taskChannel disqueConnection)
         _ <- forkIO (jobSender conf httpClientManager disqueConnection taskChannel)
         scottyApp $ do
           middleware logStdout -- log all requests; for production use logStdout
       --  Subscriber part
           get "/subscribers" $ showSubscribers dbPool
           get "/subscribers/:id" $ showSubscriber dbPool
           delete "/subscribers/:id" $ deleteSubscribers dbPool
           post "/subscribers" (addSubscriber dbPool)
       --  Task part
           post "/tasks/:queue/:value/:expire" (addTask disqueConnection)




