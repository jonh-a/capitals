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
import lustre/ui/layout/aside

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

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Validate -> validate_country(model)
    UserUpdatedGuess(value) -> Model(..model, current_guess: value)
  }
}

// VIEW ------------------------------------------------------------------------

pub fn view(model: Model) -> Element(Msg) {
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]
  let score = model.correct |> list.length() |> int.to_string()

  let content = case model.game_over {
    False ->
      ui.centre(
        [attribute.style(styles)],
        ui.aside(
          [aside.content_first(), aside.align_centre()],
          ui.field(
            [],
            [element.text(current_country(model.countries_remaining).0)],
            ui.input([
              attribute.value(model.current_guess),
              event.on_input(UserUpdatedGuess),
            ]),
            [],
          ),
          ui.button([event.on_click(Validate)], [element.text("Guess")]),
        ),
      )
    True ->
      ui.centre(
        [attribute.style(styles)],
        html.div([], [
          html.h1([], [element.text("game over!")]),
          html.h2([], [element.text("score: " <> score)]),
        ]),
      )
  }
  // ui.centre([attribute.style(styles)], content)
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
