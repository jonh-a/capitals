import gleam/list

pub fn get_countries() -> List(#(String, String, String)) {
  [
    #("united states", "washington, dc", "🇺🇸"),
    #("canada", "ottawa", "🇨🇦"),
    #("mexico", "mexico city", "🇲🇽"),
  ]
  |> list.shuffle()
}
