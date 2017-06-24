{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}

module Types.Task where

import Data.Text.Lazy
import GHC.Generics
import Data.Aeson

data Task = Task {
      id :: Integer
    , code :: Text
    , value :: Text
    , expire :: Int
} deriving (Generic, Show, ToJSON, FromJSON)