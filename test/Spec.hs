{-# LANGUAGE OverloadedStrings #-}

import Application (app)
import Database.Disque
import Test.Hspec
import Test.Hspec.Wai

main :: IO ()
main = do
  disqueConnection <- setup
  hspec $
    with (app disqueConnection) $ do
      describe "GET /tasks" $ do
        it "responds with 200" $ do
          get "/tasks" `shouldRespondWith` 200

setup :: IO Connection
setup = connect disqueConnectInfo