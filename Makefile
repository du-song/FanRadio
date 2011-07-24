install:
	rake dmg
	rake feed
	scp appcast/build/* ladder.rollingcode.org:www/app/fanradio/
	#cp -L appcast/build/release_notes.html appcast/build/appcast.xml ~/Projects/AppEngine/rollingcode/static/app/fanradio 
