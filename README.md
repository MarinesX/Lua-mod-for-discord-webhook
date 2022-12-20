## Lua Module for Discord webhook via Powershell ##


#### Documentation ####
```lua
-- Require module
webhookMod = require "webhookMod"
discord = webhookMod

discord.setURL("str") -- Initiate standart URL webhooks
discord.setAvatar("str") -- Initiate standart avatar

local embed = discord.createEmbed(<tableEmbed>) -- Initiate and assign return <tableEmbed> to embed
<tableEmbed>{
    title = "str",
    description = "str",
    color = int,
    timestamp = discord.timestamp(int) -- Initiate and assign return value from discord timestamp

    -- Assosiated Method for embed
    embed.setImage("link") -- Initiate image link
    embed.setThumbnail("link") -- Initiate thumbnail link
    embed.setFooter(<tableFooter>) -- Initiate data for footer
    embed.setAuthor(<tableAuthor>) -- Initiate data for Author
    embed.addFields(<tableFields>) -- Initiate data for fields

    <tableFooter>{
        text = "str",
        icon_url = "str"
    }

    <tableAuthor>{
        name = "str",
        icon_url = "link",
        url = "link"
    }

    <tableFields>{
        {name = "str1", value = "str1", inline = true},
        {name = "str2", value = "str2", inline = false}
    }
}

local payload = discord.createBody(<tableBody>) -- Initiate and assign return <tableBody> to payload
<tableBody>{
    username = "str",
    content = "str",
    embed = embed
}

discord.send([url][, payload][, method<bool>]) -- eExample discord.send("webhookURL/messages_id", payload, true)
    -- method = true => send method Patch
    or
discord.send("messages") -- Or sent via standard discord webhook link
```

#### TODO ####
- add compatible for file attachment