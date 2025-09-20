-- Change this to your Termux server's IP address!
local API = "http://192.168.1.35:3000/"; -- <<< FIXED: Added http:// and :3000/

local Decompile = function(Script)
    local ScriptBytecode = getscriptbytecode(Script);

    if ScriptBytecode then
        local Output = request({
            Url = API .. "decompile", -- Now this becomes: http://192.168.1.35:3000/decompile
            Method = "POST",
            Body = ScriptBytecode,
            Headers = {
                ["Content-Type"] = "text/plain"
            }
        });
      
        if Output.StatusCode == 200 then
            return Output.Body;
        end;

        return "Failed to decompile. Status: " .. Output.StatusCode;
    end;
    return "Failed to get bytecode.";
end;

getgenv().decompile = Decompile;