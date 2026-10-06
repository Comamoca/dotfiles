package main

import (
	"strconv"
	"strings"
)

// diagnostic is one licence report for a package, anchored at a line of the
// manifest it was found in.
type diagnostic struct {
	file     string
	line     int
	col      int
	severity byte
	message  string
}

// format renders the diagnostic using an errorformat template. The recognised
// tokens are the ones efm-langserver understands: %f (file), %l (line),
// %c (column), %t (severity) and %m (message). %% emits a literal percent
// sign, and unknown tokens are kept verbatim so a typo stays visible.
func (d diagnostic) format(template string) string {
	var b strings.Builder
	b.Grow(len(template) + len(d.file) + len(d.message))
	for i := 0; i < len(template); i++ {
		if template[i] != '%' || i == len(template)-1 {
			b.WriteByte(template[i])
			continue
		}
		i++
		switch template[i] {
		case 'f':
			b.WriteString(d.file)
		case 'l':
			b.WriteString(strconv.Itoa(d.line))
		case 'c':
			b.WriteString(strconv.Itoa(d.col))
		case 't':
			b.WriteByte(d.severity)
		case 'm':
			b.WriteString(d.message)
		case '%':
			b.WriteByte('%')
		default:
			b.WriteByte('%')
			b.WriteByte(template[i])
		}
	}
	return b.String()
}
