local vim = vim

local function expand_path(path)
	if string.sub(path, 1, 2) == "~/" then
		local home = vim.fn.expand("~")
		return home .. string.sub(path, 2)
	else
		return path
	end
end

local function read_file(path)
	local realpath = expand_path(path)
	local fd, err = io.open(realpath, "r")
	if not fd then
		return nil, "Cannot open file: " .. realpath .. " (" .. err .. ")"
	end
	local content = fd:read("*a")
	fd:close()
	return content, nil
end

local function parse_json(str)
	local ok, tbl = pcall(vim.fn.json_decode, str)
	if not ok then
		return nil, "Failed to parse JSON"
	end
	if type(tbl) ~= "table" then
		return nil, "JSON did not decode into a table"
	end
	return tbl, nil
end

local function authors_to_string(authors_tbl)
	if type(authors_tbl) ~= "table" then
		return ""
	end
	local names = {}
	for _, a in ipairs(authors_tbl) do
		local given = a.given or ""
		local family = a.family or ""
		given = given:gsub("^%s*(.-)%s*$", "%1")
		family = family:gsub("^%s*(.-)%s*$", "%1")
		if given ~= "" or family ~= "" then
			if given ~= "" and family ~= "" then
				table.insert(names, given .. " " .. family)
			else
				table.insert(names, given .. family)
			end
		end
	end
	return table.concat(names, ", ")
end

local generate_norg_files = function(force)
	local content, err = read_file("~/Notes/Brain2/papers/metadata/Library.json")
	if not content then
		vim.api.nvim_echo({ { "Error reading file: " .. err, "ErrorMsg" } }, true, { err = true })
		return
	end

	local tbl, err2 = parse_json(content)
	if not tbl then
		vim.api.nvim_echo({ { "Error parsing json: " .. err2, "ErrorMsg" } }, true, { err = true })
		return
	end

	for idx, rec in ipairs(tbl) do
		local citation_key = rec["citation-key"] or rec.citation_key or ""
		if citation_key == "" then
			vim.api.nvim_echo(
				{ { string.format("Record %d: Citation key is empty, skipping", idx), "WarningMsg" } },
				true,
				{}
			)
			goto continue
		end

		local filename = citation_key .. ".norg"
		local filepath = vim.fn.expand("~/Notes/Brain2/papers/" .. filename)

		if vim.fn.filereadable(filepath) == 1 and not force then
			goto continue
		end

		local title = rec.title or ""

		local year = ""
		if
			rec.issued
			and type(rec.issued) == "table"
			and rec.issued["date-parts"]
			and type(rec.issued["date-parts"]) == "table"
			and #rec.issued["date-parts"] >= 1
			and type(rec.issued["date-parts"][1]) == "table"
			and #rec.issued["date-parts"][1] >= 1
		then
			local y = rec.issued["date-parts"][1][1]
			if y then
				year = tostring(y)
			end
		end

		local authors_str = authors_to_string(rec.author)

		local doi = rec.DOI or rec.doi or ""

		local lines = {
			"",
			"___",
			string.format("* %s", title),
			"",
			string.format("- Authors: %s", authors_str),
			string.format("- Year: %s", year),
			string.format("- DOI: [Paper Link]{www.doi.org/%s}", doi),
			string.format("- Paper: {/ ./pdfs/%s.pdf}[PDF]", citation_key),
			"",
			"___",
		}

		local f, ferr = io.open(filepath, "w")
		if not f then
			vim.api.nvim_echo({
				{
					string.format("Error opening file for write: %s – %s", citation_key, tostring(ferr)),
					"ErrorMsg",
				},
			}, true, { err = true })
			goto continue
		end

		for _, line in ipairs(lines) do
			f:write(line)
			f:write("\n")
		end
		f:close()

		::continue::
	end
end

vim.api.nvim_create_user_command("RefreshPapers", function()
	generate_norg_files(false)
end, {})
vim.api.nvim_create_user_command("ForceRefreshPapers", function()
	generate_norg_files(true)
end, {})
vim.keymap.set("n", "<leader>lrp", "<cmd>RefreshPapers<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>flrp", "<cmd>ForceRefreshPapers<CR>", { noremap = true, silent = true })
