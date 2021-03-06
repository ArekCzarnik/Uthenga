{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}


module Subscriptions.SubscriptionSpec (spec) where

import Application (app)
import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON
import Database.Disque
import qualified Database.MySQL.Base as Mysql
import Data.Pool(Pool)


spec :: Connection -> Pool Mysql.MySQLConn -> Spec
spec connection dbPool = do
    with (app connection dbPool) $ do
      describe "Operation on /tasks Resource" $ do
        it "responds with 200" $ do
          post "/tasks/sms/test/1" "" `shouldRespondWith` 200

      describe "GET /subscribers" $ do
        it "create responds with 200" $ do
          post "/subscribers" [json|{target:"form test",userid:"1",code:"1",id: 1}|] `shouldRespondWith` 201
        it "fetch subscriber should responds with 200" $ do
          get "/subscribers" `shouldRespondWith` 200
        it "fetch subscriber with id 1 should responds with 200" $ do
          get "/subscribers/1" `shouldRespondWith` 200
        it "delete subscriber should response 200" $ do
          delete "/subscribers/1"  `shouldRespondWith` 200


