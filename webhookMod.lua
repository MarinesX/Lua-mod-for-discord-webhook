-- Define the discordWebhook module
local discordWebhook = {}

-- Set the URL and avatar
local url = ""
local avatar = "https://img.freepik.com/free-vector/capybara-love-logo_7688-559.jpg"

function discordWebhook.setURL(value)
    url = value
end

function discordWebhook.setAvatar(value)
    avatar = value
end

-- Create an embed object
function discordWebhook.createEmbed(data)

    local embed = data or {} -- title, description, color, timestamp

    function embed.setImage(value)
        data.image = { url = value }
    end

    function embed.setThumbnail(value)
        data.thumbnail = { url = value }
    end

    function embed.setFooter(value)
        data.footer = value
    end

    function embed.setAuthor(value)
        data.author = value
    end

    function embed.addFields(...)
        data.fields = { ... }
    end

    return embed
end

-- Create a timestamp
function discordWebhook.timestamp(value)
    return os.date("!%Y-%m-%dT%H:%M:%S", value)
end

-- Add a new function to the discordWebhook module
function discordWebhook.file(value)
    -- Read the contents of the file as a byte array
    local file = io.open(value, "rb")
    local contents = file:read("*all")
    file:close()
    -- Return the file contents
    return contents
end

-- Create the Body
function discordWebhook.createBody(data)
    data = data or {}   -- username, content, embed
    return data
end

-- Send the webhook
function discordWebhook.send(...)
    local webhookURL, Body, method

    if select('#', ...) == 1 then
        -- If only one argument is provided, treat it as the webhookURL  
        Body = {
            content = select(1, ...)
        }
    else
        -- Otherwise, unpack the arguments as normal
        webhookURL, Body, method = table.unpack{...}
    end

    local webhookURL = webhookURL or url
    local avatar_url = Body.avatar_url or avatar
    local method = method or false

    local script =  [[$webHookUrl = "]]..webhookURL..[["
    ]]

    -- if Body.file then
    --     script = script.. [[
    --     $filePath = "]]..Body.file..[["
    --     $fileContent = Get-Content -Path $filePath -Encoding Byte
    -- ]]
    -- end

    if Body.embed then
        local fieldArray = ""

        if Body.embed.fields then
            for index, values in ipairs(Body.embed.fields) do
                fieldArray = fieldArray..[[@{name = ']]..values.name..[['; value = ']]..values.value..[[';inline = ']]..tostring(values.inline)..[['};]]
            end
        end

        script = script..[[ 
        $embedArray = New-Object System.Collections.Generic.List[Object]

        $color = "]]..Body.embed.color..[["

        $title = "**]]..Body.embed.title..[[**"

        $description = "**]]..Body.embed.description..[[**"

        $timestamp = "]]..Body.embed.timestamp..[["

        $author = @{
            name = "]].. Body.embed.author.name ..[["
            icon_url = "]].. Body.embed.author.icon_url ..[["
            url = "]].. Body.embed.author.url ..[["
        }

        $thumbnail = @{
            url = "]].. Body.embed.thumbnail.url ..[["
        }

        $footer = @{
            text = "]].. Body.embed.footer.text ..[["
            icon_url = "]].. Body.embed.footer.icon_url ..[["
        }

        $fieldArray = @(]].. fieldArray ..[[)

        $embedObject = @{
            color = $color
            title = $title
            description = $description
            timestamp = $timestamp
            author = $author
            thumbnail = $thumbnail
            footer = $footer
            fields = $fieldArray
        }

        $embedArray.Add($embedObject)

        ]]
    end

    script = script..[[
$payload = @{ 
    ]]

    if Body.username then
        script = script..[[
        username = "]].. Body.username ..[["
        ]]
    end

    if avatar_url then
        script = script..[[
    avatar_url = "]].. avatar_url ..[["
        ]]
    end

    if Body.content then
        script = script..[[
    content = "]]..Body.content..[["     
        ]]
    end

    -- if Body.file then
    --     script = script..[[
    --     file_name = "]]..Body.file_name..[["
    --         file_type = "]]..Body.file_type..[["
    --         file_contents = ']].. Body.file ..[['
    --     ]]
    -- end

    if Body.embed then
        script = script..[[
    embeds = $embedArray
        ]]
    end

    script = script.."}\n"

    if method then
        script = script.."\n"..[[
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Patch -ContentType 'application/json'              
        ]]
    else
        script = script.."\n"..[[
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'      
        ]]
    end

    -- local file = io.open("log.ps1", "w")
    -- file:write(script)
    -- file:close()

    local pipe = io.popen("powershell -command -", "w")
    pipe:write(script)
    pipe:close()
end

-- Return the module
return discordWebhook
-- Credit for NightHawk for the inspiration