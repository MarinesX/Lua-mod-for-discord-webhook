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

    local embed = data or {} -- Embed table: title, description, color, timestamp

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
    data = data or {}   -- Body table: username, content, embed, [file]
    return data
end

-- Send the webhook
function discordWebhook.send(...)
    local webhookURL, Body, method

    if select('#', ...) == 1 then

        -- If the only argument is type 'table', it must be Body table!
        if type(select(1, ...)) == "table" then
            Body = select(1, ...)
        else

            -- Else, the type is 'string' as messages inside content
            Body = {
                content = select(1, ...)
            }
        end
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
        local author = ""
        local footer = ""

        if Body.embed.fields then
            for index, values in ipairs(Body.embed.fields) do
                fieldArray = fieldArray..[[@{name = ']]..values.name..[['; value = ']]..values.value..[[';inline = ']]..tostring(values.inline)..[['};]]
            end
        end

        if Body.embed.author then
            for key, value in pairs(Body.embed.author) do
                author = author..[[
                    
                ]]..key.." = '"..value..[['
                ]]
            end
        end

        if Body.embed.thumbnail then
            thumbnail = [[
                
            url = ']]..Body.embed.thumbnail.url .. [['
            ]]
        end

        if Body.embed.footer then
            for key, value in pairs(Body.embed.footer) do
                footer = footer..[[
    
                ]]..key..[[ = ']]..value..[['
                ]]
            end
        end

        if Body.embed.color then 
            script = script..[[
            $color = "]].. Body.embed.color ..[["
            ]]
        end

        if Body.embed.title then 
            script = script..[[
            $title = "]]..Body.embed.title..[["
            ]]
        end

        if Body.embed.description then 
            script = script..[[
            $description = "]]..Body.embed.description..[[" 
            ]]
        end

        if Body.embed.timestamp then 
            script = script..[[
            $timestamp = ']].. Body.embed.timestamp ..[['
            ]]
        end

        script = script..[[ 
            $author = @{]].. author ..[[}
            
            $thumbnail = @{]].. thumbnail ..[[}
            
            $footer = @{]]..footer..[[}
            
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
            
        $embedArray = New-Object System.Collections.Generic.List[Object]
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

    local file = io.open("log.ps1", "w")
    file:write(script)
    file:close()

    local pipe = io.popen("powershell -command -", "w")
    pipe:write(script)
    pipe:close()
end

-- Return the module
return discordWebhook
-- Credit for NightHawk for the inspiration