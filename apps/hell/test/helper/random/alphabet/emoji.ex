defmodule HELL.TestHelper.Random.Alphabet.Emoji do
  @moduledoc """
  Because why not?
  """

  # REVIEW: Make into a list with each emoji as an element of that list,
  #   otherwise each emoji is considered a "character" by it's own and thus
  #   ligatures become just a case of random accidents

  alias HELL.TestHelper.Random.Alphabet

  @characters "©®‼️⁉️™ℹ️↔️↕️↖️↗️↘️↙️↩️↪️⌚️⌛️⏩⏪⏫⏬⏰" <>
    "⏳Ⓜ️▪️▫️▶️◀️◻️◼️◽️◾️☀️☁️☎️☑️☔️☕️☝️☺️♈️♉️♊️♋️♌️♍️♎️♏" <>
    "️♐️♑️♒️♓️♠️♣️♥️♦️♨️♻️♿️⚓️⚠️⚡️⚪️⚫️⚽️⚾️⛄️⛅️⛎⛔️⛪" <>
    "️⛲️⛳️⛵️⛺️⛽️✂️✅✈️✉️✊✋✌️✏️✒️✔️✖️✨✳️✴️❄️❇️❌❎❓" <>
    "❔❕❗️❤️➕➖➗➡️➰➿⤴️⤵️⬅️⬆️⬇️⬛️⬜️⭐️⭕️〰〽️㊗️㊙️🀄️🃏" <>
    "🅰🅱🅾🅿️🆎🆑🆒🆓🆔🆕🆖🆗🆘🆙🆚🈁🈂🈚️🈯️🈲🈳🈴🈵🈶🈷🈸🈹🈺🉐🉑" <>
    "🌀🌁🌂🌃🌄🌅🌆🌇🌈🌉🌊🌋🌌🌍🌎🌏🌐🌑🌒🌓🌔🌕🌖🌗🌘🌙🌚🌛🌜🌝🌞" <>
    "🌟🌠🌰🌱🌲🌳🌴🌵🌷🌸🌹🌺🌻🌼🌽🌾🌿🍀🍁🍂🍃🍄🍅🍆🍇🍈🍉🍊🍋🍌🍍🍎" <>
    "🍏🍐🍑🍒🍓🍔🍕🍖🍗🍘🍙🍚🍛🍜🍝🍞🍟🍠🍡🍢🍣🍤🍥🍦🍧🍨🍩🍪🍫" <>
    "🍬🍭🍮🍯🍰🍱🍲🍳🍴🍵🍶🍷🍸🍹🍺🍻🍼🎀🎁🎂🎃🎄🎅🎆🎇🎈🎉🎊🎋" <>
    "🎌🎍🎎🎏🎐🎑🎒🎓🎠🎡🎢🎣🎤🎥🎦🎧🎨🎩🎪🎫🎬🎭🎮🎯🎰🎱🎲🎳🎴🎵" <>
    "🎶🎷🎸🎹🎺🎻🎼🎽🎾🎿🏀🏁🏂🏃🏄🏆🏇🏈🏉🏊🏠🏡🏢🏣🏤🏥🏦🏧🏨🏩🏪" <>
    "🏫🏬🏭🏮🏯🏰🐀🐁🐂🐃🐄🐅🐆🐇🐈🐉🐊🐋🐌🐍🐎🐏🐐🐑🐒🐓🐔🐕🐖🐗" <>
    "🐘🐙🐚🐛🐜🐝🐞🐟🐠🐡🐢🐣🐤🐥🐦🐧🐨🐩🐪🐫🐬🐭🐮🐯🐰🐱🐲🐳🐴🐵🐶🐷" <>
    "🐸🐹🐺🐻🐼🐽🐾👀👂👃👄👅👆👇👈👉👊👋👌👍👎👏👐👑👒👓👔👕👖👗👘👙👚" <>
    "👛👜👝👞👟👠👡👢👣👤👥👦👧👨👩👪👫👬👭👮👯👰👱👲👳👴👵👶👷👸👹👺👻" <>
    "👼👽👾👿💀💁💂💃💄💅💆💇💈💉💊💋💌💍💎💏💐💑💒💓💔💕💖💗💘💙💚💛💜💝" <>
    "💞💟💠💡💢💣💤💥💦💧💨💩💪💫💬💭💮💯💰💱💲💳💴💵💶💷💸💹💺💻" <>
    "💼💽💾💿📀📁📂📃📄📅📆📇📈📉📊📋📌📍📎📏📐📑📒📓📔📕📖📗📘📙📚📛" <>
    "📜📝📞📟📠📡📢📣📤📥📦📧📨📩📪📫📬📭📮📯📰📱📲📳📴📵📶📷📹📺📻📼🔀" <>
    "🔁🔂🔃🔄🔅🔆🔇🔈🔉🔊🔋🔌🔍🔎🔏🔐🔑🔒🔓🔔🔕🔖🔗🔘🔙🔚🔛🔜🔝🔞🔟🔠🔡" <>
    "🔢🔣🔤🔥🔦🔧🔨🔩🔪🔫🔬🔭🔮🔯🔰🔱🔲🔳🔴🔵🔶🔷🔸🔹🔺🔻🔼🔽🕐🕑🕒🕓🕔" <>
    "🕕🕖🕗🕘🕙🕚🕛🕜🕝🕞🕟🕠🕡🕢🕣🕤🕥🕦🕧🗻🗼🗽🗾🗿😀😁😂😃😄😅😆😇😈😉😊" <>
    "😋😌😍😎😏😐😑😒😓😔😕😖😗😘😙😚😛😜😝😞😟😠😡😢😣😤😥😦😧😨😩😪😫😬😭😮😯😰😱" <>
    "😲😳😴😵😶😷😸😹😺😻😼😽😾😿🙀🙅🙆🙇🙈🙉🙊🙋🙌🙍🙎🙏🚀🚁🚂🚃🚄🚅" <>
    "🚆🚇🚈🚉🚊🚋🚌🚍🚎🚏🚐🚑🚒🚓🚔🚕🚖🚗🚘🚙🚚🚛🚜🚝🚞🚟🚠🚡🚢🚣🚤🚥🚦" <>
    "🚧🚨🚩🚪🚫🚬🚭🚮🚯🚰🚱🚲🚳🚴🚵🚶🚷🚸🚹🚺🚻🚼🚽🚾🚿🛀🛁🛂🛃🛄🛅" <>
    "#️⃣0️⃣1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣🇨🇳🇩" <>
    "🇪🇪🇸🇫🇷🇬🇧🇮🇹🇯🇵🇰🇷🇷🇺🇺🇸"

  @alphabet Alphabet.build_alphabet(@characters)

  def alphabet,
    do: @alphabet
end