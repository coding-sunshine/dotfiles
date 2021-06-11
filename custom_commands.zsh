phpv() {
    valet stop
    brew unlink php@7.1 php@7.2 php@7.3 php@7.4 php@8.0
    brew link --force --overwrite $1
    brew services start $1
    composer global update
	  rm -f ~/.config/valet/valet.sock
    valet install
    valet use $1
}
