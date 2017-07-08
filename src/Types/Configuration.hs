{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}

module Types.Configuration where

import GHC.Generics
import Data.Aeson


data Configuration = Configuration {
      accountid :: String
    , authtoken :: String
    , from :: String
    , bodymessage :: String
    , url :: String
} deriving (Generic, Show, ToJSON, FromJSON)