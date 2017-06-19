module Domain where

import qualified Data.Text.Lazy as TL

data TargetType = SMS | FIREBASE | APNS
     deriving (Show)

type Code = TL.Text

type UserId = TL.Text

data Subscriber = Subscriber Integer TargetType Code UserId -- id target(example:SMS) code (example:phone_number) userid
     deriving (Show)
