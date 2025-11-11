return {
	"goolord/alpha-nvim",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		local header = {
			type = "text",
			val = {
				[[                                                                     ]],
				[[       ████ ██████           █████      ██                     ]],
				[[      ███████████             █████                             ]],
				[[      █████████ ███████████████████ ███   ███████████   ]],
				[[     █████████  ███    █████████████ █████ ██████████████   ]],
				[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
				[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
				[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
			},
			opts = { position = "center", hl = "AlphaHeader" },
		}

		local main_buttons = {
			type = "group",
			val = {
				dashboard.button("f", "󰮗  Find File", ":Telescope find_files <CR>"),
				dashboard.button("n", "  New File", ":enew<CR>"),
				dashboard.button("e", "󰙅  Open Oil", "<Cmd>Oil<CR>"),
				dashboard.button("d", "󰂺  Open Journal", ":cd ~/Notes/Brain2/ | Neorg journal today<CR>"),
				dashboard.button("i", "󰧑  Open Index", ":cd ~/Notes/Brain2/ | Neorg index <CR>"),
			},
			opts = { spacing = 1 },
		}

		local subheader = {
			type = "text",
			val = {
				[[████████╗ ██████╗ ██████╗  ██████╗ ]],
				[[╚══██╔══╝██╔═══██╗██╔══██╗██╔═══██╗]],
				[[   ██║   ██║   ██║██║  ██║██║   ██║]],
				[[   ██║   ██║   ██║██║  ██║██║   ██║]],
				[[   ██║   ╚██████╔╝██████╔╝╚██████╔╝]],
				[[   ╚═╝    ╚═════╝ ╚═════╝  ╚═════╝ ]],
			},
			opts = { position = "center", hl = "AlphaHeader" },
		}

		local todo_items = {}

		local function populateTasks()
			local root = vim.fn.expand("~/Notes/Brain2")
			local pattern = [[- \(\s*\)]]
			local cmd = {
				"rg",
				"--no-heading",
				"-n",
				"--glob",
				"*.norg",
				"-g",
				"!journal/**",
				"-g",
				"!papers/**",
				"-e",
				pattern,
				root,
			}
			local results = vim.fn.systemlist(cmd)

			local function trim(s)
				return (s:match("^%s*(.-)%s*$"))
			end

			local function splitByWhitespace(str)
				local t = {}
				for word in str:gmatch("%S+") do
					table.insert(t, word)
				end
				return t
			end

			local monthNames = {
				["january"] = 1,
				["february"] = 2,
				["march"] = 3,
				["april"] = 4,
				["may"] = 5,
				["june"] = 6,
				["july"] = 7,
				["august"] = 8,
				["september"] = 9,
				["october"] = 10,
				["november"] = 11,
				["december"] = 12,
			}

			local function getMonthNumber(monthName)
				local lowerMonthName = string.lower(monthName)
				local monthNum = monthNames[lowerMonthName]
				if monthNum then
					return monthNum
				else
					return nil
				end
			end

			local function getDaysDifference(date1, date2)
				local timestamp1 = os.time(date1)
				local timestamp2 = os.time(date2)
				local differenceInSeconds = os.difftime(timestamp2, timestamp1)
				local differenceInDays = differenceInSeconds / (24 * 60 * 60)
				return differenceInDays
			end

			local function dayToString(days_offset)
				if days_offset < -1 then
					return string.format("%d days ago", math.abs(days_offset))
				elseif days_offset == -1 then
					return "Yesterday"
				elseif days_offset == 0 then
					return "Today"
				elseif days_offset == 1 then
					return "Tomorrow"
				elseif days_offset > 1 then
					return string.format("In %d days", days_offset)
				else
					return "Invalid input"
				end
			end

			local tasks = {}

			for _, line in ipairs(results) do
				local first_colon = line:find(":")
				if not first_colon then goto continue end
				local second_colon = line:find(":", first_colon + 1)
				if not second_colon then goto continue end
				local third_colon = line:find(":", second_colon + 1)
				if not third_colon then goto continue end

				local path = trim(line:sub(1, second_colon - 1))
				local line_num = trim(line:sub(second_colon + 1, third_colon - 1))
				local rest = line:sub(third_colon + 1)

				local rparen = rest:find("%)")
				if not rparen then goto continue end

				local status = trim(rest:sub(1, rparen-1))
				rest = rest:sub(rparen+1)

				local brace = rest:find("}")
				if not brace then goto continue end

				local deadline = trim(rest:sub(1, brace-1))
				local item = trim(rest:sub(brace+1))

				local deadline_parts = splitByWhitespace(deadline)

				local currentDate = os.date("*t")
				local targetMonth = getMonthNumber(deadline_parts[4])
				if not targetMonth then goto continue end
				local targetDate = {
					year = tonumber(deadline_parts[5]),
					month = getMonthNumber(deadline_parts[4]),
					day = tonumber(deadline_parts[3]) + 1,
					hour = 0,
					min = 0,
					sec = 0,
				}

				local relativeDeadline = dayToString(math.floor(getDaysDifference(currentDate, targetDate)))

				local doesItemNeedTrimming = (string.len(relativeDeadline) + string.len(item)) > 40
				if doesItemNeedTrimming then
					item = string.sub(item, 1, (40 - string.len(relativeDeadline))) .. "..."
				end

				tasks[#tasks + 1] = {
					path = path,
					line_num = line_num,
					status = status,
					deadline = math.floor(getDaysDifference(currentDate, targetDate)),
					item = item,
				}

				::continue::
			end

			table.sort(tasks, function(a, b)
				return a.deadline < b.deadline
			end)

			local no_tasks = true
			for i, task in ipairs(tasks) do
				no_tasks = false
				if i > 8 then break end
				if task.deadline > 30 then break end
				todo_items[i] = dashboard.button(
					tostring(i),
					"(" .. dayToString(task.deadline) .. "): " .. task.item,
					":cd ~/notes/Brain2 | e " .. task.path .. "|" .. task.line_num .. "<CR>"
				)
			end

			if no_tasks then
				table.insert(todo_items, dashboard.button("q", "󰳑  Nothing left to do", ":q<CR>"))
			end
		end

		local todos = {
			type = "group",
			val = todo_items,
			opts = { spacing = 1 },
		}

		populateTasks()

		dashboard.config.layout = {
			{ type = "padding", val = 4 },
			header,
			{ type = "padding", val = 2 },
			main_buttons,
			{ type = "padding", val = 2 },
			subheader,
			{ type = "padding", val = 2 },
			todos,
		}

		dashboard.section.header = nil
		dashboard.section.buttons = nil

		vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#2BC6FF", bold = true })
		alpha.setup(dashboard.opts)

		vim.keymap.set("n", "<leader>A", function()
			vim.cmd("Alpha")
			populateTasks()
		end, { desc = "Launch Alpha" })
	end,
}
