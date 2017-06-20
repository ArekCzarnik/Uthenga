{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}

import Application (app)
import Database.Disque
import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON
import Data.Aeson (Value(..), object, (.=))


main :: IO ()
main = do
  disqueConnection <- setup
  hspec $
    with (app disqueConnection) $ do
      describe "GET /tasks" $ do
        it "responds with 200" $ do
          get "/tasks" `shouldRespondWith` [json|{expire:0,value:"1",code:"1",id: 1}|] {matchStatus = 200, matchHeaders = ["Content-Type" <:> "application/json; charset=utf-8"]}

      describe "GET /subscribers" $ do
        it "responds with 200" $ do
          get "/subscribers" `shouldRespondWith` 200

setup :: IO Connection
setup = connect disqueConnectInfo