{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}

module Types.Message where

import Data.Text.Lazy
import GHC.Generics
import Data.Aeson

data Message = Message
  { sid         :: !Text
  , dateCreated :: !Text
  , dateUpdated :: !Text
  , dateSent    :: !(Maybe Text)
  , accountSID  :: !Text
  , to          :: !Text
  , from        :: !Text
  , body        :: !Text
  , status      :: !Text
--  , numSegments :: !Integer
  , direction   :: !Text
--  , price       :: !Double
  , priceUnit   :: !Text
  , apiVersion  :: !Text
  , uri         :: !Text
  } deriving (Generic, Show, ToJSON, FromJSON)
