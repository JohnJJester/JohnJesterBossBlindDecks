--- STEAMODDED HEADER
--- MOD_NAME: Boss Blind Decks
--- MOD_ID: JJBBD
--- MOD_AUTHOR: [Johnathan J. Jester]
--- MOD_DESCRIPTION: Adds 5 Challenging decks based on the final boss blinds!
--- PREFIX: jjbbd
----------------------------------------------------------
----------- MOD CODE -----------------------------------S
if not JJBBD then
	JJBBD = {}
end

local mod_path = "" .. SMODS.current_mod.path
JJBBD.path = mod_path
JJBBD.config = SMODS.current_mod.config

local files = NFS.getDirectoryItems(mod_path .. "items")
for _, file in ipairs(files) do
	print("[JJChallengePack] Loading lua file " .. file)
	local f, err = SMODS.load_file("items/" .. file)
	if err then
		error(err) 
	end
	f()
end

SMODS.Atlas{
	key = "icon",
	path ="icon.png",
	px = 31,
	py = 31
}
------------ MOD CODE END -------------------------------------
