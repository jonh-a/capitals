import gleam/list

pub fn get_countries() -> List(#(String, String)) {
  [#("United States", "washington, dc"), #("Canada", "ottawa")]
  |> list.shuffle()
}
