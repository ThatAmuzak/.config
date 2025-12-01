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

local function trim(s)
	if type(s) ~= "string" then
		return s
	end
	return s:gsub("^%s*(.-)%s*$", "%1")
end

local function authors_to_string(authors_tbl)
	if type(authors_tbl) ~= "table" then
		return ""
	end
	local names = {}
	for _, a in ipairs(authors_tbl) do
		local given = a.given or ""
		local family = a.family or ""
		given = trim(given)
		family = trim(family)
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

-- Try several common CSL/metadata keys to find a container (journal / conference) and publisher
local function resolve_publication_and_publisher(rec)
	local publication = ""
	local publisher = ""

	-- Publication name: common fields
	local pfields = {
		"container-title",
		"container-title-short",
		"container_title",
		"collection-title",
		"collection_title",
		"journal",
		"journal-title",
		"publisher",
	}
	for _, k in ipairs(pfields) do
		if type(rec[k]) == "string" and trim(rec[k]) ~= "" then
			publication = trim(rec[k])
			break
		end
		-- also try dotted access
		if rec[k] == nil and type(rec[k:gsub("%-", "_")]) == "string" and trim(rec[k:gsub("%-", "_")]) ~= "" then
			publication = trim(rec[k:gsub("%-", "_")])
			break
		end
	end

	if type(rec.publisher) == "string" and trim(rec.publisher) ~= "" then
		publisher = trim(rec.publisher)
	elseif type(rec["publisher"]) == "string" and trim(rec["publisher"]) ~= "" then
		publisher = trim(rec["publisher"])
	end

	if publication == "" then
		if type(rec["event"]) == "string" and trim(rec["event"]) ~= "" then
			publication = trim(rec["event"])
		elseif type(rec["booktitle"]) == "string" and trim(rec["booktitle"]) ~= "" then
			publication = trim(rec["booktitle"])
		end
	end

	return publication, publisher
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

	local counter = 0
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

		local publication_name, publisher = resolve_publication_and_publisher(rec)
		local publication_line = ""
		if publication_name ~= "" then
			if publisher ~= "" then
				publication_line = string.format("- Publication: %s (%s)", publication_name, publisher)
			else
				publication_line = string.format("- Publication: %s", publication_name)
			end
		elseif publisher ~= "" then
			publication_line = string.format("- Publisher: %s", publisher)
		end

		local lines = {
			"",
			"___",
			string.format("* %s", title),
			"",
			string.format("- Authors: %s", authors_str),
			string.format("- Year: %s", year),
		}

		counter = counter + 1

		if publication_line ~= "" then
			table.insert(lines, publication_line)
		end

		table.insert(lines, string.format("- DOI: [Paper Link]{www.doi.org/%s}", doi))
		table.insert(lines, string.format("- Paper: {/ ./pdfs/%s.pdf}[PDF]", citation_key))
		table.insert(lines, string.format("- Text: {/ ./txts/%s.txt}[Text]", citation_key))
		table.insert(lines, "")
		table.insert(lines, "___")

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

	if counter > 0 then
		vim.notify("Paper notes generation complete. Added " .. counter .. " papers")
	else
		vim.notify("No new papers to add")
	end
end

vim.api.nvim_create_user_command("RefreshPapers", function()
	generate_norg_files(false)
end, {})
vim.api.nvim_create_user_command("ForceRefreshPapers", function()
	generate_norg_files(true)
end, {})
vim.keymap.set("n", "<leader>nrp", "<cmd>RefreshPapers<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>nrfp", "<cmd>ForceRefreshPapers<CR>", { noremap = true, silent = true })


-- Automatic summarizer

local api = require("avante.api")

-- your custom function
local function summarize_paper()
	local cwd = vim.loop.cwd()
	local expected = vim.loop.fs_realpath(vim.fn.expand("~/Notes/Brain2"))
	local real_cwd = vim.loop.fs_realpath(cwd)
	if real_cwd ~= expected then
		vim.notify("⚠️ Not in ~/Notes/Brain2; current working directory is: " .. cwd, vim.log.levels.WARN)
		return
	end

	-- Get current buffer name, strip extension
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" then
		vim.notify("No file name for current buffer", vim.log.levels.ERROR)
		return
	end
	local filename = vim.fn.fnamemodify(bufname, ":t:r")  -- get tail, remove extension

	local relpath = string.format("papers/txts/%s.txt", filename)

	api.ask({ new_chat = true })

	api.add_selected_file(relpath)

	-- Feed the keys
	vim.defer_fn(function()
		local seq = "#Summarize" .. vim.api.nvim_replace_termcodes("<C-s>", true, false, true)
		vim.api.nvim_feedkeys(seq, "i", true)
	end, 600)
end

vim.keymap.set("n", "<leader>up", summarize_paper, { desc = "Avante: Summarize research paper" })
