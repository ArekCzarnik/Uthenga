
-- | Disque client <https://github.com/antirez/disqueue>

{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE CPP                        #-}

module Database.MockDisque
    (
      Disque
    , runDisque

    , Connection
    , ConnectInfo(..)
    , Reply(..)

    , Job(..)
    , JobId

      -- Create and run disque
    , disqueConnectInfo
    , connect

      -- * Main API
    , addjob
    ) where

import qualified Data.ByteString.Char8 as BS8

#if !MIN_VERSION_base(4,8,0)
import Data.Monoid
import Control.Applicative
#endif

import Data.ByteString        (ByteString)
import Database.Redis as R

newtype Disque a
  = Disque a
    deriving (Show)

-- | Run disque transformer
runDisque :: Connection -> Disque a -> IO a
runDisque c (Disque m) = undefined


-- | Disque job
--
-- Job IDs start with a DI and end with an SQ and are always 48 characters
type JobId = ByteString
type Queue = ByteString
type Data  = ByteString

data Job = Job Queue JobId Data
           deriving Show


-- | Disque connection information
--
-- Use this smart constructor to override specifics
-- to your client connection
--
-- e.g.
--
-- > disqueConnectInfo { connectPort = PortNumber 7712 }
--
disqueConnectInfo :: ConnectInfo
disqueConnectInfo
  = defaultConnectInfo {
      connectHost = "127.0.0.1"
    , connectPort = PortNumber 7711
    }

mockResponse :: ByteString -> Either Reply ByteString
mockResponse bytestring = Right bytestring

addjob :: ByteString -> ByteString -> Int -> Disque (Either Reply ByteString)
addjob q jobdata _timeout = Disque $ mockResponse "addJob"

