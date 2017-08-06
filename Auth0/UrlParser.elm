module Auth0.UrlParser
    exposing
        ( Auth0CallbackInfo
        , Auth0CallbackError
        , accessTokenUrlParser
        , unauthorizedUrlParser
        )

{-| UrlParser for Auth0 token callback

Recommend o use this library with
`[kkpoon/elm-auth0](https://github.com/kkpoon/elm-auth0)`.

@docs Auth0CallbackInfo, Auth0CallbackError

@docs accessTokenUrlParser, unauthorizedUrlParser

-}

import UrlParser


{-| Callback parameters from Auth0

If no `openid` in `scope` parameters in authorize request, no idToken return

-}
type alias Auth0CallbackInfo =
    { accessToken : String
    , idToken : Maybe String
    , expiresIn : Int
    , tokenType : String
    , state : String
    }


{-| Callback of Error
-}
type alias Auth0CallbackError =
    { error : String
    , description : String
    }


{-| Create a token callback UrlParser

    import UrlParser exposing (..)
    import Auth0.UrlParser exposing (Auth0CallbackInfo, accessTokenUrlParser)

    type Route
        = AccessTokenRoute Auth0CallbackInfo
        | SomeOtherRoute

    route : Parser (Route -> a) a
    route =
        oneOf
            [ map AccessTokenRoute accessTokenUrlParser
            , map SomeOtherRoute (s "others")
            ]

-}
accessTokenUrlParser : UrlParser.Parser (Auth0CallbackInfo -> a) a
accessTokenUrlParser =
    UrlParser.custom "AUTH0_ACCESS_TOKEN" <|
        \segment ->
            if String.startsWith "access_token" segment then
                String.split "&" segment
                    |> List.map (String.split "=")
                    |> List.foldr
                        (\item info ->
                            case item of
                                [ "access_token", token ] ->
                                    { info | accessToken = token }

                                [ "id_token", token ] ->
                                    { info | idToken = Just token }

                                [ "expires_in", sec ] ->
                                    { info
                                        | expiresIn =
                                            sec
                                                |> String.toInt
                                                |> Result.withDefault 0
                                    }

                                [ "token_type", tokenType ] ->
                                    { info | tokenType = tokenType }

                                [ "state", state ] ->
                                    { info | state = state }

                                _ ->
                                    info
                        )
                        (Auth0CallbackInfo "" Nothing 0 "" "")
                    |> Ok
            else
                Err "not access token route"


{-| Create an error callback UrlParser

    import UrlParser exposing (..)
    import Auth0.UrlParser exposing (Auth0CallbackError, unauthorizedUrlParser)

    type Route
        = UnauthorizedRoute Auth0CallbackError
        | SomeOtherRoute

    route : Parser (Route -> a) a
    route =
        oneOf
            [ map UnauthorizedRoute unauthorizedUrlParser
            , map SomeOtherRoute (s "others")
            ]

-}
unauthorizedUrlParser : UrlParser.Parser (Auth0CallbackError -> a) a
unauthorizedUrlParser =
    UrlParser.custom "AUTH0_UNAUTHORIZED" <|
        \segment ->
            if String.startsWith "error" segment then
                String.split "&" segment
                    |> List.map (String.split "=")
                    |> List.foldr
                        (\item error ->
                            case item of
                                [ "error", value ] ->
                                    { error | error = value }

                                [ "error_description", value ] ->
                                    { error | description = value }

                                _ ->
                                    error
                        )
                        (Auth0CallbackError "" "")
                    |> Ok
            else
                Err "not unauthorized route"
