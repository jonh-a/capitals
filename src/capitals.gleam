import data.{get_countries}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui
import lustre/ui/layout/aside

// MODEL -----------------------------------------------------------------------

pub type Model {
  Model(
    score: Int,
    correct: List(#(String, String)),
    incorrect: List(#(String, String)),
    current_country: #(String, String),
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
    current_country: #("", ""),
    current_guess: "",
    countries_remaining: get_countries(),
    game_over: False,
  )
}

// UPDATE ----------------------------------------------------------------------

pub type Msg {
  Validate
  UserUpdatedGuess(value: String)
}

fn next_country(
  countries_remaining: List(#(String, String)),
) -> #(String, String) {
  let next =
    countries_remaining
    |> list.first()

  case next {
    Ok(next) -> next
    Error(_) -> #("", "")
  }
}

fn validate_country(model: Model) -> Model {
  let capital_guess = model.current_guess |> string.lowercase()
  let guess_was_correct = capital_guess == model.current_country.1
  let next_country = next_country(model.countries_remaining)
  let is_game_over = next_country == #("", "")

  let updated_model =
    Model(
      ..model,
      current_country: next_country,
      current_guess: "",
      game_over: is_game_over,
    )

  case guess_was_correct, is_game_over {
    True, True ->
      Model(
        ..updated_model,
        score: model.score + 1,
        correct: list.append(model.correct, [model.current_country]),
        countries_remaining: [],
      )
    False, True ->
      Model(
        ..updated_model,
        incorrect: list.append(model.incorrect, [model.current_country]),
        countries_remaining: [],
        game_over: True,
      )
    True, False ->
      Model(
        ..updated_model,
        score: model.score + 1,
        correct: list.append(model.correct, [model.current_country]),
        countries_remaining: model.countries_remaining
          |> list.drop(1),
      )
    False, False ->
      Model(
        ..updated_model,
        incorrect: list.append(model.incorrect, [model.current_country]),
        countries_remaining: model.countries_remaining
          |> list.drop(1),
      )
  }
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Validate -> validate_country(model)
    UserUpdatedGuess(value) -> Model(..model, current_guess: value)
  }
}

// VIEW ------------------------------------------------------------------------

pub fn view(model: Model) -> element.Element(Msg) {
  let score = int.to_string(model.score)
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]

  let content = case model.game_over {
    False ->
      element.fragment([
        ui.field(
          [],
          [element.text("Country: " <> model.current_country.0)],
          ui.input([
            attribute.value(model.current_guess),
            event.on_input(UserUpdatedGuess),
          ]),
          [],
        ),
        ui.button([event.on_click(Validate)], [element.text("Submit")]),
        element.text("Score: " <> score),
        // element.text("Correct: " <> string.join(model.correct, ", ")),
      // element.text("Incorrect: " <> string.join(model.incorrect, ", ")),
      ])
    True ->
      element.fragment([
        element.text(
          "Game over! Score: "
          <> model.correct |> list.length() |> int.to_string(),
        ),
      ])
  }

  ui.centre([attribute.style(styles)], content)
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
