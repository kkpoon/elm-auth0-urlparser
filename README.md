# elm-auth0-urlparser

Help function to create an UrlParser of Auth0 token callback.

Recommend to use this library with
`[kkpoon/elm-auth0](https://github.com/kkpoon/elm-auth0)`.

## Example

In your routing module...

```elm
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
```