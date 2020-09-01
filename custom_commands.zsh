phpv() {
    valet stop
    brew unlink php@7.0 php@7.1 php@7.2 php@7.3 php@7.4
    brew link --force --overwrite $1
    brew services start $1
    composer global update
	  rm -f ~/.config/valet/valet.sock
    valet install
}
