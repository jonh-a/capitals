import gleam/list

pub fn get_countries() -> List(#(String, String, String)) {
  [
    #("argentina", "buenos aires", "🇦🇷"),
    #("australia", "canberra", "🇦🇺"),
    #("austria", "vienna", "🇦🇹"),
    #("belarus", "minsk", "🇧🇾"),
    #("belgium", "brussels", "🇧🇪"),
    #("brazil", "brasilia", "🇧🇷"),
    #("bulgaria", "sofia", "🇧🇬"),
    #("canada", "ottawa", "🇨🇦"),
    #("chile", "santiago", "🇨🇱"),
    #("czech republic", "prague", "🇨🇿"),
    #("colombia", "bogota", "🇨🇴"),
    #("ecuador", "quito", "🇪🇨"),
    #("finland", "helsinki", "🇫🇮"),
    #("ghana", "accra", "🇬🇭"),
    #("greece", "athens", "🇬🇷"),
    #("hungary", "budapest", "🇭🇺"),
    #("india", "new delhi", "🇮🇳"),
    #("japan", "tokyo", "🇯🇵"),
    #("mexico", "mexico city", "🇲🇽"),
    #("netherlands", "amsterdam", "🇳🇱"),
    #("poland", "warsaw", "🇵🇱"),
    #("russia", "moscow", "🇷🇺"),
    #("spain", "madrid", "🇪🇸"),
    #("thailand", "bangkok", "🇹🇭"),
    #("ukraine", "kyiv", "🇺🇦"),
    #("united states", "washington, dc", "🇺🇸"),
    #("venezuela", "caracas", "🇻🇪"),
  ]
  |> list.shuffle()
  |> list.take(15)
}
