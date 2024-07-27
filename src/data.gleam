import gleam/list

pub fn get_countries(
  continents: List(String),
) -> List(#(String, String, String)) {
  continents
  |> list.map(fn(c: String) -> List(#(String, String, String)) {
    case c {
      "americas" -> americas
      "europe" -> europe
      "asia" -> asia
      "africa" -> africa
      "oceania" -> oceania
      _ -> []
    }
  })
  |> list.flatten()
  |> list.shuffle()
  |> list.take(15)
}

const americas = [
  #("argentina", "buenos aires", "🇦🇷"), #("bolivia", "sucre", "🇧🇴"),
  #("brazil", "brasília", "🇧🇷"), #("canada", "ottawa", "🇨🇦"),
  #("chile", "santiago", "🇨🇱"), #("colombia", "bogota", "🇨🇴"),
  #("costa rica", "san jose", "🇨🇷"), #("cuba", "havana", "🇨🇺"),
  #("dominican republic", "santo domingo", "🇩🇴"),
  #("ecuador", "quito", "🇪🇨"),
  #("el salvador", "san salvador", "🇸🇻"),
  #("guatemala", "guatemala city", "🇬🇹"),
  #("haiti", "port-au-prince", "🇭🇹"),
  #("honduras", "tegucigalpa", "🇭🇳"), #("jamaica", "kingston", "🇯🇲"),
  #("mexico", "mexico city", "🇲🇽"), #("nicaragua", "managua", "🇳🇮"),
  #("panama", "panama city", "🇵🇦"), #("paraguay", "asuncion", "🇵🇾"),
  #("peru", "lima", "🇵🇪"),
  #("trinidad and tobago", "port of spain", "🇹🇹"),
  #("united states", "washington, dc", "🇺🇸"),
  #("uruguay", "montevideo", "🇺🇾"), #("venezuela", "caracas", "🇻🇪"),
  #("belize", "belmopan", "🇧🇿"), #("bahamas", "nassau", "🇧🇸"),
  #("antigua and barbuda", "saint john's", "🇦🇬"),
  #("barbados", "bridgetown", "🇧🇧"),
  #("grenada", "saint george's", "🇬🇩"),
  #("guyana", "georgetown", "🇬🇾"),
  #("saint kitts and nevis", "basseterre", "🇰🇳"),
  #("saint lucia", "castries", "🇱🇨"),
  #("saint vincent and the grenadines", "kingstown", "🇻🇨"),
  #("suriname", "paramaribo", "🇸🇷"),
]

const europe = [
  #("austria", "vienna", "🇦🇹"), #("belarus", "minsk", "🇧🇾"),
  #("belgium", "brussels", "🇧🇪"),
  #("bosnia and herzegovina", "sarajevo", "🇧🇦"),
  #("bulgaria", "sofia", "🇧🇬"), #("croatia", "zagreb", "🇭🇷"),
  #("czech republic", "prague", "🇨🇿"),
  #("denmark", "copenhagen", "🇩🇰"), #("finland", "helsinki", "🇫🇮"),
  #("france", "paris", "🇫🇷"), #("germany", "berlin", "🇩🇪"),
  #("greece", "athens", "🇬🇷"), #("hungary", "budapest", "🇭🇺"),
  #("iceland", "reykjavik", "🇮🇸"), #("ireland", "dublin", "🇮🇪"),
  #("italy", "rome", "🇮🇹"), #("latvia", "riga", "🇱🇻"),
  #("lithuania", "vilnius", "🇱🇹"),
  #("luxembourg", "luxembourg", "🇱🇺"), #("malta", "valletta", "🇲🇹"),
  #("netherlands", "amsterdam", "🇳🇱"), #("norway", "oslo", "🇳🇴"),
  #("poland", "warsaw", "🇵🇱"), #("portugal", "lisbon", "🇵🇹"),
  #("romania", "bucharest", "🇷🇴"), #("russia", "moscow", "🇷🇺"),
  #("serbia", "belgrade", "🇷🇸"), #("slovakia", "bratislava", "🇸🇰"),
  #("slovenia", "ljubljana", "🇸🇮"), #("spain", "madrid", "🇪🇸"),
  #("sweden", "stockholm", "🇸🇪"), #("switzerland", "bern", "🇨🇭"),
  #("ukraine", "kyiv", "🇺🇦"), #("united kingdom", "london", "🇬🇧"),
  #("albania", "tirana", "🇦🇱"),
  #("andorra", "andorra la vella", "🇦🇩"),
  #("armenia", "yerevan", "🇦🇲"), #("azerbaijan", "baku", "🇦🇿"),
  #("cyprus", "nicosia", "🇨🇾"), #("estonia", "tallinn", "🇪🇪"),
  #("georgia", "tbilisi", "🇬🇪"), #("kosovo", "pristina", "🇽🇰"),
  #("liechtenstein", "vaduz", "🇱🇮"), #("moldova", "chisinau", "🇲🇩"),
  #("monaco", "monaco", "🇲🇨"), #("montenegro", "podgorica", "🇲🇪"),
  #("north macedonia", "skopje", "🇲🇰"),
  #("san marino", "san marino", "🇸🇲"),
  #("vatican city", "vatican city", "🇻🇦"),
]

const africa = [
  #("algeria", "algiers", "🇩🇿"), #("angola", "luanda", "🇦🇴"),
  #("benin", "porto-novo", "🇧🇯"), #("botswana", "gaborone", "🇧🇼"),
  #("burkina faso", "ouagadougou", "🇧🇫"),
  #("burundi", "gitega", "🇧🇮"), #("cabo verde", "praia", "🇨🇻"),
  #("cameroon", "yaoundé", "🇨🇲"),
  #("central african republic", "bangui", "🇨🇫"),
  #("chad", "n'djamena", "🇹🇩"), #("comoros", "moroni", "🇰🇲"),
  #("democratic republic of the congo", "kinshasa", "🇨🇩"),
  #("republic of the congo", "brazzaville", "🇨🇬"),
  #("djibouti", "djibouti", "🇩🇯"), #("egypt", "cairo", "🇪🇬"),
  #("equatorial guinea", "malabo", "🇬🇶"),
  #("eritrea", "asmara", "🇪🇷"), #("eswatini", "mbabane", "🇸🇿"),
  #("ethiopia", "addis ababa", "🇪🇹"), #("gabon", "libreville", "🇬🇦"),
  #("gambia", "banjul", "🇬🇲"), #("ghana", "accra", "🇬🇭"),
  #("guinea", "conakry", "🇬🇳"), #("guinea-bissau", "bissau", "🇬🇼"),
  #("ivory coast", "yamoussoukro", "🇨🇮"),
  #("kenya", "nairobi", "🇰🇪"), #("lesotho", "maseru", "🇱🇸"),
  #("liberia", "monrovia", "🇱🇷"), #("libya", "tripoli", "🇱🇾"),
  #("madagascar", "antananarivo", "🇲🇬"),
  #("malawi", "lilongwe", "🇲🇼"), #("mali", "bamako", "🇲🇱"),
  #("mauritania", "nouakchott", "🇲🇷"),
  #("mauritius", "port louis", "🇲🇺"), #("morocco", "rabat", "🇲🇦"),
  #("mozambique", "maputo", "🇲🇿"), #("namibia", "windhoek", "🇳🇦"),
  #("niger", "niamey", "🇳🇪"), #("nigeria", "abuja", "🇳🇬"),
  #("rwanda", "kigali", "🇷🇼"),
  #("sao tome and principe", "sao tome", "🇸🇹"),
  #("senegal", "dakar", "🇸🇳"), #("seychelles", "victoria", "🇸🇨"),
  #("sierra leone", "freetown", "🇸🇱"),
  #("somalia", "mogadishu", "🇸🇴"),
  #("south africa", "pretoria", "🇿🇦"),
  #("south sudan", "juba", "🇸🇸"), #("sudan", "khartoum", "🇸🇩"),
  #("tanzania", "dodoma", "🇹🇿"), #("togo", "lome", "🇹🇬"),
  #("tunisia", "tunis", "🇹🇳"), #("uganda", "kampala", "🇺🇬"),
  #("zambia", "lusaka", "🇿🇲"), #("zimbabwe", "harare", "🇿🇼"),
]

const asia = [
  #("afghanistan", "kabul", "🇦🇫"), #("bangladesh", "dhaka", "🇧🇩"),
  #("bhutan", "thimphu", "🇧🇹"),
  #("brunei", "bandar seri begawan", "🇧🇳"),
  #("cambodia", "phnom penh", "🇰🇭"), #("china", "beijing", "🇨🇳"),
  #("india", "new delhi", "🇮🇳"), #("indonesia", "jakarta", "🇮🇩"),
  #("iran", "tehran", "🇮🇷"), #("iraq", "baghdad", "🇮🇶"),
  #("japan", "tokyo", "🇯🇵"), #("jordan", "amman", "🇯🇴"),
  #("kazakhstan", "nur-sultan", "🇰🇿"),
  #("kuwait", "kuwait city", "🇰🇼"), #("kyrgyzstan", "bishkek", "🇰🇬"),
  #("laos", "vientiane", "🇱🇦"), #("lebanon", "beirut", "🇱🇧"),
  #("malaysia", "kuala lumpur", "🇲🇾"), #("maldives", "male", "🇲🇻"),
  #("mongolia", "ulaanbaatar", "🇲🇳"),
  #("myanmar", "naypyidaw", "🇲🇲"), #("nepal", "kathmandu", "🇳🇵"),
  #("north korea", "pyongyang", "🇰🇵"), #("oman", "muscat", "🇴🇲"),
  #("pakistan", "islamabad", "🇵🇰"), #("philippines", "manila", "🇵🇭"),
  #("qatar", "doha", "🇶🇦"), #("saudi arabia", "riyadh", "🇸🇦"),
  #("singapore", "singapore", "🇸🇬"), #("south korea", "seoul", "🇰🇷"),
  #("sri lanka", "kotte", "🇱🇰"), #("syria", "damascus", "🇸🇾"),
  #("taiwan", "taipei", "🇹🇼"), #("tajikistan", "dushanbe", "🇹🇯"),
  #("thailand", "bangkok", "🇹🇭"), #("turkey", "ankara", "🇹🇷"),
  #("turkmenistan", "ashgabat", "🇹🇲"),
  #("united arab emirates", "abu dhabi", "🇦🇪"),
  #("uzbekistan", "tashkent", "🇺🇿"), #("vietnam", "hanoi", "🇻🇳"),
  #("yemen", "sana'a", "🇾🇪"),
]

const oceania = [
  #("australia", "canberra", "🇦🇺"), #("fiji", "suva", "🇫🇯"),
  #("kiribati", "tarawa", "🇰🇮"),
  #("marshall islands", "majuro", "🇲🇭"),
  #("micronesia", "palikir", "🇫🇲"),
  #("nauru", "yaren district", "🇳🇷"),
  #("new zealand", "wellington", "🇳🇿"),
  #("palau", "ngerulmud", "🇵🇼"),
  #("papua new guinea", "port moresby", "🇵🇬"),
  #("samoa", "apia", "🇼🇸"), #("solomon islands", "honiara", "🇸🇧"),
  #("tonga", "nuku'alofa", "🇹🇴"), #("tuvalu", "funafuti", "🇹🇻"),
  #("vanuatu", "port vila", "🇻🇺"),
]
