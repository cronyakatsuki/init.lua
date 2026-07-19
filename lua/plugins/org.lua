--    When nvim-orgmode is (re)installed or updated, rebuild its
--    tree-sitter grammar automatically.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "orgmode" and (kind == "install" or kind == "update") then
      if not ev.data.active then vim.cmd.packadd("orgmode") end
      vim.cmd("Org install_grammar")
    end
  end,
})

-- Install org mode and org-roam
vim.pack.add({
  {
    src = "https://github.com/nvim-orgmode/orgmode",
    version = "0.7.0",
  },

  {
    src = "https://github.com/chipsenkbeil/org-roam.nvim",
    version = "0.2.0",
  },
})

local ORG_DIR = "~/org"

-- Defer orgmode setup to after startup (~23ms saved)
vim.schedule(function()
require("orgmode").setup({
  -- ─── Agenda Files ───────────────────────────────────────────────
  org_agenda_files = {
    ORG_DIR .. "/tasks.org",
    ORG_DIR .. "/journal.org",
    ORG_DIR .. "/inbox.org",
    ORG_DIR .. "/someday.org",
    ORG_DIR .. "/notes/**/*.org",
    ORG_DIR .. "/journal/**/*.org",
    ORG_DIR .. "/projects/**/*.org",
  },

  -- Default file for refile and quick capture (your inbox)
  org_default_notes_file = ORG_DIR .. "/inbox.org",

  org_archive_location = ORG_DIR .. "/archive/%s_archive::",

  org_todo_keywords = {
    "TODO(t)", "NEXT(n)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)",
  },

  org_capture_templates = {
    -- ── t: Task → tasks.org ──
    t = {
      description = "Task",
      template = "* TODO %?\n  SCHEDULED: %t\n  :PROPERTIES:\n  :CREATED: %U\n  :END:",
      target = ORG_DIR .. "/tasks.org",
    },
    -- ── n: Quick note → inbox.org (refile later) ──
    n = {
      description = "Note (inbox)",
      template = "* %?\n  :PROPERTIES:\n  :CREATED: %U\n  :END:",
      target = ORG_DIR .. "/inbox.org",
    },
    -- ── i: Inbox item (no TODO keyword, just a note to triage) ──
    i = {
      description = "Inbox",
      template = "* %?\n  %U",
      target = ORG_DIR .. "/inbox.org",
    },
    -- ── j: Journal entry → journal.org (single-file journal) ──
    -- Uses a datetree so entries are grouped by year → month → day
    j = {
      description = "Journal",
      template = "* %?\n  %U",
      target = ORG_DIR .. "/journal.org",
      datetree = {
        tree_type = "day",
        reversed = true, -- newest entries at the top
      },
      properties = {
        empty_lines = 1, -- blank line between entries
      },
    },

    -- ── m: Meeting → tasks.org (with action items section) ──
    m = {
      description = "Meeting",
      template = {
        "* Meeting: %?",
        "  SCHEDULED: %t",
        "  :PROPERTIES:",
        "  :CREATED: %U",
        "  :END:",
        "** Notes",
        "- ",
        "** Action items",
        "- [ ] ",
      },
      target = ORG_DIR .. "/tasks.org",
    },

    -- ── e: Event (nested under "Events" headline in tasks.org) ──
    e = {
      description = "Event",
      template = "* %?\n  SCHEDULED: %^t",
      target = ORG_DIR .. "/tasks.org",
      headline = "Events",
    },

    -- capture directly to a "someday/maybe" file
    s = {
      description = "Someday/Maybe",
      template = "* SOMEDAY %?\n  :PROPERTIES:\n  :CREATED: %U\n  :END:",
      target = ORG_DIR .. "/someday.org",
    },
  },

  -- ─── Agenda Settings ────────────────────────────────────────────
  org_agenda_span = "week",
  org_deadline_warning_days = 14,

  -- Custom agenda views: <leader>oa then press the key
  org_agenda_custom_commands = {
    -- a: All TODOs across every file
    a = {
      description = "All TODOs",
      types = {
        {
          type = "todo",
          org_agenda_overriding_header = "All TODOs",
        },
      },
    },
    -- n: Next actions only
    n = {
      description = "Next actions",
      types = {
        {
          type = "tags_todo",
          match = 'TODO="NEXT"',
          org_agenda_overriding_header = "Next Actions",
        },
      },
    },
    -- w: Waiting / delegated
    w = {
      description = "Waiting on",
      types = {
        {
          type = "tags_todo",
          match = 'TODO="WAITING"',
          org_agenda_overriding_header = "Waiting on…",
        },
      },
    },
    -- i: Inbox triage (all headlines in inbox.org with no TODO keyword)
    i = {
      description = "Inbox triage",
      types = {
        {
          type = "search",
          match = "{.*}", -- match all headlines
          org_agenda_files = { ORG_DIR .. "/inbox.org" },
          org_agenda_overriding_header = "Inbox — triage me",
        },
      },
    },
    r = {
      description = "Review completed (DONE/CANCELLED)",
      types = {
        {
          type = "search",
          match = 'TODO="DONE"|TODO="CANCELLED"',
          org_agenda_files = {
            ORG_DIR .. "/tasks.org",
            ORG_DIR .. "/inbox.org",
            ORG_DIR .. "/journal.org",
          },
          org_agenda_overriding_header = "Recently completed — archive when ready",
        },
      },
    },
  },

  -- ─── Notifications (desktop + cron) ─────────────────────────────
  notifications = {
    enabled = true,               -- in-editor floating notifications
    cron_enabled = true,          -- system notifications even when Neovim is closed
    reminder_time = { 1, 5, 10 }, -- minutes before scheduled/deadline
    deadline_reminder = true,
    scheduled_reminder = true,
    cron_notifier = function(tasks)
      for _, task in ipairs(tasks) do
        local title = string.format("%s (%s)", task.category, task.humanized_duration)
        local body = string.format("%s %s\n%s: %s",
          string.rep("*", task.level), task.todo, task.type, task.time:to_string())
        if vim.fn.executable("notify-send") == 1 then
          vim.system({ "notify-send", "--app-name=orgmode", title, body })
        end
      end
    end,
  },
})

  -- Experimental LSP support
  vim.lsp.enable("org")

  -- Configure org-roam.nvim
require("org-roam").setup({
  -- Your roam node files live in notes/
  directory = ORG_DIR .. "/notes",

  -- Include other org files so roam can find nodes outside notes/
  -- (e.g. headlines in tasks.org or journal.org you've linked to)
  org_files = {
    ORG_DIR .. "/tasks.org",
    ORG_DIR .. "/inbox.org",
    ORG_DIR .. "/journal.org",
  },
  -- ─── Dailies Extension ──────────────────────────────────────────
  -- File naming: YYYYMMDD (e.g. 20260716)
  dailies = {
    -- Directory where daily files are stored (under your roam directory)
    directory = ORG_DIR .. "/journal",

    -- Capture template for new daily entries
    capture = {
      -- Template used when you press <leader>ndN (capture today's daily)
      template = {
        "* %<%Y-%m-%d %A>",
        "  :PROPERTIES:",
        "  :CREATED: %U",
        "  :END:",
        "",
        "** Journal",
        "%?",
        "",
        "** Tasks",
        "",
        "** Log",
        "",
      },
    },

    -- Keybindings (all global, prefixed with <leader>nd)
    keybinds = {
      capture_today     = "<leader>ndN", -- capture today's daily
      capture_tomorrow  = "<leader>ndT", -- capture tomorrow's
      capture_yesterday = "<leader>ndY", -- capture yesterday's
      goto_today        = "<leader>ndn", -- navigate to today's note
      goto_date         = "<leader>ndd", -- pick a date to navigate to
      next_day          = "<leader>ndf", -- go forward one day
      previous_day      = "<leader>ndb", -- go back one day
      open_dailies_dir  = "<leader>nd.", -- open journal/ in a file browser
    },
  },
})
end)
