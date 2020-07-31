local Hash = game:HttpGet("http://setup.roblox.com/versionQTStudio")
local APIDump = game:HttpGet("http://setup.roblox.com/"..Hash.."-API-Dump.json")
APIDump = game:GetService("HttpService"):JSONDecode(APIDump)

local MemberCache = {}
function GetMembers(Class)
    if MemberCache[Class] then
        return MemberCache[Class]
    end

	local Members = {}
	local Entries = {}

	local Entry = FetchClassEntry(Class)
	while Entry and Entry.Superclass ~= "<<<ROOT>>>" do
		table.insert(Entries, 1, Entry)
		Entry = FetchClassEntry(Entry.Superclass)
    end
    
	if not Entry then
		error(Class.." doesn't exist.")
	end
	table.insert(Entries, 1, Entry)
	
	for _, Entry in pairs(Entries) do
		for _, Member in pairs(Entry.Members) do
			Members[#Members + 1] = Member
		end
	end
	
	MemberCache[Class] = Members
	return Members
end

local ClassCache = {}
function FetchClassEntry(Class)
    if ClassCache[Class] then
        return ClassCache[Class]
    end

	for _, Entry in pairs(APIDump.Classes) do
		if Entry.Name == Class then
			ClassCache[Class] = Entry
			return Entry
		end
    end
    
    error(Class.." doesn't exist.")
    return false
end

function GetClassProperties(Class)
	local Members = GetMembers(Class)
    local DontConvert = false
    
	local Properties = {}
	for _, Member in pairs(Members) do
		if Member.MemberType == "Property" then
			if Member.Tags then
				for _, Tag in pairs(Member.Tags) do
                    if Tag.ReadOnly or Tag.Deprecated or Tag.Hidden then
                        DontConvert = true
                        break
                    end
				end
            end
            
			if not DontConvert then
				Properties[#Properties + 1] = Member.Name
			end
		end
	end
	
	return Properties
end

return {
    GetClassProperties = GetClassProperties,
    FetchClassEntry = FetchClassEntry,
    GetMembers = GetMembers
}
