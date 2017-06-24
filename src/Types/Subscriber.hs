{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}

module Types.Subscriber where

import Data.Text.Lazy
import GHC.Generics
import Data.Aeson

data TargetType = SMS | FIREBASE | APNS
     deriving (Show, Enum)

data Subscriber = Subscriber {
      id :: Integer
    , target :: Text
    , code :: Text
    , userid :: Text
    } deriving (Generic, Show, ToJSON, FromJSON)