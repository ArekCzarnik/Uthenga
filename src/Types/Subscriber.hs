{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}

module Types.Subscriber where

import Data.Text.Lazy
import GHC.Generics
import Data.Aeson

data Subscriber = Subscriber {
      id :: Integer
    , target :: Text
    , code :: Text
    , userid :: Text
    } deriving (Generic, Show, ToJSON, FromJSON)