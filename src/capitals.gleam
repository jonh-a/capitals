import data.{get_countries}
import gleam/int
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui

// MODEL -----------------------------------------------------------------------

pub type Model {
  Model(
    score: Int,
    correct: List(#(String, String)),
    incorrect: List(#(String, String)),
    current_guess: String,
    countries_remaining: List(#(String, String)),
    game_over: Bool,
  )
}

fn init(_flags) -> Model {
  Model(
    score: 0,
    correct: [],
    incorrect: [],
    current_guess: "",
    countries_remaining: get_countries(),
    game_over: False,
  )
}

// UPDATE ----------------------------------------------------------------------

pub type Msg {
  Validate
  UserUpdatedGuess(value: String)
  UserKeyPress(key: String)
}

fn current_country(
  countries_remaining: List(#(String, String)),
) -> #(String, String) {
  let this =
    countries_remaining
    |> list.first()

  case this {
    Ok(this) -> this
    Error(_) -> #("", "")
  }
}

fn has_next_country(countries_remaining: List(#(String, String))) -> Bool {
  let next =
    countries_remaining
    |> list.drop(1)
    |> list.first()

  case next {
    Ok(_) -> True
    Error(_) -> False
  }
}

fn validate_country(model: Model) -> Model {
  let capital_guess = model.current_guess |> string.lowercase()
  let current_country = current_country(model.countries_remaining)
  let guess_was_correct = capital_guess == current_country.1
  let is_game_over = has_next_country(model.countries_remaining) == False

  let updated_model = Model(..model, current_guess: "", game_over: is_game_over)

  case guess_was_correct, is_game_over {
    True, True ->
      Model(
        ..updated_model,
        score: model.score + 1,
        correct: list.append(model.correct, [current_country]),
        countries_remaining: [],
      )
    False, True ->
      Model(
        ..updated_model,
        incorrect: list.append(model.incorrect, [current_country]),
        countries_remaining: [],
        game_over: True,
      )
    True, False ->
      Model(
        ..updated_model,
        score: model.score + 1,
        correct: list.append(model.correct, [current_country]),
        countries_remaining: model.countries_remaining
          |> list.drop(1),
      )
    False, False ->
      Model(
        ..updated_model,
        incorrect: list.append(model.incorrect, [current_country]),
        countries_remaining: model.countries_remaining
          |> list.drop(1),
      )
  }
}

fn handle_key_press(key: String, model: Model) -> Model {
  case key, model.current_guess |> string.length {
    _, 0 -> model
    "Enter", _ -> validate_country(model)
    _, _ -> model
  }
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Validate -> validate_country(model)
    UserUpdatedGuess(value) ->
      Model(..model, current_guess: value |> string.lowercase())
    UserKeyPress(key) -> handle_key_press(key, model)
  }
}

// VIEW ------------------------------------------------------------------------

pub fn view(model: Model) -> Element(Msg) {
  let main_styles = [
    #("width", "100vw"),
    #("height", "100vh"),
    #("padding", "1rem"),
  ]
  let score = model.correct |> list.length() |> int.to_string()

  case model.game_over {
    False -> ui.centre([attribute.style(main_styles)], quiz_input(model))
    True ->
      ui.centre(
        [attribute.style(main_styles)],
        html.div([], [
          html.h1([], [element.text("game over! score: " <> score)]),
          ..missed_table(model)
        ]),
      )
  }
}

fn quiz_input(model: Model) -> Element(Msg) {
  let button_style = [#("width", "100%"), #("margin-top", "1em")]

  html.div([], [
    ui.field(
      [],
      [element.text(current_country(model.countries_remaining).0)],
      ui.input([
        attribute.value(model.current_guess),
        event.on_input(UserUpdatedGuess),
        event.on_keypress(UserKeyPress),
      ]),
      [],
    ),
    ui.button([event.on_click(Validate), attribute.style(button_style)], [
      element.text("Guess"),
    ]),
  ])
}

fn missed_table(model: Model) -> List(Element(Msg)) {
  case list.length(model.incorrect) {
    0 -> [html.h1([], [element.text("you didn't miss any!")])]
    _ -> [
      html.h1([], [element.text("you got these wrong: ")]),
      html.table(
        [],
        model.incorrect
          |> list.map(fn(country: #(String, String)) {
            html.tr([], [
              html.td([], [element.text(country.0)]),
              html.td([], [element.text(country.1)]),
            ])
          }),
      ),
    ]
  }
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
