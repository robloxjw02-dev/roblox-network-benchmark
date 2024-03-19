local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")
local process = require("@lune/process")

require('dotenv').config()

local AUTH_TOKEN: string? = nil
local PATH_TO_7ZIP = "C:\\Program Files\\7-Zip\\7z.exe"
local PATH_TO_TOOLS = "./tools/"
local PATH_TO_PACKAGES = "./packages/"

type Versions  = { [string]: string }

type Tools = { [string]: string }

type Packages = {
	[string]: {
		github: string,
		wally: string?,
	},
}

local tools = {
	speedy = "https://api.github.com/repos/robloxjw02-dev/speedy",
	blitz = "https://api.github.com/repos/robloxjw02-dev/blitz",
} :: Tools

local packages = {
	packetize = {
		github = "https://api.github.com/repos/robloxjw02-dev/Packetize",
	},
} :: Packages

local versions: Versions = {}

local function fetchAuthenticationToken()
	local authenticationToken: string?
	if process.env['GITHUB_TOKEN'] then
		authenticationToken = process.env['GITHUB_TOKEN']
	elseif fs.isFile("config.json") then
		local configuration = serde.decode("json", fs.readFile("config.json"))
		authenticationToken = configuration["github-token"]
	end

	if authenticationToken then
		print(`Using github token to do API requests!`)
	end

	return authenticationToken
end

local function curl(URL: string, Output: string?, Headers: { string }?): process.SpawnResult
	local arguments: { string } = {}

	if AUTH_TOKEN then
		table.insert(arguments, "--header")
		table.insert(arguments, "Accept: application/vnd.github.v3.raw")
		table.insert(arguments, "--header")
		table.insert(arguments, `Authorization: token {AUTH_TOKEN}`)
	end

	if Headers then
		for _, Header in Headers do
			table.insert(arguments, "--header")
			table.insert(arguments, Header)
		end
	end

	table.insert(arguments, "--location")
	table.insert(arguments, URL)

	if Output then
		table.insert(arguments, "--output")
		table.insert(arguments, Output)
	end

	return process.spawn(`curl`, arguments)
end

local function download(owner: string, repository: string, tag: string, pattern: string, output: string)
	local arguments: { string } = { "release", "download", tag, "--pattern", pattern, "--repo" }
	table.insert(arguments, `{owner}/{repository}`)
	table.insert(arguments, "--output")
	table.insert(arguments, output)
	table.insert(arguments, "--clobber")

	return process.spawn("gh", arguments)
end

local function request(fetch: net.FetchParams): net.FetchResponse
	if AUTH_TOKEN then
		fetch.headers = fetch.headers or {};
		(fetch.headers :: any).Authorization = `Bearer {AUTH_TOKEN}`
	end

	local response = net.request(fetch)
	local ratelimit = response.headers["x-ratelimit-remaining"]

	if tonumber(ratelimit) == 0 then
		error(`API rate limit exceeded, retry again in {response.headers["x-ratelimit-reset"] - os.time()} seconds.`)
	end

	assert(response.ok, response.statusMessage)
	return response
end

AUTH_TOKEN = fetchAuthenticationToken()

for toolName, url in tools do
	local response = request({
		url = `{url}/releases/latest`,
		method = "GET",
	})

	local release = net.jsonDecode(response.body)

	local repoOwner = string.match(url, "/repos/(.-)/.-")
	assert(repoOwner, "Repository owner is not found")
	local downloadResult = download(repoOwner, toolName, release.tag_name, "*-windows-x86_64.zip", `{PATH_TO_TOOLS}{toolName}.zip`)
	assert(downloadResult.ok, `Encountered an exception while downloading files for {toolName}, {downloadResult.stderr}`)
	local unzipResult = process.spawn(`{PATH_TO_7ZIP}`, { "e", `{PATH_TO_TOOLS}{toolName}.zip`, "-y", `-o{PATH_TO_TOOLS}` })
	assert(unzipResult.ok, `Encountered an exception while unzipping downloads for {toolName}, {unzipResult.stderr}`)

	versions[toolName] = release.tag_name
	print("Downloaded", toolName, release.tag_name)
end

for packageName, urls in packages do
	local ZIP_PATH = `{PATH_TO_PACKAGES}{packageName}_ZIP`
	local FINAL_PATH = `{PATH_TO_PACKAGES}{packageName}`
	local response = request({
		url = `{urls.github}/releases`,
		method = "GET",
	})

	local releases = serde.decode("json", response.body)
	table.sort(releases, function(a, b)
		return a.id > b.id
	end)

	local release = releases[1]
	local releaseVersion = release.tag_name
	if not urls.wally then
		local status = request({
			url = urls.github,
			method = "GET",
		})

		local data = serde.decode("json", status.body)
		local isPrivate = data.visibility == "private"

		if not isPrivate then
			local assets = release.assets
			local asset = assets[1]
			local assetDownloadUrl = asset["browser_download_url"]
			local curlResult = curl(assetDownloadUrl, `{ZIP_PATH}.zip`)
			assert(curlResult.ok, `Encountered an exception while downloading files for {packageName}, {curlResult.stderr}`)
		else
			local repoOwner = string.match(urls.github, "/repos/(.-)/.-")
			assert(repoOwner, "Repository owner is not found")
			local downloadResult = download(repoOwner, packageName, release.tag_name, "*.zip", `{ZIP_PATH}.zip`)
			assert(
				downloadResult.ok,
				`Encountered an exception while downloading files for {packageName}, {downloadResult.stderr}`
			)
		end
		local unzipResult = process.spawn(`{PATH_TO_7ZIP}`, { "x", `{ZIP_PATH}.zip`, "-y", `-o{ZIP_PATH}` })
		assert(
			unzipResult.ok,
			`Encountered an exception while unzipping downloads for {packageName}, {unzipResult.stderr}`
		)
		local directories = fs.readDir(ZIP_PATH)
		local directory = directories[1]

		if fs.isDir(FINAL_PATH) then
			fs.removeDir(FINAL_PATH)
		end

		fs.move(`{ZIP_PATH}/{directory}`, FINAL_PATH)
		fs.removeDir(ZIP_PATH)
	else
		local packageVersion = releaseVersion 

		if string.sub(releaseVersion, 1, 1) == "v" then
			packageVersion = string.sub(releaseVersion, 2)
		end

		local downloadUrl = `{urls.wally}{packageVersion}`
		local curlResult = curl(downloadUrl, `{ZIP_PATH}.zip`, { "Wally-Version: 0.3.2" })
		assert(curlResult.ok, `Encountered an exception while downloading files for {packageName}, {curlResult.stderr}`)

		if not fs.isDir(ZIP_PATH) then
			fs.writeDir(ZIP_PATH)
		end

		local unzipResult = process.spawn(`{PATH_TO_7ZIP}`, { "x", `{ZIP_PATH}.zip`, "-y", `-o{ZIP_PATH}` })
		assert(unzipResult.ok, `Encountered an exception while unzipping downloads for {packageName}, {unzipResult.stderr}`)

		if fs.isDir(FINAL_PATH) then
			fs.removeDir(FINAL_PATH)
		end

		fs.move(`{ZIP_PATH}/src`, FINAL_PATH)
		fs.removeDir(ZIP_PATH)
	end

	versions[packageName] = releaseVersion
	print("Downloaded", packageName, releaseVersion)
end

fs.writeFile("./tools/versions.json", serde.encode("json", versions))
