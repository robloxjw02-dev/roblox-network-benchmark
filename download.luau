local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")

local AUTH_TOKEN: string?
local PATH_TO_7ZIP = "C:\\Program Files\\7-Zip\\7z.exe"
local PATH_TO_TOOLS = "./tools/"
local PATH_TO_PACKAGES = "./packages/"

type Tools = {
	[string]: string,
}

type Packages = {
	[string]: {
		GitHub: string,
		Wally: string?,
	},
}

local Tools = {
	speedy = "https://api.github.com/repos/robloxjw02-dev/speedy",
	blitz = "https://api.github.com/repos/robloxjw02-dev/blitz",
} :: Tools

local Packages = {
	packetize = {
		GitHub = "https://api.github.com/repos/robloxjw02-dev/Packetize",
	},
} :: Packages

local Versions: { [string]: string } = {}

if fs.isFile(".env") then
	local Configuration = {}
	for Line in string.gmatch(fs.readFile(".env"), "[^\r\n]+") do
		local Key, Value = Line:match("^([^=]+)=(.+)$")
		if Key and Value then
			Configuration[Key] = Value
		end
	end

	AUTH_TOKEN = Configuration["GITHUB_TOKEN"]
	print(`Using github token to do API requests!`)
elseif fs.isFile("config.json") then
    local Configuration = net.jsonDecode(fs.readFile("config.json"))
	AUTH_TOKEN = Configuration["github-token"]
	print(`Using github token to do API requests!`)
end

local function Curl(URL: string, Output: string?, Headers: { string }?): process.SpawnResult
	local Arguments = {}

	if AUTH_TOKEN then
		table.insert(Arguments, "--header")
		table.insert(Arguments, "Accept: application/vnd.github.v3.raw")
		table.insert(Arguments, "--header")
		table.insert(Arguments, `Authorization: token {AUTH_TOKEN}`)
	end

	if Headers then
		for _, Header in Headers do
			table.insert(Arguments, "--header")
			table.insert(Arguments, Header)
		end
	end

	table.insert(Arguments, "--location")
	table.insert(Arguments, URL)

	if Output then
		table.insert(Arguments, "--output")
		table.insert(Arguments, Output)
	end

	return process.spawn(`curl`, Arguments)
end

local function Request(Fetch: net.FetchParams): net.FetchResponse
	if AUTH_TOKEN then
		Fetch.headers = Fetch.headers or {};
		(Fetch.headers :: any).Authorization = `Bearer {AUTH_TOKEN}`
	end

	local Response = net.request(Fetch)
	local Ratelimit = Response.headers["x-ratelimit-remaining"]

	if tonumber(Ratelimit) == 0 then
		error(`API rate limit exceeded, retry again in {Response.headers["x-ratelimit-reset"] - os.time()} seconds.`)
	end

	assert(Response.ok, Response.statusMessage)
	return Response
end

local function Download(Owner: string, RepoName: string, Tag: string, Pattern: string, Output: string)
	local Arguments: { string } = { "release", "download", Tag, "--pattern", Pattern, "--repo" }
	table.insert(Arguments, `{Owner}/{RepoName}`)
	table.insert(Arguments, "--output")
	table.insert(Arguments, Output)
	table.insert(Arguments, "--clobber")

	return process.spawn("gh", Arguments)
end

for Name, Url in Tools do
	local Response = Request({
		url = `{Url}/releases/latest`,
		method = "GET",
	})

	local Release = net.jsonDecode(Response.body)

	local RepoOwner = string.match(Url, "/repos/(.-)/.-")
	assert(RepoOwner, "Repository owner is not found")
	local DownloadResult = Download(RepoOwner, Name, Release.tag_name, "*-windows-x86_64.zip", `{PATH_TO_TOOLS}{Name}.zip`)
	assert(DownloadResult.ok, `Encountered an exception while downloading files for {Name}, {DownloadResult.stderr}`)
	local UnzipResult = process.spawn(`{PATH_TO_7ZIP}`, { "e", `{PATH_TO_TOOLS}{Name}.zip`, "-y", `-o{PATH_TO_TOOLS}` })
	assert(UnzipResult.ok, `Encountered an exception while unzipping downloads for {Name}, {UnzipResult.stderr}`)

	Versions[Name] = Release.tag_name
	print("Downloaded", Name, Release.tag_name)
end

for Name, Urls in Packages do
	local Response = Request({
		url = `{Urls.GitHub}/releases`,
		method = "GET",
	})

	local Releases = net.jsonDecode(Response.body)
	table.sort(Releases, function(a, b)
		return a.id > b.id
	end)

	local Release = Releases[1]
	local Version = Release.tag_name

	local ZipPath = `{PATH_TO_PACKAGES}{Name}_ZIP`
	local FinalPath = `{PATH_TO_PACKAGES}{Name}`
	if not Urls.Wally then
		local Status = Request({
			url = Urls.GitHub,
			method = "GET",
		})

		local Data = net.jsonDecode(Status.body)
		local IsPrivate = Data.visibility == "private" and true or false

		if not IsPrivate then
			local Assets = Release.assets
			local Asset = Assets[1]
			local AssetDownloadUrl = Asset["browser_download_url"]
			local CurlResult = Curl(AssetDownloadUrl, `{ZipPath}.zip`)
			assert(CurlResult.ok, `Encountered an exception while downloading files for {Name}, {CurlResult.stderr}`)

			local UnzipResult = process.spawn(`{PATH_TO_7ZIP}`, { "x", `{ZipPath}.zip`, "-y", `-o{ZipPath}` })
			assert(
				UnzipResult.ok,
				`Encountered an exception while unzipping downloads for {Name}, {UnzipResult.stderr}`
			)
		else
			local RepoOwner = string.match(Urls.GitHub, "/repos/(.-)/.-")
			assert(RepoOwner, "Repository owner is not found")
			local DownloadResult = Download(RepoOwner, Name, Release.tag_name, "*.zip", `{ZipPath}.zip`)
			assert(
				DownloadResult.ok,
				`Encountered an exception while downloading files for {Name}, {DownloadResult.stderr}`
			)
		end
		local UnzipResult = process.spawn(`{PATH_TO_7ZIP}`, { "x", `{ZipPath}.zip`, "-y", `-o{ZipPath}` })
		assert(
			UnzipResult.ok,
			`Encountered an exception while unzipping downloads for {Name}, {UnzipResult.stderr}`
		)
		local FullDirectories = fs.readDir(ZipPath)
		local Directory = FullDirectories[1]

		if fs.isDir(FinalPath) then
			fs.removeDir(FinalPath)
		end

		fs.move(`{ZipPath}/{Directory}`, FinalPath)
		fs.removeDir(ZipPath)
	else
		local PackageVersion = Version

		if string.sub(Version, 1, 1) == "v" then
			PackageVersion = string.sub(Version, 2)
		end

		local DownloadUrl = `{Urls.Wally}{PackageVersion}`
		local CurlResult = Curl(DownloadUrl, `{ZipPath}.zip`, { "Wally-Version: 0.3.2" })
		assert(CurlResult.ok, `Encountered an exception while downloading files for {Name}, {CurlResult.stderr}`)

		if not fs.isDir(ZipPath) then
			fs.writeDir(ZipPath)
		end

		local UnzipResult = process.spawn(`{PATH_TO_7ZIP}`, { "x", `{ZipPath}.zip`, "-y", `-o{ZipPath}` })
		assert(UnzipResult.ok, `Encountered an exception while unzipping downloads for {Name}, {UnzipResult.stderr}`)

		if fs.isDir(FinalPath) then
			fs.removeDir(FinalPath)
		end

		fs.move(`{ZipPath}/src`, FinalPath)
		fs.removeDir(ZipPath)
		-- fs.removeFile(`{ZipPath}.zip`)
	end

	Versions[Name] = Version
	print("Downloaded", Name, Version)
end

fs.writeFile("./tools/versions.json", net.jsonEncode(Versions))
