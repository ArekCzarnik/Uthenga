{-# LANGUAGE DeriveGeneric #-}

module Domain where

import Data.Text.Lazy
import GHC.Generics

data TargetType = SMS | FIREBASE | APNS
     deriving (Show)

data Subscriber = Subscriber {
      id :: Integer
    , target :: TargetType
    , code :: Text
    , userid :: Text
    } deriving (Generic, Show)
     

