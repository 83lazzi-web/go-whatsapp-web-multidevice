package main

import (
	"embed"

	"github.com/aldinokemal/go-whatsapp-web-multidevice/cmd"
)

//go:embed views/index.html
var embedIndex embed.FS

//go:embed views
var embedViews embed.FS

// teste
func main() {
	cmd.Execute(embedIndex, embedViews)
}
