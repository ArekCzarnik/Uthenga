{-# LANGUAGE DeriveGeneric #-}

module Types.Task where

import Data.Text.Lazy
import GHC.Generics
import Data.Aeson

data Task = Task {
      id :: Integer
    , code :: Text
    , value :: Text
    , expire :: Int
} deriving (Generic, Show)

instance FromJSON Task
instance ToJSON Task