// Command goda-fi-config is coma's goda-fi.vim configuration: an ordinary Go
// program that links the sources, filters and kinds below into one binary.
//
// goda-fi.vim runs the built binary (see g:goda_fi#binary). Rebuild it after
// every change here:
//
//	go build -o ~/.cache/nvim/goda-fi/goda-fi .
//
// Option names are ddu.vim's; extension names lose their "_" ("file_rec" is
// "filerec", "matcher_substring" is "matchersubstring").
package main

import (
	"github.com/Shougo/goda-fi.vim/ext/column/filename"
	"github.com/Shougo/goda-fi.vim/ext/filter/converterhldir"
	"github.com/Shougo/goda-fi.vim/ext/filter/matcherfiles"
	"github.com/Shougo/goda-fi.vim/ext/filter/matcherhidden"
	"github.com/Shougo/goda-fi.vim/ext/filter/matcherrelative"
	"github.com/Shougo/goda-fi.vim/ext/filter/matchersubstring"
	"github.com/Shougo/goda-fi.vim/ext/filter/sorteralpha"
	"github.com/Shougo/goda-fi.vim/ext/filter/sortermtime"
	kindfile "github.com/Shougo/goda-fi.vim/ext/kind/file"
	"github.com/Shougo/goda-fi.vim/ext/kind/url"
	"github.com/Shougo/goda-fi.vim/ext/kind/word"
	"github.com/Shougo/goda-fi.vim/ext/source/buffer"
	"github.com/Shougo/goda-fi.vim/ext/source/file"
	"github.com/Shougo/goda-fi.vim/ext/source/fileexternal"
	"github.com/Shougo/goda-fi.vim/ext/source/fileold"
	"github.com/Shougo/goda-fi.vim/ext/source/filepoint"
	"github.com/Shougo/goda-fi.vim/ext/source/filerec"
	"github.com/Shougo/goda-fi.vim/ext/source/line"
	"github.com/Shougo/goda-fi.vim/ext/source/pathhistory"
	"github.com/Shougo/goda-fi.vim/ext/source/register"
	"github.com/Shougo/goda-fi.vim/ext/source/rg"
	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda-fi.vim/ui/ff"
	"github.com/Shougo/goda-fi.vim/ui/filer"
)

func main() {
	b := fi.New()

	// --- UIs -------------------------------------------------------------
	b.AddUI(ff.New())
	b.AddUI(filer.New())

	// --- Sources ---------------------------------------------------------
	b.AddSource(file.New(file.Params{}))
	b.AddSource(filerec.New(filerec.Params{
		IgnoredDirectories: []string{".git", "node_modules", ".direnv", "result"},
	}))
	b.AddSource(fileexternal.New(fileexternal.Params{
		Cmd: []string{"git", "ls-files", "--cached", "--others", "--exclude-standard"},
	}))
	b.AddSource(fileold.New())
	b.AddSource(filepoint.New())
	b.AddSource(buffer.New())
	b.AddSource(line.New(line.Params{}))
	b.AddSource(register.New())
	b.AddSource(pathhistory.New())
	b.AddSource(rg.New(rg.Params{
		Args: []string{"--column", "--no-heading", "--color", "never", "--smart-case"},
	}))

	// --- Filters ---------------------------------------------------------
	b.AddFilter(matchersubstring.New(matchersubstring.Params{HighlightMatched: "Search"}))
	b.AddFilter(matcherfiles.New(matcherfiles.Params{}))
	b.AddFilter(matcherhidden.New())
	b.AddFilter(matcherrelative.New())
	b.AddFilter(sorteralpha.New())
	b.AddFilter(sortermtime.New())
	b.AddFilter(converterhldir.New(converterhldir.Params{}))

	// --- Kinds / columns -------------------------------------------------
	b.AddKind(kindfile.New())
	b.AddKind(word.New())
	b.AddKind(url.New())
	b.AddColumn(filename.New(filename.DefaultParams()))

	// --- ddu#custom#patch_global() ---------------------------------------
	b.PatchGlobal(fi.Options{
		UI: "ff",
		UIParams: map[string]fi.Params{
			"ff": {
				"split":                 "floating",
				"winHeight":             20,
				"winWidth":              "&columns - 20",
				"autoResize":            true,
				"overwriteStatusline":   true,
				"displaySourceName":     "short",
				"previewFloating":       true,
				"previewFloatingBorder": "rounded",
				"previewHeight":         20,
				"previewWidth":          "&columns - 20",
			},
		},
		SourceOptions: map[string]fi.SourceOptions{
			"_": {
				Matchers:   []string{"matchersubstring"},
				IgnoreCase: new(true),
				SmartCase:  new(true),
			},
			"file":         {Columns: []string{"filename"}},
			"filerec":      {Columns: []string{"filename"}},
			"fileexternal": {Columns: []string{"filename"}},
			"fileold":      {Columns: []string{"filename"}},
			"filepoint":    {Columns: []string{"filename"}},
			"rg":           {Columns: []string{"filename"}},
		},
		KindOptions: map[string]fi.KindOptions{
			"file": {DefaultAction: "open"},
			"word": {DefaultAction: "append"},
			"url":  {DefaultAction: "browse"},
		},
	})

	// --- ddu#custom#patch_local() ----------------------------------------
	// Sessions started from the keymaps of ~/.config/nvim tie the name to a
	// source, so `goda_fi#start({'name': 'files', 'resume': v:true})` works.
	b.PatchLocal("files", fi.Options{
		Sources: fi.Sources("filerec"),
		SourceOptions: map[string]fi.SourceOptions{
			"filerec": {Matchers: []string{"matchersubstring"}},
		},
	})
	b.PatchLocal("gitfiles", fi.Options{
		Sources: fi.Sources("fileexternal"),
	})
	b.PatchLocal("buffers", fi.Options{
		Sources: fi.Sources("buffer"),
		SourceOptions: map[string]fi.SourceOptions{
			"buffer": {Sorters: []string{"sorteralpha"}, Columns: []string{"filename"}},
		},
	})
	b.PatchLocal("lines", fi.Options{
		Sources: fi.Sources("line"),
	})
	b.PatchLocal("rg", fi.Options{
		Sources: fi.Sources("rg"),
		// ddu の rg は UI の入力をそのまま source に渡すが、goda-fi の rg は
		// volatile でないと SourceParams.Input しか読まない (入力が空だと
		// 何も返さない)。volatile にすると live の input で毎回検索する。
		SourceOptions: map[string]fi.SourceOptions{
			"rg": {Volatile: new(true)},
		},
	})
	b.PatchLocal("histories", fi.Options{
		Sources: fi.Sources("fileold", "pathhistory"),
	})

	b.Main()
}
