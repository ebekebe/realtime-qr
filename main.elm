import Html exposing (..)
import Time exposing (Time, second)
import Date exposing (fromTime)
import Date.Extra exposing (toIsoString)
import QRCode

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model = Maybe Time


init : (Model, Cmd Msg)
init =
  (Nothing, Cmd.none)


-- UPDATE

type Msg
  = Tick Time


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      (Just newTime, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every second Tick


-- VIEW

view : Model -> Html Msg
view model =
  case model of
    Nothing -> text ""
    Just timestamp ->
      let
        timeString = timestamp |> fromTime |> toIsoString
        qrResult = QRCode.toSvg timeString
      in
        div
          []
          [ case qrResult of
              Result.Err err -> text "An error occurred"
              Result.Ok view -> view
          , Html.text timeString
          ]
