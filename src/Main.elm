module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Time exposing (Posix, utc, toMillis)
-- import Date exposing (fromTime)
import Iso8601
import QRCode
import Svg.Attributes as SvgA

main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model = Maybe Posix


init : () -> (Model, Cmd Msg)
init _ =
  (Nothing, Cmd.none)


-- UPDATE

type Msg
  = Tick Posix


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      case model of
        Nothing -> (Just newTime, Cmd.none)
        Just _ -> (Nothing, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every 10.0 Tick


-- VIEW

view : Model -> Html Msg
view model =
  case model of
    Nothing -> text ""
    Just timestamp ->
      let
        -- timeString = (timestamp |> Iso8601.fromTime |> String.dropRight 5) ++ "Z"
        timeString = (timestamp |> Iso8601.fromTime)
        qrResult = QRCode.fromString timeString
          |> Result.map (
            QRCode.toSvgWithoutQuietZone [ SvgA.width "200px", SvgA.height "200px"]
          )
        milliseconds = timestamp |> toMillis utc |> toFloat
      in
        div
          [ style "padding" "20px" ]
          [ Html.node "link" [ Html.Attributes.rel "stylesheet", Html.Attributes.href "style.css" ] []
          , h1 [] [text timeString]
          , div
            [ class "qrcode" ]
            [ case qrResult of
                Result.Err err -> text "An error occurred"
                -- Result.Ok view -> { view | facts = { facts | ATTR = { ATTR | height = Nothing }}}
                Result.Ok theView -> theView
            ]
          , div
            [ style "width" ((String.fromFloat (milliseconds/5)) ++ "px")
            , style "height" "100px"
            , style "background-color" "black"
            ]
            []
          , div
            [ style "width" "200px"
            , style "height" "100px"
            , style "background-color" "black"
            ]
            []
          ]
