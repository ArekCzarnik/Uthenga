{-# LANGUAGE DeriveGeneric #-}

module Domain where

import Data.Text.Lazy
import GHC.Generics
import Data.Aeson

data TargetType = SMS | FIREBASE | APNS
     deriving (Show)

data Subscriber = Subscriber {
      id :: Integer
    , target :: Text
    , code :: Text
    , userid :: Text
    } deriving (Generic, Show)

instance FromJSON Subscriber
instance ToJSON Subscriber